import UIKit

protocol ImagePickerDelegate: AnyObject {
    func imagePicker(_ picker: ImagePicker, didSelectImage image: UIImage)
}

class ImagePicker: NSObject {
    
    weak var delegate: ImagePickerDelegate?
    private var pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    
    override init() {
        self.pickerController = UIImagePickerController()
        super.init()
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    func present(from viewController: UIViewController) {
        self.presentationController = viewController
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = viewController.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            alertController.popoverPresentationController?.permittedArrowDirections = []
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage) {
        controller.dismiss(animated: true, completion: nil)
        
        delegate?.imagePicker(self, didSelectImage: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: UIImage())
        }
        
        self.pickerController(picker, didSelect: image)
    }
}
