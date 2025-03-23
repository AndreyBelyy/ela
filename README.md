# Eyelash Modeler iOS Application

An iOS application for eyelash specialists that allows them to preview different eyelash styles on client photos before application.

## Features

- **Photo Capture**: Take photos of clients directly within the app
- **Photo Library**: Access existing photos from the device's photo library
- **Face Detection**: Automatic detection of face and eye areas using Vision framework
- **Eyelash Library**: Browse through various eyelash styles and models
- **Virtual Try-On**: Apply virtual eyelash models to client photos
- **Editing Capabilities**: Adjust eyelash properties such as length, thickness, and curl
- **Preview**: Show clients what the eyelash extensions will look like when applied

## Technical Details

- **Platform**: iOS 14.0+
- **Devices**: Compatible with iPhone and iPad
- **Frameworks**:
  - UIKit for the user interface
  - AVFoundation for camera functionality
  - Vision for face detection
  - Core Graphics for rendering

## Project Structure

The project follows a modular architecture with clear separation of concerns:

- **Models**: Data structures for eyelash properties and face detection
- **Views**: User interface components
- **Utils**: Helper classes for face detection, image picking, and eyelash rendering

## Installation

1. Clone the repository
2. Open `EyelashModeler.xcodeproj` in Xcode 12.0 or later
3. Build and run on an iOS device or simulator

## Usage

The app features a tab-based interface with the following main sections:

1. **Camera**: Capture photos of clients
2. **Library**: Browse and select eyelash styles
3. **Editor**: Fine-tune eyelash properties
4. **Preview**: View the final result with eyelashes applied

## Requirements

- Xcode 12.0+
- iOS 14.0+
- Swift 5.3+
- Physical device recommended for camera functionality (simulator has limited camera support)

## Privacy

The app requires the following permissions:

- Camera access for capturing photos
- Photo library access for selecting existing photos

## License

This project is available for use under the MIT license.