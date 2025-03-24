import UIKit
import AVFoundation

class CameraView: UIView {
    
    // Callback for when image is captured
    var onImageCaptured: ((UIImage) -> Void)?
    
    // Camera capture session
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let photoOutput = AVCapturePhotoOutput()
    
    // UI elements
    private let captureButton = UIButton()
    private let switchCameraButton = UIButton()
    private let flashButton = UIButton()
    private let galleryButton = UIButton()
    
    // Camera position
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // Flash mode
    private var currentFlashMode: AVCaptureDevice.FlashMode = .auto
    
    // Camera setup state
    private var isCameraSetup = false
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update video preview layer frame when view layout changes
        videoPreviewLayer?.frame = self.layer.bounds
        
        // If camera is not set up yet, try to set it up now
        // This ensures the view has a valid size before setting up camera
        if !isCameraSetup && !bounds.isEmpty {
            setupCamera()
        }
    }
    
    // Called when the view becomes visible
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        // If view is visible and camera isn't set up, set it up
        if window != nil && !isCameraSetup && !bounds.isEmpty {
            setupCamera()
        }
    }
    
    // Called when view becomes visible or hidden
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview != nil {
            // View was added to a superview
            if !isCameraSetup && !bounds.isEmpty {
                setupCamera()
            }
            
            // Start the camera if it's already set up but not running
            if isCameraSetup && !(captureSession?.isRunning ?? false) {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.captureSession?.startRunning()
                }
            }
        } else {
            // View was removed from superview
            stopCamera()
        }
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        backgroundColor = .black
        
        // Add UI elements
        setupCaptureButton()
        setupSwitchCameraButton()
        setupFlashButton()
        setupGalleryButton()
    }
    
    private func setupCaptureButton() {
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 35
        captureButton.layer.borderWidth = 5
        captureButton.layer.borderColor = UIColor.lightGray.cgColor
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        addSubview(captureButton)
        
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupSwitchCameraButton() {
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        switchCameraButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        switchCameraButton.tintColor = .white
        switchCameraButton.contentVerticalAlignment = .fill
        switchCameraButton.contentHorizontalAlignment = .fill
        switchCameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        
        addSubview(switchCameraButton)
        
        NSLayoutConstraint.activate([
            switchCameraButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            switchCameraButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            switchCameraButton.widthAnchor.constraint(equalToConstant: 30),
            switchCameraButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupFlashButton() {
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        updateFlashButtonIcon()
        flashButton.tintColor = .white
        flashButton.contentVerticalAlignment = .fill
        flashButton.contentHorizontalAlignment = .fill
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        
        addSubview(flashButton)
        
        NSLayoutConstraint.activate([
            flashButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            flashButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            flashButton.widthAnchor.constraint(equalToConstant: 30),
            flashButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupGalleryButton() {
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        galleryButton.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        galleryButton.tintColor = .white
        galleryButton.contentVerticalAlignment = .fill
        galleryButton.contentHorizontalAlignment = .fill
        galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        
        addSubview(galleryButton)
        
        NSLayoutConstraint.activate([
            galleryButton.leadingAnchor.constraint(equalTo: captureButton.trailingAnchor, constant: 30),
            galleryButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            galleryButton.widthAnchor.constraint(equalToConstant: 30),
            galleryButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() {
        // Check if we have camera access
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthStatus {
        case .authorized:
            configureCaptureSession()
            
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                
                DispatchQueue.main.async {
                    self?.configureCaptureSession()
                }
            }
            
        default:
            // Not authorized, show a message
            showCameraAccessNeeded()
        }
    }
    
    private func configureCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Create a new capture session
            let captureSession = AVCaptureSession()
            
            // Begin configuration
            captureSession.beginConfiguration()
            
            // Set session preset
            if captureSession.canSetSessionPreset(.photo) {
                captureSession.sessionPreset = .photo
            } else {
                captureSession.sessionPreset = .high
            }
            
            // Get camera device
            guard let camera = self.getCameraDevice(for: self.currentCameraPosition) else {
                DispatchQueue.main.async {
                    self.showCameraError()
                }
                return
            }
            
            // Add camera input to session
            do {
                let cameraInput = try AVCaptureDeviceInput(device: camera)
                
                if captureSession.canAddInput(cameraInput) {
                    captureSession.addInput(cameraInput)
                } else {
                    DispatchQueue.main.async {
                        self.showCameraError()
                    }
                    return
                }
            } catch {
                print("Error creating camera input: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showCameraError()
                }
                return
            }
            
            // Add photo output to session
            if captureSession.canAddOutput(self.photoOutput) {
                captureSession.addOutput(self.photoOutput)
                
                // Configure photo output
                self.photoOutput.isHighResolutionCaptureEnabled = true
                
                // Check if video stabilization is available
                if let connection = self.photoOutput.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                    
                    // Verify connection is active
                    if !connection.isActive {
                        print("Warning: Video connection is not active")
                    }
                } else {
                    print("Warning: Could not get video connection")
                }
                
                // Enable portrait effects if available
                if self.photoOutput.isPortraitEffectsMatteDeliverySupported {
                    self.photoOutput.isPortraitEffectsMatteDeliveryEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.showCameraError()
                }
                return
            }
            
            // Commit configuration
            captureSession.commitConfiguration()
            
            DispatchQueue.main.async {
                // Create video preview layer
                let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer.videoGravity = .resizeAspectFill
                videoPreviewLayer.frame = self.layer.bounds
                self.layer.insertSublayer(videoPreviewLayer, at: 0)
                
                // Store session and layer
                self.captureSession = captureSession
                self.videoPreviewLayer = videoPreviewLayer
                
                // Start capture session on a background thread to prevent UI blocking
                DispatchQueue.global(qos: .userInitiated).async {
                    captureSession.startRunning()
                    
                    DispatchQueue.main.async {
                        self.isCameraSetup = true
                        print("Camera setup complete and running")
                    }
                }
            }
        }
    }
    
    private func getCameraDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: position) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            return device
        } else {
            return nil
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func capturePhoto() {
        // Make sure camera session is running
        if captureSession?.isRunning != true {
            // If not running, try to start it
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
                
                // Wait a moment for camera to initialize
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.takePicture()
                }
            }
            return
        }
        
        takePicture()
    }
    
    private func takePicture() {
        // Check for active video connection
        guard let videoConnection = photoOutput.connection(with: .video), 
              videoConnection.isEnabled, videoConnection.isActive else {
            print("Error: No active video connection available")
            
            // Show error to user
            let errorLabel = UILabel()
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            errorLabel.text = "Camera not ready. Please try again."
            errorLabel.textColor = .white
            errorLabel.textAlignment = .center
            errorLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            errorLabel.layer.cornerRadius = 8
            errorLabel.layer.masksToBounds = true
            errorLabel.alpha = 0
            
            addSubview(errorLabel)
            
            NSLayoutConstraint.activate([
                errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                errorLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
                errorLabel.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            UIView.animate(withDuration: 0.3, animations: {
                errorLabel.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                    errorLabel.alpha = 0
                }, completion: { _ in
                    errorLabel.removeFromSuperview()
                })
            })
            
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = currentFlashMode
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func switchCamera() {
        // Update camera position
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        // Stop current session
        captureSession?.stopRunning()
        
        // Remove previous inputs
        if let inputs = captureSession?.inputs {
            for input in inputs {
                captureSession?.removeInput(input)
            }
        }
        
        // Reconfigure with new camera
        configureCaptureSession()
    }
    
    @objc private func toggleFlash() {
        switch currentFlashMode {
        case .auto:
            currentFlashMode = .on
        case .on:
            currentFlashMode = .off
        case .off:
            currentFlashMode = .auto
        @unknown default:
            currentFlashMode = .auto
        }
        
        updateFlashButtonIcon()
    }
    
    private func updateFlashButtonIcon() {
        let iconName: String
        
        switch currentFlashMode {
        case .auto:
            iconName = "bolt.badge.a"
        case .on:
            iconName = "bolt"
        case .off:
            iconName = "bolt.slash"
        @unknown default:
            iconName = "bolt.badge.a"
        }
        
        flashButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
    
    @objc private func openGallery() {
        // Notify parent to open photo gallery
        let imagePicker = ImagePicker()
        
        // Find view controller
        if let viewController = getParentViewController() {
            imagePicker.present(from: viewController, sourceType: .photoLibrary) { [weak self] image in
                if let image = image {
                    self?.onImageCaptured?(image)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func showCameraError() {
        let errorLabel = UILabel()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = "Camera not available"
        errorLabel.textColor = .white
        errorLabel.textAlignment = .center
        
        addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -40)
        ])
    }
    
    private func showCameraAccessNeeded() {
        let accessLabel = UILabel()
        accessLabel.translatesAutoresizingMaskIntoConstraints = false
        accessLabel.text = "Camera access required. Please enable in Settings."
        accessLabel.textColor = .white
        accessLabel.textAlignment = .center
        accessLabel.numberOfLines = 0
        
        let settingsButton = UIButton(type: .system)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setTitle("Open Settings", for: .normal)
        settingsButton.tintColor = .white
        settingsButton.backgroundColor = .systemBlue
        settingsButton.layer.cornerRadius = 8
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        addSubview(accessLabel)
        addSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            accessLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            accessLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            accessLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -40),
            
            settingsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            settingsButton.topAnchor.constraint(equalTo: accessLabel.bottomAnchor, constant: 20),
            settingsButton.widthAnchor.constraint(equalToConstant: 150),
            settingsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    // Helper method to find parent view controller
    private func getParentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    // Method to stop the camera
    private func stopCamera() {
        // Stop capture session
        if captureSession?.isRunning ?? false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.stopRunning()
            }
        }
    }
    
    // Clean up when view is removed
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        // Stop and clean up camera resources
        stopCamera()
        captureSession = nil
        
        // Remove video preview layer
        videoPreviewLayer?.removeFromSuperlayer()
        videoPreviewLayer = nil
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        // Get the image data and create UIImage
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        // Call the callback with the captured image
        onImageCaptured?(image)
    }
}