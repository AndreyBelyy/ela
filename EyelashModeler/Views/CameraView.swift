import UIKit
import AVFoundation

protocol CameraViewDelegate: AnyObject {
    func cameraView(_ view: CameraView, didCaptureImage image: UIImage)
    func cameraView(_ view: CameraView, didSelectImage image: UIImage)
}

class CameraView: UIViewController {
    
    weak var delegate: CameraViewDelegate?
    
    // Camera session properties
    private var captureSession: AVCaptureSession?
    private var stillImageOutput: AVCapturePhotoOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // Image picker for selecting photos from library
    private let imagePicker = ImagePicker()
    
    // UI components
    private let cameraPreviewView = UIView()
    private let takePictureButton = UIButton()
    private let selectPhotoButton = UIButton()
    private let switchCameraButton = UIButton()
    
    // Flags
    private var isFrontCameraActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCamera()
        setupImagePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start the camera when the view appears
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop the camera when the view disappears
        captureSession?.stopRunning()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Camera preview view
        cameraPreviewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraPreviewView)
        
        // Take picture button
        takePictureButton.translatesAutoresizingMaskIntoConstraints = false
        takePictureButton.setTitle("Take Photo", for: .normal)
        takePictureButton.setTitleColor(.white, for: .normal)
        takePictureButton.backgroundColor = .systemBlue
        takePictureButton.layer.cornerRadius = 25
        takePictureButton.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        view.addSubview(takePictureButton)
        
        // Select photo button
        selectPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        selectPhotoButton.setTitle("Select Photo", for: .normal)
        selectPhotoButton.setTitleColor(.white, for: .normal)
        selectPhotoButton.backgroundColor = .systemGreen
        selectPhotoButton.layer.cornerRadius = 25
        selectPhotoButton.addTarget(self, action: #selector(selectPhoto), for: .touchUpInside)
        view.addSubview(selectPhotoButton)
        
        // Switch camera button
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        switchCameraButton.setTitle("Switch", for: .normal)
        switchCameraButton.setTitleColor(.white, for: .normal)
        switchCameraButton.backgroundColor = .systemGray
        switchCameraButton.layer.cornerRadius = 20
        switchCameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        view.addSubview(switchCameraButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            cameraPreviewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cameraPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraPreviewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            
            takePictureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takePictureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            takePictureButton.widthAnchor.constraint(equalToConstant: 150),
            takePictureButton.heightAnchor.constraint(equalToConstant: 50),
            
            selectPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectPhotoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            selectPhotoButton.widthAnchor.constraint(equalToConstant: 120),
            selectPhotoButton.heightAnchor.constraint(equalToConstant: 50),
            
            switchCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            switchCameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            switchCameraButton.widthAnchor.constraint(equalToConstant: 80),
            switchCameraButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCamera() {
        // Initialize the capture session
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        // Get the back camera
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera")
            return
        }
        
        do {
            // Create input from the camera
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            // Add input to the session
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
            
            // Configure photo output
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession?.canAddOutput(stillImageOutput!) == true {
                captureSession?.addOutput(stillImageOutput!)
                
                // Set up the preview layer
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                videoPreviewLayer?.connection?.videoOrientation = .portrait
                videoPreviewLayer?.frame = cameraPreviewView.bounds
                
                if let previewLayer = videoPreviewLayer {
                    cameraPreviewView.layer.addSublayer(previewLayer)
                }
                
                // Start the session
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.captureSession?.startRunning()
                }
            }
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
    }
    
    @objc private func takePicture() {
        // Configure the photo settings
        let settings = AVCapturePhotoSettings()
        
        // Capture the photo
        stillImageOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func selectPhoto() {
        // Present the image picker
        imagePicker.present(from: self)
    }
    
    @objc private func switchCamera() {
        // Remove existing inputs
        captureSession?.beginConfiguration()
        
        if let inputs = captureSession?.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession?.removeInput(input)
            }
        }
        
        // Get the new camera (front or back)
        let position: AVCaptureDevice.Position = isFrontCameraActive ? .back : .front
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            print("Unable to access camera")
            return
        }
        
        do {
            // Create and add the new input
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
            
            // Toggle the flag
            isFrontCameraActive.toggle()
            
            // Update the video orientation
            if let connection = videoPreviewLayer?.connection {
                connection.videoOrientation = .portrait
            }
            
            captureSession?.commitConfiguration()
        } catch {
            print("Error switching camera: \(error.localizedDescription)")
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        // Get the image data and create a UIImage
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Unable to create image from photo data")
            return
        }
        
        // Notify the delegate
        delegate?.cameraView(self, didCaptureImage: image)
    }
}

// MARK: - ImagePickerDelegate
extension CameraView: ImagePickerDelegate {
    func imagePicker(_ picker: ImagePicker, didSelectImage image: UIImage) {
        // Notify the delegate
        delegate?.cameraView(self, didSelectImage: image)
    }
}
