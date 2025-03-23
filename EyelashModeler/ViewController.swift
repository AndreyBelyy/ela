import UIKit
import Vision
import ARKit

class ViewController: UIViewController {
    
    // Navigation controller to manage the app flow
    private var navController: UINavigationController?
    
    // Current image being edited
    private var currentImage: UIImage?
    
    // Current detected face landmarks
    private var faceLandmarks: VNFaceObservation?
    
    // FaceDetector utility to detect facial landmarks
    private let faceDetector = FaceDetector()
    
    // EyelashRenderer to apply eyelash models onto images
    private let eyelashRenderer = EyelashRenderer()
    
    // View for the camera and photo selection
    private let cameraView = CameraView()
    
    // View for the eyelash library
    private let libraryView = EyelashLibraryView()
    
    // View for editing the eyelashes on the image
    private let editorView = EditorView()
    
    // Current selected eyelash model
    private var selectedEyelashModel: EyelashModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDelegates()
    }
    
    private func setupUI() {
        // Set up the navigation bar
        title = "Eyelash Modeler"
        
        // Add the camera view as a child view controller
        addChild(cameraView)
        view.addSubview(cameraView.view)
        cameraView.view.frame = view.bounds
        cameraView.didMove(toParent: self)
        
        // Navigation buttons for moving between views
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Library", 
            style: .plain, 
            target: self, 
            action: #selector(showLibrary)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back", 
            style: .plain, 
            target: self, 
            action: #selector(goBack)
        )
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    private func setupDelegates() {
        // Set up delegate for camera view to handle image selection
        cameraView.delegate = self
        
        // Set up delegate for library view to handle eyelash selection
        libraryView.delegate = self
        
        // Set up delegate for editor view to handle editing completion
        editorView.delegate = self
    }
    
    @objc private func showLibrary() {
        guard currentImage != nil else {
            showAlert(message: "Please take or select a photo first")
            return
        }
        
        // Remove current child view controller
        if let childVC = children.first {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        
        // Add the library view
        addChild(libraryView)
        view.addSubview(libraryView.view)
        libraryView.view.frame = view.bounds
        libraryView.didMove(toParent: self)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Apply", 
            style: .plain, 
            target: self, 
            action: #selector(applySelectedEyelash)
        )
        navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    @objc private func applySelectedEyelash() {
        guard let eyelashModel = selectedEyelashModel, let image = currentImage, let faceLandmarks = faceLandmarks else {
            showAlert(message: "Please select a photo and eyelash style first")
            return
        }
        
        // Remove current child view controller
        if let childVC = children.first {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        
        // Add the editor view
        addChild(editorView)
        view.addSubview(editorView.view)
        editorView.view.frame = view.bounds
        editorView.didMove(toParent: self)
        
        // Apply the eyelash model to the image
        eyelashRenderer.renderEyelashes(on: image, with: faceLandmarks, using: eyelashModel) { [weak self] renderedImage in
            guard let self = self, let renderedImage = renderedImage else {
                self?.showAlert(message: "Failed to apply eyelashes. Please try again.")
                return
            }
            
            // Display the rendered image in the editor view
            self.editorView.setImage(renderedImage, with: eyelashModel)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", 
            style: .plain, 
            target: self, 
            action: #selector(saveImage)
        )
    }
    
    @objc private func goBack() {
        // Remove current child view controller
        if let childVC = children.first {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        
        // If we're in the editor, go back to the library
        if children.first is EditorView {
            addChild(libraryView)
            view.addSubview(libraryView.view)
            libraryView.view.frame = view.bounds
            libraryView.didMove(toParent: self)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Apply", 
                style: .plain, 
                target: self, 
                action: #selector(applySelectedEyelash)
            )
        } else {
            // Otherwise go back to the camera view
            addChild(cameraView)
            view.addSubview(cameraView.view)
            cameraView.view.frame = view.bounds
            cameraView.didMove(toParent: self)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Library", 
                style: .plain, 
                target: self, 
                action: #selector(showLibrary)
            )
            navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }
    
    @objc private func saveImage() {
        guard let finalImage = editorView.getFinalImage() else {
            showAlert(message: "Failed to save the image. Please try again.")
            return
        }
        
        // Save the image to the photo library
        UIImageWriteToSavedPhotosAlbum(finalImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(message: "Failed to save: \(error.localizedDescription)")
        } else {
            showAlert(message: "Image saved successfully!")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Eyelash Modeler", 
            message: message, 
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func processImage(_ image: UIImage) {
        // Detect faces in the image
        faceDetector.detectFace(in: image) { [weak self] result in
            switch result {
            case .success(let observation):
                self?.faceLandmarks = observation
                self?.currentImage = image
                self?.showLibrary()
            case .failure(let error):
                self?.showAlert(message: "Face detection failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - CameraViewDelegate
extension ViewController: CameraViewDelegate {
    func cameraView(_ view: CameraView, didCaptureImage image: UIImage) {
        processImage(image)
    }
    
    func cameraView(_ view: CameraView, didSelectImage image: UIImage) {
        processImage(image)
    }
}

// MARK: - EyelashLibraryViewDelegate
extension ViewController: EyelashLibraryViewDelegate {
    func libraryView(_ view: EyelashLibraryView, didSelectEyelash eyelashModel: EyelashModel) {
        selectedEyelashModel = eyelashModel
    }
}

// MARK: - EditorViewDelegate
extension ViewController: EditorViewDelegate {
    func editorView(_ view: EditorView, didFinishEditing image: UIImage) {
        // This method will be called when the user finishes editing
        // We could add additional behavior here if needed
    }
}
