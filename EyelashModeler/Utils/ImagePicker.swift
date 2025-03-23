import UIKit
import Photos

class ImagePicker: NSObject {
    
    // Callback typealias for image selection and cancellation
    typealias ImagePickerCompletion = (UIImage?) -> Void
    
    // Image picker controller
    private let pickerController = UIImagePickerController()
    
    // Reference to presenting view controller
    private weak var presentationController: UIViewController?
    
    // Completion handler to call when image is selected or picker is cancelled
    private var completion: ImagePickerCompletion?
    
    override init() {
        super.init()
        
        // Configure image picker
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
    }
    
    // Present the image picker from a view controller
    func present(from viewController: UIViewController, sourceType: UIImagePickerController.SourceType = .camera, completion: @escaping ImagePickerCompletion) {
        // Store references for later use
        self.presentationController = viewController
        self.completion = completion
        
        // Check if the source type is available
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            print("Source type \(sourceType) is not available")
            completion(nil)
            return
        }
        
        // For camera source, check and request camera permissions
        if sourceType == .camera {
            checkCameraPermissions { [weak self] granted in
                guard let self = self, granted else {
                    completion(nil)
                    return
                }
                
                self.presentImagePicker(sourceType: sourceType)
            }
        } 
        // For photo library, check and request photo library permissions
        else if sourceType == .photoLibrary {
            checkPhotoLibraryPermissions { [weak self] granted in
                guard let self = self, granted else {
                    completion(nil)
                    return
                }
                
                self.presentImagePicker(sourceType: sourceType)
            }
        } 
        // For other sources, just present the picker
        else {
            presentImagePicker(sourceType: sourceType)
        }
    }
    
    // Present the picker with the specified source type
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        pickerController.sourceType = sourceType
        presentationController?.present(pickerController, animated: true)
    }
    
    // Check camera permissions and request if needed
    private func checkCameraPermissions(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completion(true)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
            
        default:
            showPermissionAlert(for: "Camera")
            completion(false)
        }
    }
    
    // Check photo library permissions and request if needed
    private func checkPhotoLibraryPermissions(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            completion(true)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
            
        default:
            showPermissionAlert(for: "Photo Library")
            completion(false)
        }
    }
    
    // Show an alert when permissions are denied
    private func showPermissionAlert(for resource: String) {
        let alert = UIAlertController(
            title: "\(resource) Access Required",
            message: "Please enable access to your \(resource.lowercased()) in Settings to use this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        presentationController?.present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Called when user has picked an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Dismiss the picker
        picker.dismiss(animated: true)
        
        // Extract the edited image if available, otherwise use the original image
        let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        
        // Call the completion handler with the selected image
        completion?(image)
    }
    
    // Called when user has cancelled the picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker
        picker.dismiss(animated: true)
        
        // Call the completion handler with nil to indicate cancellation
        completion?(nil)
    }
}