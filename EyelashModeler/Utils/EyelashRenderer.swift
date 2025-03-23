import UIKit
import Vision

class EyelashRenderer {
    
    // Renders eyelashes on an image based on face landmarks
    func renderEyelashes(on image: UIImage, with faceObservation: VNFaceObservation, using eyelashModel: EyelashModel, completion: @escaping (UIImage?) -> Void) {
        // Create a face detection model
        let faceModel = FaceDetectionModel(faceObservation: faceObservation, originalImage: image)
        
        // Create a new image context
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        // Draw the original image
        image.draw(at: .zero)
        
        // Get the current graphics context
        guard let context = UIGraphicsGetCurrentContext() else {
            completion(nil)
            return
        }
        
        // Draw eyelashes on both eyes
        drawEyelashes(
            for: .left,
            on: context,
            with: faceModel,
            using: eyelashModel
        )
        
        drawEyelashes(
            for: .right,
            on: context,
            with: faceModel,
            using: eyelashModel
        )
        
        // Get the resulting image
        guard let renderedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            completion(nil)
            return
        }
        
        // Return the image with eyelashes applied
        completion(renderedImage)
    }
    
    private enum EyeSide {
        case left
        case right
    }
    
    private func drawEyelashes(for side: EyeSide, on context: CGContext, with faceModel: FaceDetectionModel, using eyelashModel: EyelashModel) {
        // Get the eye points
        let eyePoints: [CGPoint]?
        let eyebrowPoints: [CGPoint]?
        
        switch side {
        case .left:
            eyePoints = faceModel.getLeftEyePoints()
            eyebrowPoints = faceModel.leftEyebrowLandmarks?.normalizedPoints.map { point in
                CGPoint(
                    x: point.x * faceModel.originalImage.size.width,
                    y: (1 - point.y) * faceModel.originalImage.size.height
                )
            }
        case .right:
            eyePoints = faceModel.getRightEyePoints()
            eyebrowPoints = faceModel.rightEyebrowLandmarks?.normalizedPoints.map { point in
                CGPoint(
                    x: point.x * faceModel.originalImage.size.width,
                    y: (1 - point.y) * faceModel.originalImage.size.height
                )
            }
        }
        
        guard let points = eyePoints, !points.isEmpty else {
            return
        }
        
        // Get the top points of the eye (where eyelashes would be attached)
        let topPoints = getTopEyelidPoints(from: points)
        
        // Get the eye center
        let eyeCenter: CGPoint?
        switch side {
        case .left:
            eyeCenter = faceModel.getLeftEyeCenter()
        case .right:
            eyeCenter = faceModel.getRightEyeCenter()
        }
        
        guard let center = eyeCenter else {
            return
        }
        
        // Calculate the average eye width to scale the eyelashes
        let eyeWidth = faceModel.getAverageEyeWidth() ?? 50.0
        
        // Set drawing properties based on the eyelash model
        let eyelashColor = UIColor.black
        let eyelashWidth = CGFloat(eyelashModel.thickness) * 2
        
        context.setStrokeColor(eyelashColor.cgColor)
        context.setLineWidth(eyelashWidth)
        context.setLineCap(.round)
        
        // Draw eyelashes using the model properties
        let eyebrowDistance = calculateEyebrowDistance(eyePoints: topPoints, eyebrowPoints: eyebrowPoints)
        let baseLength = CGFloat(eyelashModel.length) * eyeWidth / 20.0
        
        for i in 0..<topPoints.count {
            // Skip some points for a more natural look
            if i % 2 != 0 {
                continue
            }
            
            let point = topPoints[i]
            
            // Calculate direction vector from eye center to eyelid point
            var dirX = point.x - center.x
            var dirY = point.y - center.y
            
            // Normalize the direction vector
            let length = sqrt(dirX * dirX + dirY * dirY)
            if length > 0 {
                dirX /= length
                dirY /= length
            }
            
            // Calculate length based on position (longer in the middle for some styles)
            var lashLength = baseLength
            
            // Adjust based on style
            switch eyelashModel.style {
            case .natural:
                // Natural style has fairly uniform length
                lashLength *= 0.8 + 0.4 * sin(CGFloat(i) / CGFloat(topPoints.count) * .pi)
                
            case .volume:
                // Volume style has slightly longer lashes in the middle
                lashLength *= 0.7 + 0.6 * sin(CGFloat(i) / CGFloat(topPoints.count) * .pi)
                
            case .dramatic:
                // Dramatic style has much longer lashes in the middle
                lashLength *= 0.6 + 0.8 * sin(CGFloat(i) / CGFloat(topPoints.count) * .pi)
                
            case .catEye:
                // Cat eye style has longer lashes on the outer edge
                let normalizedPos = CGFloat(i) / CGFloat(topPoints.count)
                let factor = side == .left ? normalizedPos : (1 - normalizedPos)
                lashLength *= 0.7 + 0.7 * factor
                
            case .dolly:
                // Dolly style has longer lashes in the middle for a rounded look
                lashLength *= 0.6 + 0.8 * sin(CGFloat(i) / CGFloat(topPoints.count) * .pi)
                
            case .squirrel:
                // Squirrel style has crossed lashes
                lashLength *= 0.7 + 0.5 * sin(CGFloat(i) / CGFloat(topPoints.count) * 2 * .pi)
            }
            
            // Apply curl based on the model
            var curlFactor: CGFloat = 0
            switch eyelashModel.curve {
            case .jCurl:
                curlFactor = 0.1
            case .bCurl:
                curlFactor = 0.2
            case .cCurl:
                curlFactor = 0.4
            case .dCurl:
                curlFactor = 0.6
            case .lCurl:
                curlFactor = 0.8
            case .uCurl:
                curlFactor = 1.0
            }
            
            // Calculate the end point with curl
            let endX = point.x + dirX * lashLength
            let endY = point.y + dirY * lashLength
            
            // Calculate control point for the curve (to create the curl)
            let controlX = point.x + dirX * lashLength * 0.7 + dirY * lashLength * curlFactor * (side == .left ? -0.3 : 0.3)
            let controlY = point.y + dirY * lashLength * 0.7 - dirX * lashLength * curlFactor * (side == .left ? -0.3 : 0.3)
            
            // Draw the eyelash as a curved line
            context.beginPath()
            context.move(to: point)
            context.addQuadCurve(to: CGPoint(x: endX, y: endY), control: CGPoint(x: controlX, y: controlY))
            context.strokePath()
        }
    }
    
    // Get the top points of the eyelid
    private func getTopEyelidPoints(from eyePoints: [CGPoint]) -> [CGPoint] {
        // Sort points by y coordinate (top to bottom)
        let sortedPoints = eyePoints.sorted { $0.y < $1.y }
        
        // Take the top half of points
        let topHalfCount = max(eyePoints.count / 2, 5)
        let topPoints = Array(sortedPoints.prefix(topHalfCount))
        
        // Sort these points by x coordinate (left to right)
        return topPoints.sorted { $0.x < $1.x }
    }
    
    // Calculate distance between eyebrow and eye
    private func calculateEyebrowDistance(eyePoints: [CGPoint], eyebrowPoints: [CGPoint]?) -> CGFloat {
        guard let eyebrowPoints = eyebrowPoints, !eyebrowPoints.isEmpty else {
            return 20.0  // Default value if eyebrow not detected
        }
        
        // Get the average y-coordinate of the top eyelid
        let avgEyeY = eyePoints.reduce(0) { $0 + $1.y } / CGFloat(eyePoints.count)
        
        // Get the average y-coordinate of the eyebrow
        let avgEyebrowY = eyebrowPoints.reduce(0) { $0 + $1.y } / CGFloat(eyebrowPoints.count)
        
        // Return the vertical distance
        return max(avgEyeY - avgEyebrowY, 10.0)
    }
}
