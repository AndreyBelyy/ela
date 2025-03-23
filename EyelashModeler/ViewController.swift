import UIKit

class ViewController: UIViewController {
    
    private var cameraView: CameraView?
    private var eyelashLibraryView: EyelashLibraryView?
    private var editorView: EditorView?
    private var previewView: EyelashPreviewView?
    
    private var currentSelectedEyelash: EyelashModel?
    private var imagePicker = ImagePicker()
    private let faceDetector = FaceDetector()
    private let eyelashRenderer = EyelashRenderer()
    
    // UI Elements
    private let cameraButton = UIButton()
    private let libraryButton = UIButton()
    private let previewButton = UIButton()
    private let editButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCameraView()
        setupLibraryView()
        setupEditorView()
        setupPreviewView()
        
        // Initially show camera view
        showCameraView()
    }
    
    private func setupUI() {
        title = "Eyelash Modeler"
        view.backgroundColor = .white
        
        // Setup UI elements like buttons, navigation, etc.
        setupButtons()
    }
    
    private func setupButtons() {
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 10
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure buttons
        configureButton(cameraButton, title: "Camera", action: #selector(showCameraView))
        configureButton(libraryButton, title: "Styles", action: #selector(showLibraryView))
        configureButton(editButton, title: "Edit", action: #selector(showEditorView))
        configureButton(previewButton, title: "Preview", action: #selector(showPreviewView))
        
        // Add buttons to stack
        buttonStack.addArrangedSubview(cameraButton)
        buttonStack.addArrangedSubview(libraryButton)
        buttonStack.addArrangedSubview(editButton)
        buttonStack.addArrangedSubview(previewButton)
        
        // Add stack to view
        view.addSubview(buttonStack)
        
        // Set constraints
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: action, for: .touchUpInside)
    }
    
    private func setupCameraView() {
        cameraView = CameraView(frame: getContentFrame())
        cameraView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let cameraView = cameraView {
            view.addSubview(cameraView)
            cameraView.isHidden = true
            
            // Set camera view callbacks
            cameraView.onImageCaptured = { [weak self] image in
                // Process the captured image for face detection
                self?.processImageForFaceDetection(image)
            }
        }
    }
    
    private func setupLibraryView() {
        eyelashLibraryView = EyelashLibraryView()
        
        if let libraryView = eyelashLibraryView {
            // Add as a child view controller
            addChild(libraryView)
            view.addSubview(libraryView.view)
            libraryView.view.frame = getContentFrame()
            libraryView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            libraryView.didMove(toParent: self)
            libraryView.view.isHidden = true
            
            // Set library view delegate
            libraryView.delegate = self
        }
    }
    
    private func setupEditorView() {
        editorView = EditorView()
        
        if let editorView = editorView {
            // Add as a child view controller
            addChild(editorView)
            view.addSubview(editorView.view)
            editorView.view.frame = getContentFrame()
            editorView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            editorView.didMove(toParent: self)
            editorView.view.isHidden = true
        }
    }
    
    private func setupPreviewView() {
        previewView = EyelashPreviewView()
        
        if let previewView = previewView {
            // Add as a child view controller
            addChild(previewView)
            view.addSubview(previewView.view)
            previewView.view.frame = getContentFrame()
            previewView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            previewView.didMove(toParent: self)
            previewView.view.isHidden = true
        }
    }
    
    private func getContentFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 80)
    }
    
    @objc private func showCameraView() {
        hideAllViews()
        cameraView?.isHidden = false
        cameraButton.backgroundColor = .systemGreen
    }
    
    @objc private func showLibraryView() {
        hideAllViews()
        eyelashLibraryView?.view.isHidden = false
        libraryButton.backgroundColor = .systemGreen
    }
    
    @objc private func showEditorView() {
        hideAllViews()
        editorView?.view.isHidden = false
        editButton.backgroundColor = .systemGreen
        
        // Update the editor with the current eyelash model if available
        if let eyelashModel = currentSelectedEyelash, let editorView = editorView {
            editorView.setEyelashModel(eyelashModel)
        }
    }
    
    @objc private func showPreviewView() {
        hideAllViews()
        previewView?.view.isHidden = false
        previewButton.backgroundColor = .systemGreen
        
        // Update the preview with the current eyelash model and latest face data
        if let eyelashModel = currentSelectedEyelash, let previewView = previewView {
            previewView.setEyelashModel(eyelashModel)
        }
    }
    
    private func hideAllViews() {
        cameraView?.isHidden = true
        eyelashLibraryView?.view.isHidden = true
        editorView?.view.isHidden = true
        previewView?.view.isHidden = true
        
        // Reset button colors
        cameraButton.backgroundColor = .systemBlue
        libraryButton.backgroundColor = .systemBlue
        editButton.backgroundColor = .systemBlue
        previewButton.backgroundColor = .systemBlue
    }
    
    private func processImageForFaceDetection(_ image: UIImage) {
        faceDetector.detectFace(in: image) { [weak self] faceDetectionModel in
            if let model = faceDetectionModel {
                // Face detected, update the UI
                DispatchQueue.main.async {
                    // We need to call our custom method that will be added to the preview controller
                    if let previewView = self?.previewView as? EyelashPreviewView {
                        previewView.updateWithFaceDetection(model: model, image: image)
                        self?.showPreviewView()
                    }
                }
            } else {
                // No face detected, show an alert
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "No Face Detected", 
                                                message: "Please take another photo with a clear view of the face.", 
                                                preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}

// MARK: - EyelashLibraryViewDelegate
extension ViewController: EyelashLibraryViewDelegate {
    func libraryView(_ view: EyelashLibraryView, didSelectEyelash eyelashModel: EyelashModel) {
        currentSelectedEyelash = eyelashModel
        showPreviewView()
    }
}