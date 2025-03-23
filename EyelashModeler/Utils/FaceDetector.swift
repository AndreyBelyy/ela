import UIKit
import Vision

enum FaceDetectionError: Error {
    case detectionFailed
    case noFaceDetected
    case imageConversionFailed
}

class FaceDetector {
    // Detect faces in the given image
    func detectFace(in image: UIImage, completion: @escaping (Result<VNFaceObservation, FaceDetectionError>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(.imageConversionFailed))
            return
        }
        
        // Create a face detection request
        let request = VNDetectFaceLandmarksRequest { request, error in
            if let error = error {
                print("Face detection failed: \(error.localizedDescription)")
                completion(.failure(.detectionFailed))
                return
            }
            
            // Get the face observations
            guard let observations = request.results as? [VNFaceObservation], !observations.isEmpty else {
                completion(.failure(.noFaceDetected))
                return
            }
            
            // Get the first detected face (we assume there's only one face in the image)
            guard let face = observations.first else {
                completion(.failure(.noFaceDetected))
                return
            }
            
            // Check if we have landmarks (eyes, eyebrows, etc.)
            guard face.landmarks != nil else {
                completion(.failure(.noFaceDetected))
                return
            }
            
            // Return the face observation
            completion(.success(face))
        }
        
        // Create a request handler
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: imageOrientationToVNImageOrientation(image.imageOrientation))
        
        // Perform the request
        do {
            try handler.perform([request])
        } catch {
            print("Face detection request failed: \(error.localizedDescription)")
            completion(.failure(.detectionFailed))
        }
    }
    
    // Convert UIImage orientation to VNImageOrientation
    private func imageOrientationToVNImageOrientation(_ orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .upMirrored:
            return .upMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        @unknown default:
            return .up
        }
    }
}
