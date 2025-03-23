import UIKit

protocol EyelashLibraryViewDelegate: AnyObject {
    func libraryView(_ view: EyelashLibraryView, didSelectEyelash eyelashModel: EyelashModel)
}

class EyelashLibraryView: UIViewController {
    
    weak var delegate: EyelashLibraryViewDelegate?
    
    private var eyelashModels: [EyelashModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var selectedIndex: Int? {
        didSet {
            // Notify delegate of selection
            if let index = selectedIndex {
                delegate?.libraryView(self, didSelectEyelash: eyelashModels[index])
            }
        }
    }
    
    // UI Components
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(EyelashCell.self, forCellWithReuseIdentifier: "EyelashCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Eyelash Styles"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadEyelashModels()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add title label
        view.addSubview(titleLabel)
        
        // Add collection view
        view.addSubview(collectionView)
        
        // Set up collection view delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func loadEyelashModels() {
        // In a real application, these would come from a backend or local database
        // Creating sample eyelash models for demonstration
        
        let naturalEyelash = EyelashModel(
            id: "natural",
            name: "Natural",
            description: "A natural-looking eyelash extension",
            type: .classic,
            length: .medium,
            thickness: .thin,
            curl: .jCurl,
            customParameters: ["style": "natural"]
        )
        
        let volumeEyelash = EyelashModel(
            id: "volume",
            name: "Volume",
            description: "Full volume eyelash extension",
            type: .volume,
            length: .medium,
            thickness: .medium,
            curl: .dCurl,
            customParameters: ["style": "volume"]
        )
        
        let dramaticEyelash = EyelashModel(
            id: "dramatic",
            name: "Dramatic",
            description: "Dramatic and bold eyelash extension",
            type: .volume,
            length: .long,
            thickness: .thick,
            curl: .dCurl,
            customParameters: ["style": "dramatic"]
        )
        
        let catEyeEyelash = EyelashModel(
            id: "cat_eye",
            name: "Cat Eye",
            description: "Cat eye style with longer outer lashes",
            type: .classic,
            length: .mixed,
            thickness: .medium,
            curl: .cCurl,
            customParameters: ["patternType": "catEye"]
        )
        
        let dollyEyelash = EyelashModel(
            id: "dolly",
            name: "Dolly",
            description: "Doll-like round eyelash extension",
            type: .hybrid,
            length: .mixed,
            thickness: .medium,
            curl: .cCurl,
            customParameters: ["patternType": "dollEye"]
        )
        
        let squirrelEyelash = EyelashModel(
            id: "squirrel",
            name: "Squirrel",
            description: "Squirrel style with crossed lashes",
            type: .hybrid,
            length: .medium,
            thickness: .thin,
            curl: .cCurl,
            customParameters: ["patternType": "squirrel"]
        )
        
        eyelashModels = [
            naturalEyelash,
            volumeEyelash,
            dramaticEyelash,
            catEyeEyelash,
            dollyEyelash,
            squirrelEyelash
        ]
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension EyelashLibraryView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eyelashModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EyelashCell", for: indexPath) as? EyelashCell else {
            return UICollectionViewCell()
        }
        
        let model = eyelashModels[indexPath.item]
        cell.configure(with: model)
        
        // Highlight selected cell
        cell.isSelected = indexPath.item == selectedIndex
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Update selected index
        selectedIndex = indexPath.item
        
        // Refresh collection view to update cell appearances
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EyelashLibraryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate cell size based on collection view width (2 columns)
        let width = (collectionView.frame.width - 10) / 2
        return CGSize(width: width, height: 180)
    }
}

// MARK: - EyelashCell
class EyelashCell: UICollectionViewCell {
    
    // UI Components
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let thumbnailView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            // Update appearance when selected state changes
            contentView.layer.borderWidth = isSelected ? 3 : 0
            contentView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : nil
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.1
        
        // Add UI components to the cell
        contentView.addSubview(thumbnailView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            thumbnailView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            thumbnailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            thumbnailView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with model: EyelashModel) {
        nameLabel.text = model.name
        descriptionLabel.text = model.description
        
        // In a real app, we would display an image of the eyelash style here
        // For now, we'll just use a colored background to differentiate types
        switch model.type {
        case .classic:
            thumbnailView.backgroundColor = .systemBrown.withAlphaComponent(0.3)
        case .volume:
            thumbnailView.backgroundColor = .systemBrown.withAlphaComponent(0.6)
        case .hybrid:
            thumbnailView.backgroundColor = .systemBrown.withAlphaComponent(0.4)
        }
        
        // Add additional styling based on custom parameters if available
        if let patternType = model.customParameters?["patternType"] as? String {
            switch patternType {
            case "catEye":
                thumbnailView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
            case "dollEye":
                thumbnailView.backgroundColor = .systemPink.withAlphaComponent(0.3)
            case "squirrel":
                thumbnailView.backgroundColor = .systemOrange.withAlphaComponent(0.3)
            default:
                break
            }
        }
    }
}
