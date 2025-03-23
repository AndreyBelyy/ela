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
        eyelashLibraryView = EyelashLibraryView(frame: getContentFrame())
        eyelashLibraryView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let libraryView = eyelashLibraryView {
            view.addSubview(libraryView)
            libraryView.isHidden = true
            
            // Set library view callbacks
            libraryView.onEyelashSelected = { [weak self] eyelashModel in
                self?.currentSelectedEyelash = eyelashModel
                self?.showPreviewView()
            }
        }
    }
    
    private func setupEditorView() {
        editorView = EditorView(frame: getContentFrame())
        editorView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let editorView = editorView {
            view.addSubview(editorView)
            editorView.isHidden = true
            
            // Set editor view callbacks
            editorView.onEditingComplete = { [weak self] eyelashModel in
                self?.currentSelectedEyelash = eyelashModel
                self?.showPreviewView()
            }
        }
    }
    
    private func setupPreviewView() {
        previewView = EyelashPreviewView(frame: getContentFrame())
        previewView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let previewView = previewView {
            view.addSubview(previewView)
            previewView.isHidden = true
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
        eyelashLibraryView?.isHidden = false
        libraryButton.backgroundColor = .systemGreen
    }
    
    @objc private func showEditorView() {
        hideAllViews()
        editorView?.isHidden = false
        editButton.backgroundColor = .systemGreen
        
        // Update the editor with the current eyelash model if available
        if let eyelashModel = currentSelectedEyelash {
            editorView?.setupWithEyelashModel(eyelashModel)
        }
    }
    
    @objc private func showPreviewView() {
        hideAllViews()
        previewView?.isHidden = false
        previewButton.backgroundColor = .systemGreen
        
        // Update the preview with the current eyelash model and latest face data
        if let eyelashModel = currentSelectedEyelash {
            previewView?.setupWithEyelashModel(eyelashModel)
        }
    }
    
    private func hideAllViews() {
        cameraView?.isHidden = true
        eyelashLibraryView?.isHidden = true
        editorView?.isHidden = true
        previewView?.isHidden = true
        
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
                    self?.previewView?.updateWithFaceDetection(model, image: image)
                    self?.showPreviewView()
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