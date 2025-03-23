import UIKit

class EyelashRenderer {
    
    // Renders eyelashes on the provided image based on face detection model and eyelash model
    func renderEyelashes(on image: UIImage, 
                         faceDetection: FaceDetectionModel, 
                         eyelashModel: EyelashModel) -> UIImage? {
        
        // Check if we have the required eye data for rendering
        guard faceDetection.hasEyesDetected else {
            print("Cannot render eyelashes: Eye data not available")
            return nil
        }
        
        // Begin image context to draw on
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        // Draw the original image
        image.draw(at: .zero)
        
        // Get the current context to draw on
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Render eyelashes for each eye
        renderEyelashesForEye(.left, context: context, faceDetection: faceDetection, eyelashModel: eyelashModel, imageSize: image.size)
        renderEyelashesForEye(.right, context: context, faceDetection: faceDetection, eyelashModel: eyelashModel, imageSize: image.size)
        
        // Get the resulting image with eyelashes
        guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        return resultImage
    }
    
    // Render eyelashes for a specific eye
    private func renderEyelashesForEye(_ eyePosition: EyePosition, 
                                      context: CGContext, 
                                      faceDetection: FaceDetectionModel, 
                                      eyelashModel: EyelashModel, 
                                      imageSize: CGSize) {
        
        // Get the eyelash positions for this eye
        let lashPositions = faceDetection.getEyelashPositions(for: eyePosition, withSize: imageSize)
        
        // Exit if no positions are available
        guard !lashPositions.isEmpty else { return }
        
        // Save the context state before modifications
        context.saveGState()
        
        // Set the drawing properties based on eyelash model
        configureDrawingProperties(for: context, eyelashModel: eyelashModel)
        
        // Draw each eyelash
        for (index, position) in lashPositions.enumerated() {
            drawSingleEyelash(at: position, 
                             index: index, 
                             totalLashes: lashPositions.count, 
                             context: context, 
                             eyelashModel: eyelashModel, 
                             eyePosition: eyePosition)
        }
        
        // Restore the context state
        context.restoreGState()
    }
    
    // Configure the drawing context based on eyelash properties
    private func configureDrawingProperties(for context: CGContext, eyelashModel: EyelashModel) {
        // Set color - black by default, but can be customized
        context.setStrokeColor(UIColor.black.cgColor)
        
        // Set line width based on eyelash thickness
        let thickness = eyelashModel.thickness.minThickness + 
                       (eyelashModel.thickness.maxThickness - eyelashModel.thickness.minThickness) / 2
        context.setLineWidth(CGFloat(thickness * 2)) // Scale for visibility
        
        // Set line cap for nicer endings
        context.setLineCap(.round)
    }
    
    // Draw a single eyelash at the specified position
    private func drawSingleEyelash(at position: CGPoint, 
                                  index: Int, 
                                  totalLashes: Int, 
                                  context: CGContext, 
                                  eyelashModel: EyelashModel, 
                                  eyePosition: EyePosition) {
        
        // Calculate normalized position (0 to 1) from left to right
        let normalizedPosition = CGFloat(index) / CGFloat(totalLashes - 1)
        
        // Determine lash length based on eyelash model and position
        let length = calculateLashLength(normalizedPosition: normalizedPosition, 
                                         eyelashModel: eyelashModel, 
                                         eyePosition: eyePosition)
        
        // Determine lash angle and curvature
        let angle = calculateLashAngle(normalizedPosition: normalizedPosition, 
                                       eyePosition: eyePosition)
        let curlFactor = eyelashModel.curl.curlFactor
        
        // Start drawing path
        context.beginPath()
        context.move(to: position)
        
        // Calculate end point for a straight lash
        var endX = position.x + sin(angle) * length
        var endY = position.y - cos(angle) * length
        
        // For curved lashes, we'll use a quadratic curve
        if curlFactor > 0.1 {
            // Draw a curved lash
            let controlPointDistance = length * CGFloat(curlFactor)
            let controlX = position.x + sin(angle + .pi / 8) * controlPointDistance * 0.7
            let controlY = position.y - cos(angle + .pi / 8) * controlPointDistance * 0.7
            
            context.addQuadCurve(to: CGPoint(x: endX, y: endY), 
                               control: CGPoint(x: controlX, y: controlY))
        } else {
            // Draw a straight lash
            context.addLine(to: CGPoint(x: endX, y: endY))
        }
        
        // Stroke the path
        context.strokePath()
    }
    
    // Calculate the length of an eyelash based on position and model
    private func calculateLashLength(normalizedPosition: CGFloat, 
                                    eyelashModel: EyelashModel, 
                                    eyePosition: EyePosition) -> CGFloat {
        
        // Get base length from eyelash model
        let minLength = CGFloat(eyelashModel.length.minLength)
        let maxLength = CGFloat(eyelashModel.length.maxLength)
        var length: CGFloat = 0
        
        // Check if there's a specific pattern type
        if let patternType = eyelashModel.customParameters?["patternType"] as? String {
            switch patternType {
            case "catEye":
                // Cat eye: shorter in middle, longer at edges (especially outer)
                if eyePosition == .left {
                    // Left eye: longer on right side
                    length = minLength + (maxLength - minLength) * normalizedPosition * 1.2
                } else {
                    // Right eye: longer on left side
                    length = minLength + (maxLength - minLength) * (1 - normalizedPosition) * 1.2
                }
                
            case "dollEye":
                // Doll eye: longer in middle, shorter at edges
                let middleFactor = 1 - abs(normalizedPosition - 0.5) * 2
                length = minLength + (maxLength - minLength) * middleFactor
                
            case "wispy":
                // Wispy: varied lengths in a somewhat random but pleasing pattern
                let oscillation = sin(normalizedPosition * .pi * 4)
                let randomFactor = CGFloat(0.3 + (abs(oscillation) * 0.7))
                length = minLength + (maxLength - minLength) * randomFactor
                
            default:
                // Default uniform length
                length = minLength + (maxLength - minLength) * 0.5
            }
        } else if eyelashModel.length == .mixed {
            // Mixed lengths - create a pattern when specific pattern not specified
            let oscillation = sin(normalizedPosition * .pi * 2)
            length = minLength + (maxLength - minLength) * (0.4 + abs(oscillation) * 0.6)
        } else {
            // Use average length from model
            length = minLength + (maxLength - minLength) * 0.5
        }
        
        return length
    }
    
    // Calculate the angle for an eyelash based on position
    private func calculateLashAngle(normalizedPosition: CGFloat, eyePosition: EyePosition) -> CGFloat {
        // Base angle pointing upward
        let baseAngle: CGFloat = -.pi / 2 // -90 degrees (straight up)
        
        // Adjust angle based on position (fan out from center)
        let positionFactor = normalizedPosition - 0.5 // -0.5 to 0.5
        
        // Apply more angle variation at the edges
        var angleVariation = positionFactor * .pi / 3 // Max ±60 degree variation
        
        // For more natural look, angle more outward at outer corners
        if (eyePosition == .left && normalizedPosition < 0.3) || 
           (eyePosition == .right && normalizedPosition > 0.7) {
            // Strengthen outward angle at outer corners
            angleVariation *= 1.5
        }
        
        // Apply opposite angle adjustments for left vs right eye
        if eyePosition == .right {
            angleVariation *= -1
        }
        
        return baseAngle + angleVariation
    }
}