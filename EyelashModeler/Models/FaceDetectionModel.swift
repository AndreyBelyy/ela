import UIKit
import Vision

// Class to store face detection results
class FaceDetectionModel {
    // The detected face
    let faceObservation: VNFaceObservation
    
    // The original image on which detection was performed
    let originalImage: UIImage
    
    // Detected landmarks for the left eye
    var leftEyeLandmarks: VNFaceLandmarkRegion2D? {
        return faceObservation.landmarks?.leftEye
    }
    
    // Detected landmarks for the right eye
    var rightEyeLandmarks: VNFaceLandmarkRegion2D? {
        return faceObservation.landmarks?.rightEye
    }
    
    // Detected landmarks for the left eyebrow
    var leftEyebrowLandmarks: VNFaceLandmarkRegion2D? {
        return faceObservation.landmarks?.leftEyebrow
    }
    
    // Detected landmarks for the right eyebrow
    var rightEyebrowLandmarks: VNFaceLandmarkRegion2D? {
        return faceObservation.landmarks?.rightEyebrow
    }
    
    // The bounding box for the face, normalized to the image size
    var faceBoundingBox: CGRect {
        // Convert the normalized bounding box to image coordinates
        let width = originalImage.size.width
        let height = originalImage.size.height
        
        // Vision's coordinate system has (0,0) at the bottom left
        // UIKit's coordinate system has (0,0) at the top left
        // We need to flip the y-coordinate
        let x = faceObservation.boundingBox.minX * width
        let y = (1 - faceObservation.boundingBox.minY - faceObservation.boundingBox.height) * height
        let w = faceObservation.boundingBox.width * width
        let h = faceObservation.boundingBox.height * height
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    // Initialize with a face observation and the original image
    init(faceObservation: VNFaceObservation, originalImage: UIImage) {
        self.faceObservation = faceObservation
        self.originalImage = originalImage
    }
    
    // Get points for left eye in image coordinates
    func getLeftEyePoints() -> [CGPoint]? {
        guard let landmarks = leftEyeLandmarks?.normalizedPoints else {
            return nil
        }
        
        return convertPointsToImageCoordinates(landmarks)
    }
    
    // Get points for right eye in image coordinates
    func getRightEyePoints() -> [CGPoint]? {
        guard let landmarks = rightEyeLandmarks?.normalizedPoints else {
            return nil
        }
        
        return convertPointsToImageCoordinates(landmarks)
    }
    
    // Convert normalized points to image coordinates
    private func convertPointsToImageCoordinates(_ normalizedPoints: [CGPoint]) -> [CGPoint] {
        let width = originalImage.size.width
        let height = originalImage.size.height
        
        return normalizedPoints.map { point in
            let x = point.x * width
            let y = (1 - point.y) * height
            return CGPoint(x: x, y: y)
        }
    }
    
    // Get the center point of the left eye
    func getLeftEyeCenter() -> CGPoint? {
        guard let points = getLeftEyePoints(), !points.isEmpty else {
            return nil
        }
        
        let xSum = points.reduce(0) { $0 + $1.x }
        let ySum = points.reduce(0) { $0 + $1.y }
        
        return CGPoint(x: xSum / CGFloat(points.count), y: ySum / CGFloat(points.count))
    }
    
    // Get the center point of the right eye
    func getRightEyeCenter() -> CGPoint? {
        guard let points = getRightEyePoints(), !points.isEmpty else {
            return nil
        }
        
        let xSum = points.reduce(0) { $0 + $1.x }
        let ySum = points.reduce(0) { $0 + $1.y }
        
        return CGPoint(x: xSum / CGFloat(points.count), y: ySum / CGFloat(points.count))
    }
    
    // Calculate the average width of the eyes
    func getAverageEyeWidth() -> CGFloat? {
        guard let leftPoints = getLeftEyePoints(), let rightPoints = getRightEyePoints(),
              !leftPoints.isEmpty, !rightPoints.isEmpty else {
            return nil
        }
        
        // Find the width of each eye by getting the min/max x values
        let leftMinX = leftPoints.min { $0.x < $1.x }?.x ?? 0
        let leftMaxX = leftPoints.max { $0.x < $1.x }?.x ?? 0
        let leftWidth = leftMaxX - leftMinX
        
        let rightMinX = rightPoints.min { $0.x < $1.x }?.x ?? 0
        let rightMaxX = rightPoints.max { $0.x < $1.x }?.x ?? 0
        let rightWidth = rightMaxX - rightMinX
        
        return (leftWidth + rightWidth) / 2.0
    }
}
