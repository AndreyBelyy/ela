import UIKit

protocol EditorViewDelegate: AnyObject {
    func editorView(_ view: EditorView, didFinishEditing image: UIImage)
}

class EditorView: UIViewController {
    
    weak var delegate: EditorViewDelegate?
    
    // The image with eyelashes applied
    private var editedImage: UIImage?
    
    // The current eyelash model being applied
    private var currentEyelashModel: EyelashModel?
    
    // UI components
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Eyelashes"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sliderStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Sliders for adjusting eyelash properties
    private let thicknessSlider = UISlider()
    private let lengthSlider = UISlider()
    private let densitySlider = UISlider()
    
    // Labels for sliders
    private let thicknessLabel = UILabel()
    private let lengthLabel = UILabel()
    private let densityLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add title label
        view.addSubview(titleLabel)
        
        // Add image view
        view.addSubview(imageView)
        
        // Set up sliders
        setupSliders()
        
        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            sliderStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            sliderStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            sliderStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            sliderStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
    
    private func setupSliders() {
        // Thickness slider
        let thicknessView = createSliderWithLabel(
            slider: thicknessSlider,
            label: thicknessLabel,
            title: "Thickness",
            minValue: 0.05,
            maxValue: 0.25,
            initialValue: 0.15
        )
        
        // Length slider
        let lengthView = createSliderWithLabel(
            slider: lengthSlider,
            label: lengthLabel,
            title: "Length",
            minValue: 8,
            maxValue: 16,
            initialValue: 12
        )
        
        // Density slider
        let densityView = createSliderWithLabel(
            slider: densitySlider,
            label: densityLabel,
            title: "Density",
            minValue: 0.5,
            maxValue: 1.5,
            initialValue: 1.0
        )
        
        // Add sliders to stack view
        sliderStack.addArrangedSubview(thicknessView)
        sliderStack.addArrangedSubview(lengthView)
        sliderStack.addArrangedSubview(densityView)
        
        // Add slider actions
        thicknessSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        lengthSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        densitySlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    private func createSliderWithLabel(slider: UISlider, label: UILabel, title: String, minValue: Float, maxValue: Float, initialValue: Float) -> UIView {
        // Container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Value label
        label.text = "\(initialValue)"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure slider
        slider.minimumValue = minValue
        slider.maximumValue = maxValue
        slider.value = initialValue
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        // Add components to container
        containerView.addSubview(titleLabel)
        containerView.addSubview(label)
        containerView.addSubview(slider)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.widthAnchor.constraint(equalToConstant: 50),
            
            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            slider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            slider.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    @objc private func sliderValueChanged() {
        // Update the labels with current slider values
        thicknessLabel.text = String(format: "%.2f", thicknessSlider.value)
        lengthLabel.text = String(format: "%.1f", lengthSlider.value)
        densityLabel.text = String(format: "%.2f", densitySlider.value)
        
        // In a real application, we would update the eyelash rendering in real-time
        // For now, we'll just simulate this by logging the changes
        print("Adjusting eyelashes - Thickness: \(thicknessSlider.value), Length: \(lengthSlider.value), Density: \(densitySlider.value)")
        
        // Notify delegate that editing has occurred
        if let image = editedImage {
            delegate?.editorView(self, didFinishEditing: image)
        }
    }
    
    func setEyelashModel(_ eyelashModel: EyelashModel) {
        self.currentEyelashModel = eyelashModel
        
        // Set slider values based on the eyelash model properties
        // Map from enum values to actual slider values
        
        // Set thickness slider based on thickness enum
        var thicknessValue: Float = 0.15 // Default to medium
        switch eyelashModel.thickness {
        case .thin:
            thicknessValue = 0.06
        case .medium:
            thicknessValue = 0.12
        case .thick:
            thicknessValue = 0.20
        case .mixed:
            thicknessValue = 0.15
        }
        thicknessSlider.value = thicknessValue
        thicknessLabel.text = String(format: "%.2f", thicknessValue)
        
        // Set length slider based on length enum
        var lengthValue: Float = 12.0 // Default to medium
        switch eyelashModel.length {
        case .short:
            lengthValue = 8.0
        case .medium:
            lengthValue = 11.0
        case .long:
            lengthValue = 14.0
        case .extraLong:
            lengthValue = 16.0
        case .mixed:
            lengthValue = 12.0
        }
        lengthSlider.value = lengthValue
        lengthLabel.text = String(format: "%.1f", lengthValue)
        
        // Density is not in the model, so we'll keep it at the default value
        densitySlider.value = 1.0
        densityLabel.text = "1.00"
        
        // Update UI with the model name
        titleLabel.text = "Editing: \(eyelashModel.name)"
    }
    
    func setImage(_ image: UIImage) {
        self.editedImage = image
        
        // Update the image view
        imageView.image = image
    }
    
    func getFinalImage() -> UIImage? {
        // In a real application, we would apply all the adjustments to create the final image
        // For this demo, we'll just return the current edited image
        return editedImage
    }
}
