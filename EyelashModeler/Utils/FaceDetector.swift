import UIKit
import Vision
import AVFoundation

class FaceDetector {
    
    typealias FaceDetectionCompletion = (FaceDetectionModel?) -> Void
    
    // Detect faces in a provided UIImage
    func detectFace(in image: UIImage, completion: @escaping FaceDetectionCompletion) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        // Create a new request to detect faces
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            if let error = error {
                print("Face detection error: \(error)")
                completion(nil)
                return
            }
            
            // Process the results
            if let results = request.results as? [VNFaceObservation], 
               let firstFace = results.first {
                // Extract face data
                let faceDetectionModel = self?.processFaceObservation(firstFace, imageSize: image.size)
                completion(faceDetectionModel)
            } else {
                completion(nil)
            }
        }
        
        // Create request handler
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: self.cgImageOrientation(from: image))
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform face detection: \(error)")
            completion(nil)
        }
    }
    
    // Process VNFaceObservation to extract detailed face and eye information
    private func processFaceObservation(_ observation: VNFaceObservation, imageSize: CGSize) -> FaceDetectionModel {
        // Convert normalized coordinates to image coordinates
        let faceRect = convertToImageRect(observation.boundingBox, imageSize: imageSize)
        
        var leftEyeData: EyeData?
        var rightEyeData: EyeData?
        var faceContour: [CGPoint]?
        
        if let landmarks = observation.landmarks {
            // Extract left eye data
            if let leftEye = landmarks.leftEye {
                leftEyeData = processEyePoints(leftEye.normalizedPoints, 
                                               boundingBox: observation.boundingBox,
                                               imageSize: imageSize)
            }
            
            // Extract right eye data
            if let rightEye = landmarks.rightEye {
                rightEyeData = processEyePoints(rightEye.normalizedPoints, 
                                                boundingBox: observation.boundingBox,
                                                imageSize: imageSize)
            }
            
            // Extract face contour if available
            if let contour = landmarks.faceContour {
                faceContour = convertPointsToImageCoordinates(contour.normalizedPoints,
                                                             boundingBox: observation.boundingBox,
                                                             imageSize: imageSize)
            }
        }
        
        return FaceDetectionModel(
            faceRect: faceRect,
            leftEye: leftEyeData,
            rightEye: rightEyeData,
            faceContour: faceContour,
            landmarks: observation.landmarks
        )
    }
    
    // Process eye points from Vision framework to create EyeData
    private func processEyePoints(_ points: [CGPoint], boundingBox: CGRect, imageSize: CGSize) -> EyeData {
        // Convert normalized points to image coordinates
        let imagePoints = convertPointsToImageCoordinates(points, boundingBox: boundingBox, imageSize: imageSize)
        
        // Calculate eye bounding box
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX = CGFloat.leastNormalMagnitude
        var maxY = CGFloat.leastNormalMagnitude
        
        for point in imagePoints {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }
        
        let width = maxX - minX
        let height = maxY - minY
        let center = CGPoint(x: minX + (width / 2), y: minY + (height / 2))
        
        // Divide the eye points into upper and lower eyelid
        var upperEyelid: [CGPoint] = []
        var lowerEyelid: [CGPoint] = []
        
        if imagePoints.count > 0 {
            // Sort points by x coordinate
            let sortedPoints = imagePoints.sorted { $0.x < $1.x }
            
            // Determine which points belong to upper and lower eyelids
            // This is a simplification - in a real app, we'd use more sophisticated algorithms
            for point in sortedPoints {
                if point.y < center.y {
                    upperEyelid.append(point)
                } else {
                    lowerEyelid.append(point)
                }
            }
        }
        
        // Calculate eye openness (simplified version)
        let openness = height / width  // A simple ratio
        
        return EyeData(
            center: center,
            width: width,
            height: height,
            openness: openness,
            upperEyelid: upperEyelid.isEmpty ? nil : upperEyelid,
            lowerEyelid: lowerEyelid.isEmpty ? nil : lowerEyelid
        )
    }
    
    // Helper method to convert normalized rect to image coordinates
    private func convertToImageRect(_ normalizedRect: CGRect, imageSize: CGSize) -> CGRect {
        let x = normalizedRect.origin.x * imageSize.width
        let y = (1 - normalizedRect.origin.y - normalizedRect.height) * imageSize.height
        let width = normalizedRect.width * imageSize.width
        let height = normalizedRect.height * imageSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // Helper method to convert normalized points to image coordinates
    private func convertPointsToImageCoordinates(_ normalizedPoints: [CGPoint], boundingBox: CGRect, imageSize: CGSize) -> [CGPoint] {
        return normalizedPoints.map { point in
            let x = boundingBox.origin.x * imageSize.width + point.x * boundingBox.width * imageSize.width
            let y = (1 - boundingBox.origin.y) * imageSize.height - point.y * boundingBox.height * imageSize.height
            return CGPoint(x: x, y: y)
        }
    }
    
    // Helper method to get CGImagePropertyOrientation from UIImage
    private func cgImageOrientation(from image: UIImage) -> CGImagePropertyOrientation {
        switch image.imageOrientation {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}