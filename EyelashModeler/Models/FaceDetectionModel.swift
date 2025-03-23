import UIKit
import Vision

struct FaceDetectionModel {
    var faceRect: CGRect
    var leftEye: EyeData?
    var rightEye: EyeData?
    var faceContour: [CGPoint]?
    var landmarks: VNFaceLandmarks2D?
    
    init(faceRect: CGRect, 
         leftEye: EyeData? = nil, 
         rightEye: EyeData? = nil, 
         faceContour: [CGPoint]? = nil,
         landmarks: VNFaceLandmarks2D? = nil) {
        
        self.faceRect = faceRect
        self.leftEye = leftEye
        self.rightEye = rightEye
        self.faceContour = faceContour
        self.landmarks = landmarks
    }
    
    // Convenience method to check if both eyes were detected
    var hasEyesDetected: Bool {
        return leftEye != nil && rightEye != nil
    }
    
    // Method to get the transformed eyelash positions for a specific eye
    func getEyelashPositions(for eye: EyePosition, withSize size: CGSize) -> [CGPoint] {
        let eyeData = eye == .left ? leftEye : rightEye
        guard let eyeData = eyeData else { return [] }
        
        // Use the eye data to properly position the eyelashes
        // This would include the curvature of the eyelid and factors like length and curl
        
        // For now, generate sample points along the upper eyelid
        let numberOfLashes = 15
        var points: [CGPoint] = []
        
        for i in 0..<numberOfLashes {
            let progress = CGFloat(i) / CGFloat(numberOfLashes - 1)
            let x = eyeData.center.x - (eyeData.width / 2) + (eyeData.width * progress)
            
            // Create a curve for the upper eyelid position
            // Use a parabola-like curve to mimic the eyelid shape
            let normalizedX = (progress * 2) - 1 // Range from -1 to 1
            let curve = -0.5 * (normalizedX * normalizedX) + 0.5 // Parabola, peak at center
            
            let y = eyeData.center.y - (eyeData.height * 0.4) - (curve * eyeData.height * 0.2)
            
            points.append(CGPoint(x: x, y: y))
        }
        
        return points
    }
}

// Eye position enum
enum EyePosition {
    case left
    case right
}

// Structure to hold detailed eye information
struct EyeData {
    var center: CGPoint
    var width: CGFloat
    var height: CGFloat
    var openness: CGFloat // 0.0 to 1.0
    var upperEyelid: [CGPoint]?
    var lowerEyelid: [CGPoint]?
    
    init(center: CGPoint, 
         width: CGFloat, 
         height: CGFloat, 
         openness: CGFloat = 1.0,
         upperEyelid: [CGPoint]? = nil,
         lowerEyelid: [CGPoint]? = nil) {
        
        self.center = center
        self.width = width
        self.height = height
        self.openness = openness
        self.upperEyelid = upperEyelid
        self.lowerEyelid = lowerEyelid
    }
    
    // Convenience method to get the eye rect
    var rect: CGRect {
        return CGRect(
            x: center.x - (width / 2),
            y: center.y - (height / 2),
            width: width,
            height: height
        )
    }
}