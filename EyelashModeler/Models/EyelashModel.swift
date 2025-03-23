import UIKit

struct EyelashModel {
    var id: String
    var name: String
    var image: UIImage?
    var description: String
    var type: EyelashType
    var length: EyelashLength
    var thickness: EyelashThickness
    var curl: EyelashCurl
    var customParameters: [String: Any]?
    
    init(id: String = UUID().uuidString,
         name: String,
         image: UIImage? = nil,
         description: String = "",
         type: EyelashType = .classic,
         length: EyelashLength = .medium,
         thickness: EyelashThickness = .medium,
         curl: EyelashCurl = .cCurl,
         customParameters: [String: Any]? = nil) {
        
        self.id = id
        self.name = name
        self.image = image
        self.description = description
        self.type = type
        self.length = length
        self.thickness = thickness
        self.curl = curl
        self.customParameters = customParameters
    }
    
    // Static method to get sample eyelash models for the library
    static func getSampleEyelashes() -> [EyelashModel] {
        return [
            EyelashModel(name: "Classic Natural", 
                         description: "Natural looking classic lashes", 
                         type: .classic, 
                         length: .short, 
                         thickness: .thin, 
                         curl: .jCurl),
            
            EyelashModel(name: "Classic Dramatic", 
                         description: "Bold classic lashes", 
                         type: .classic, 
                         length: .long, 
                         thickness: .thick, 
                         curl: .dCurl),
            
            EyelashModel(name: "Volume Light", 
                         description: "Light volume lashes", 
                         type: .volume, 
                         length: .medium, 
                         thickness: .medium, 
                         curl: .cCurl),
            
            EyelashModel(name: "Volume Dramatic", 
                         description: "Full dramatic volume", 
                         type: .volume, 
                         length: .extraLong, 
                         thickness: .thick, 
                         curl: .dCurl),
            
            EyelashModel(name: "Hybrid Natural", 
                         description: "Mixed classic and volume for natural look", 
                         type: .hybrid, 
                         length: .medium, 
                         thickness: .medium, 
                         curl: .cCurl),
            
            EyelashModel(name: "Wispy", 
                         description: "Wispy effect with varied lengths", 
                         type: .hybrid, 
                         length: .mixed, 
                         thickness: .mixed, 
                         curl: .cCurl,
                         customParameters: ["patternType": "wispy"]),
            
            EyelashModel(name: "Cat Eye", 
                         description: "Longer on the outer edges", 
                         type: .classic, 
                         length: .mixed, 
                         thickness: .medium, 
                         curl: .dCurl,
                         customParameters: ["patternType": "catEye"]),
            
            EyelashModel(name: "Doll Eye", 
                         description: "Longest in the middle for doll-like effect", 
                         type: .volume, 
                         length: .mixed, 
                         thickness: .thick, 
                         curl: .dCurl,
                         customParameters: ["patternType": "dollEye"])
        ]
    }
}

// MARK: - Eyelash Properties Enums

enum EyelashType: String, CaseIterable {
    case classic = "Classic"
    case volume = "Volume"
    case hybrid = "Hybrid"
    
    var description: String {
        switch self {
        case .classic:
            return "One extension per natural lash"
        case .volume:
            return "Multiple extensions per natural lash"
        case .hybrid:
            return "Mix of classic and volume"
        }
    }
}

enum EyelashLength: String, CaseIterable {
    case short = "Short (6-8mm)"
    case medium = "Medium (9-11mm)"
    case long = "Long (12-14mm)"
    case extraLong = "Extra Long (15mm+)"
    case mixed = "Mixed Lengths"
    
    var minLength: Float {
        switch self {
        case .short: return 6.0
        case .medium: return 9.0
        case .long: return 12.0
        case .extraLong: return 15.0
        case .mixed: return 6.0 // Minimum in the mix
        }
    }
    
    var maxLength: Float {
        switch self {
        case .short: return 8.0
        case .medium: return 11.0
        case .long: return 14.0
        case .extraLong: return 20.0
        case .mixed: return 20.0 // Maximum in the mix
        }
    }
}

enum EyelashThickness: String, CaseIterable {
    case thin = "Thin (0.05-0.07mm)"
    case medium = "Medium (0.10-0.15mm)"
    case thick = "Thick (0.18-0.25mm)"
    case mixed = "Mixed"
    
    var minThickness: Float {
        switch self {
        case .thin: return 0.05
        case .medium: return 0.10
        case .thick: return 0.18
        case .mixed: return 0.05
        }
    }
    
    var maxThickness: Float {
        switch self {
        case .thin: return 0.07
        case .medium: return 0.15
        case .thick: return 0.25
        case .mixed: return 0.25
        }
    }
}

enum EyelashCurl: String, CaseIterable {
    case jCurl = "J Curl"
    case bCurl = "B Curl"
    case cCurl = "C Curl"
    case dCurl = "D Curl"
    case lCurl = "L Curl"
    case uCurl = "U Curl"
    
    var curlFactor: Float {
        switch self {
        case .jCurl: return 0.2  // Slight curl
        case .bCurl: return 0.4  // Natural curl
        case .cCurl: return 0.6  // Medium curl
        case .dCurl: return 0.8  // Dramatic curl
        case .lCurl: return 0.7  // Lifted curl
        case .uCurl: return 0.9  // Extreme curl
        }
    }
    
    var description: String {
        switch self {
        case .jCurl: return "Very subtle lift, ideal for straight lashes"
        case .bCurl: return "Slight curl, creates a natural look"
        case .cCurl: return "Medium curl, provides a lifted look"
        case .dCurl: return "Dramatic curl, creates an eye-opening effect"
        case .lCurl: return "Flat base with lifted tip, ideal for hooded eyes"
        case .uCurl: return "Extreme curl, provides maximum lift"
        }
    }
}