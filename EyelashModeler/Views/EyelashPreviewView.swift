import UIKit
import ARKit

class EyelashPreviewView: UIViewController {
    
    // AR scene view for live preview
    private let sceneView = ARSCNView()
    
    // Current eyelash model being previewed
    private var currentEyelashModel: EyelashModel?
    
    // UI components
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Position your face in the frame"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupARSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure the AR session
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the AR session
        sceneView.session.pause()
    }
    
    private func setupUI() {
        // Configure the scene view
        sceneView.delegate = self
        sceneView.frame = view.bounds
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(sceneView)
        
        // Add instruction label
        view.addSubview(instructionLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            instructionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            instructionLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupARSession() {
        // Create and configure the face tracking configuration
        guard ARFaceTrackingConfiguration.isSupported else {
            instructionLabel.text = "Face tracking is not supported on this device"
            return
        }
        
        // Add tap gesture to capture a photo
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        // In a real app, this would capture the current frame with the AR eyelash overlay
        instructionLabel.text = "Captured photo with eyelash preview!"
        
        // Simulate a flash effect
        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 0.8
        view.addSubview(flashView)
        
        // Animate flash effect
        UIView.animate(withDuration: 0.3, animations: {
            flashView.alpha = 0
        }) { _ in
            flashView.removeFromSuperview()
        }
    }
    
    func setEyelashModel(_ model: EyelashModel) {
        currentEyelashModel = model
        
        // Update the instruction label
        instructionLabel.text = "Previewing \(model.name) eyelashes"
        
        // Apply the eyelash style to the current image if available
        applyCurrentEyelashStyle()
    }
    
    // Store the current face detection model and original image
    private var currentFaceModel: FaceDetectionModel?
    private var originalImage: UIImage?
    
    // Method to update the view with face detection results
    func updateWithFaceDetection(model: FaceDetectionModel, image: UIImage) {
        // Store the face detection model and image for later use
        currentFaceModel = model
        originalImage = image
        
        // Create an image overlay with the detected face
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = sceneView.bounds
        imageView.tag = 100 // Tag for easy reference
        
        // Remove any existing image overlays
        for subview in sceneView.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
        
        // Add the new image overlay
        sceneView.insertSubview(imageView, at: 0)
        
        // Update the instruction label
        instructionLabel.text = "Face detected! Select an eyelash style to preview"
        
        // Apply current eyelash model if available
        applyCurrentEyelashStyle()
        
        // Add a save button
        addSaveButton()
    }
    
    private func applyCurrentEyelashStyle() {
        guard let model = currentFaceModel, let image = originalImage else { return }
        
        if let eyelashModel = currentEyelashModel {
            // In a real app, we would apply the eyelash style to the image
            // For this demo, we'll simulate by creating visual indicators
            
            // Create overlay for eyelashes
            let eyelashOverlay = UIView()
            eyelashOverlay.tag = 200 // Tag for easy reference
            eyelashOverlay.frame = sceneView.bounds
            eyelashOverlay.isUserInteractionEnabled = false
            
            // Remove any existing eyelash overlays
            for subview in sceneView.subviews {
                if subview.tag == 200 {
                    subview.removeFromSuperview()
                }
            }
            
            // Get eye positions from the face detection model
            if let leftEye = model.leftEye, let rightEye = model.rightEye {
                // Create visual representations for the eyelashes
                let leftEyelashView = createEyelashIndicator(for: eyelashModel, at: leftEye.rect, isLeft: true)
                let rightEyelashView = createEyelashIndicator(for: eyelashModel, at: rightEye.rect, isLeft: false)
                
                eyelashOverlay.addSubview(leftEyelashView)
                eyelashOverlay.addSubview(rightEyelashView)
                
                // Add the overlay to the scene
                sceneView.addSubview(eyelashOverlay)
                
                // Update label
                instructionLabel.text = "Previewing \(eyelashModel.name) eyelashes - Tap to save"
            }
        }
    }
    
    private func createEyelashIndicator(for model: EyelashModel, at eyeRect: CGRect, isLeft: Bool) -> UIView {
        // This is a simplified visual representation - in a real app, we would use more sophisticated rendering
        let indicatorView = UIView()
        
        // Scale the eye rect to match the image in the view
        let scale = sceneView.bounds.width / (originalImage?.size.width ?? 1.0)
        let scaledRect = CGRect(
            x: eyeRect.origin.x * scale + sceneView.bounds.width/4, // Adjust for aspect fit
            y: eyeRect.origin.y * scale + sceneView.bounds.height/4,
            width: eyeRect.width * scale,
            height: eyeRect.height * scale
        )
        
        // Position slightly above the eye
        indicatorView.frame = CGRect(
            x: scaledRect.origin.x,
            y: scaledRect.origin.y - scaledRect.height * 0.3,
            width: scaledRect.width,
            height: scaledRect.height * 0.5
        )
        
        // Style based on eyelash model
        indicatorView.backgroundColor = .clear
        
        // Create a visual indicator of eyelashes
        let eyelashLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        // Number of lashes depends on thickness
        var lashCount = 7
        switch model.thickness {
        case .thin: lashCount = 5
        case .medium: lashCount = 7
        case .thick: lashCount = 9
        case .mixed: lashCount = 8
        }
        
        // Length factor depends on length enum
        var lengthFactor: CGFloat = 1.0
        switch model.length {
        case .short: lengthFactor = 0.7
        case .medium: lengthFactor = 1.0
        case .long: lengthFactor = 1.3
        case .extraLong: lengthFactor = 1.5
        case .mixed: lengthFactor = 1.2
        }
        
        // Draw lashes
        for i in 0..<lashCount {
            let x = indicatorView.bounds.width * CGFloat(i) / CGFloat(lashCount - 1)
            let startY = indicatorView.bounds.height
            let endY = indicatorView.bounds.height - indicatorView.bounds.height * lengthFactor
            
            path.move(to: CGPoint(x: x, y: startY))
            path.addLine(to: CGPoint(x: x, y: endY))
        }
        
        eyelashLayer.path = path.cgPath
        eyelashLayer.strokeColor = UIColor.black.cgColor
        eyelashLayer.lineWidth = 1.5
        
        switch model.thickness {
        case .thin: eyelashLayer.lineWidth = 1.0
        case .medium: eyelashLayer.lineWidth = 1.5
        case .thick: eyelashLayer.lineWidth = 2.0
        case .mixed: eyelashLayer.lineWidth = 1.5
        }
        
        indicatorView.layer.addSublayer(eyelashLayer)
        
        return indicatorView
    }
    
    private func addSaveButton() {
        // Check if save button already exists
        if let existingButton = view.viewWithTag(300) {
            return // Button already exists
        }
        
        let saveButton = UIButton(type: .system)
        saveButton.tag = 300
        saveButton.setTitle("Save Image", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: instructionLabel.topAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 120),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func saveButtonTapped() {
        // In a real app, we would create a composite image with the eyelashes rendered properly
        // For this demo, we'll simulate saving by showing a success message
        
        // Flash effect to simulate capture
        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 0.8
        view.addSubview(flashView)
        
        UIView.animate(withDuration: 0.3, animations: {
            flashView.alpha = 0
        }) { _ in
            flashView.removeFromSuperview()
            
            // Show success message
            self.instructionLabel.text = "Image saved with \(self.currentEyelashModel?.name ?? "eyelash") style!"
            
            // In a real app, we would save to Photos
            print("Saved image with eyelash style: \(self.currentEyelashModel?.name ?? "unknown")")
        }
    }
}

// MARK: - ARSCNViewDelegate
extension EyelashPreviewView: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.transparency = 0.5
        
        // In a real app, we would attach the eyelash models to the face at this point
        if let model = currentEyelashModel {
            applyEyelashesToFace(node: node, faceAnchor: faceAnchor, model: model)
        }
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        
        // Update the face geometry with the current face anchor
        faceGeometry.update(from: faceAnchor.geometry)
        
        // In a real app, we would update the eyelash positioning here
        if let model = currentEyelashModel {
            applyEyelashesToFace(node: node, faceAnchor: faceAnchor, model: model)
        }
    }
    
    private func applyEyelashesToFace(node: SCNNode, faceAnchor: ARFaceAnchor, model: EyelashModel) {
        // This is a simplified implementation
        // In a real app, we would use the actual face geometry and blend shapes
        // to position eyelash models correctly on the eyelids
        
        // Get eye positions
        let leftEyePosition = faceAnchor.leftEyeTransform.columns.3
        let rightEyePosition = faceAnchor.rightEyeTransform.columns.3
        
        // Create simplified eyelash visualizations
        let leftEyelash = createEyelashNode(for: model, isLeft: true)
        leftEyelash.position = SCNVector3(x: leftEyePosition.x, y: leftEyePosition.y + 0.01, z: leftEyePosition.z)
        
        let rightEyelash = createEyelashNode(for: model, isLeft: false)
        rightEyelash.position = SCNVector3(x: rightEyePosition.x, y: rightEyePosition.y + 0.01, z: rightEyePosition.z)
        
        // Remove previous eyelash nodes if they exist
        node.childNodes.filter { $0.name == "eyelash" }.forEach { $0.removeFromParentNode() }
        
        // Add new eyelash nodes
        node.addChildNode(leftEyelash)
        node.addChildNode(rightEyelash)
    }
    
    private func createEyelashNode(for model: EyelashModel, isLeft: Bool) -> SCNNode {
        // This is a placeholder implementation
        // In a real app, we would use actual 3D models for the eyelashes
        
        // Create a simple curved plane to represent eyelashes
        let width: CGFloat = isLeft ? 0.025 : -0.025  // Mirror for right eye
        let height: CGFloat = 0.01
        let eyelashGeometry = SCNPlane(width: abs(width), height: height)
        
        // Set material properties based on the eyelash model
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        material.transparency = 0.8
        eyelashGeometry.materials = [material]
        
        let eyelashNode = SCNNode(geometry: eyelashGeometry)
        eyelashNode.name = "eyelash"
        
        // Apply transformations based on model properties
        var lengthValue: Float = 0.0
        switch model.length {
        case .short: lengthValue = 0.8
        case .medium: lengthValue = 1.0
        case .long: lengthValue = 1.2
        case .extraLong: lengthValue = 1.4
        case .mixed: lengthValue = 1.1
        }
        
        var thicknessValue: Float = 0.0
        switch model.thickness {
        case .thin: thicknessValue = 0.8
        case .medium: thicknessValue = 1.0
        case .thick: thicknessValue = 1.2
        case .mixed: thicknessValue = 1.0
        }
        
        let length = CGFloat(lengthValue)
        let thickness = CGFloat(thicknessValue)
        
        eyelashNode.scale = SCNVector3(length, thickness, 1.0)
        
        // Adjust position based on type
        switch model.type {
        case .classic:
            // Classic eyelashes are positioned normally
            break
        case .volume:
            // Volume eyelashes are slightly thicker
            eyelashNode.scale.y *= 1.3
        case .hybrid:
            // Hybrid lashes are a mix
            eyelashNode.scale.y *= 1.2
        }
        
        // Additional adjustments based on custom parameters if available
        if let patternType = model.customParameters?["patternType"] as? String {
            switch patternType {
            case "catEye":
                // Cat eye has longer outer lashes
                eyelashNode.eulerAngles.z = isLeft ? -0.2 : 0.2
            case "dollEye":
                // Doll lashes are even in the middle
                eyelashNode.eulerAngles.z = isLeft ? 0.1 : -0.1
            case "squirrel":
                // Squirrel lashes have a criss-cross pattern
                eyelashNode.eulerAngles.x = 0.1
            default:
                break
            }
        }
        
        return eyelashNode
    }
}
