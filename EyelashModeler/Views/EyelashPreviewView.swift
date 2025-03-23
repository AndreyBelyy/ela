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
        
        // In a real app, we would update the AR face content with the new eyelash model
    }
    
    // Method to update the view with face detection results
    func updateWithFaceDetection(model: FaceDetectionModel, image: UIImage) {
        // Store the face detection model for use in AR face tracking
        
        // Create an image overlay with the detected face
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = sceneView.bounds
        imageView.alpha = 0.3 // Semi-transparent overlay
        
        // Remove any existing image overlays
        for subview in sceneView.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
        
        // Add the new image overlay
        sceneView.insertSubview(imageView, at: 0)
        
        // Update the instruction label
        instructionLabel.text = "Face detected! Try different eyelash styles"
        
        // Apply current eyelash model if available
        if let eyelashModel = currentEyelashModel {
            // In a real app, we would update the AR face content with the eyelash model
            // using the detected face points from the FaceDetectionModel
            
            // For now, we'll just update the label
            instructionLabel.text = "Previewing \(eyelashModel.name) on detected face"
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
