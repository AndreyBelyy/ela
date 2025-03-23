import Foundation

// Enumeration for different eyelash styles
enum EyelashStyle {
    case natural   // Natural-looking eyelashes
    case volume    // Full volume eyelashes
    case dramatic  // Bold and dramatic eyelashes
    case catEye    // Cat-eye style (longer outer lashes)
    case dolly     // Doll-like round eyelashes
    case squirrel  // Squirrel style with crossed lashes
}

// Enumeration for different eyelash curls
enum EyelashCurl {
    case jCurl   // J-shaped curl (subtle)
    case bCurl   // B-shaped curl (natural)
    case cCurl   // C-shaped curl (noticeable)
    case dCurl   // D-shaped curl (dramatic)
    case lCurl   // L-shaped curl (very lifted)
    case uCurl   // U-shaped curl (extremely curled)
}

// Model representing an eyelash style
struct EyelashModel {
    // Unique identifier for the eyelash style
    let id: String
    
    // Display name for the eyelash style
    let name: String
    
    // Description of the eyelash style
    let description: String
    
    // The style of the eyelashes
    let style: EyelashStyle
    
    // Thickness of the eyelashes (in mm)
    let thickness: Double
    
    // Curl type of the eyelashes
    let curve: EyelashCurl
    
    // Length of the eyelashes (in mm)
    let length: Double
    
    // Default initializer
    init(id: String, name: String, description: String, style: EyelashStyle, thickness: Double, curve: EyelashCurl, length: Double) {
        self.id = id
        self.name = name
        self.description = description
        self.style = style
        self.thickness = thickness
        self.curve = curve
        self.length = length
    }
    
    // Create a copy with modified parameters
    func with(thickness: Double? = nil, curve: EyelashCurl? = nil, length: Double? = nil) -> EyelashModel {
        return EyelashModel(
            id: self.id,
            name: self.name,
            description: self.description,
            style: self.style,
            thickness: thickness ?? self.thickness,
            curve: curve ?? self.curve,
            length: length ?? self.length
        )
    }
}
