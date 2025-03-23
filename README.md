# Eyelash Modeler iOS App

This is an iOS application for eyelash professionals to help clients visualize different eyelash styles before application.

## Features

- Take photos or select from the photo library
- Automatic face and eye detection
- Library of different eyelash styles
- Real-time preview of eyelashes on the client's photo
- Edit eyelash properties (thickness, length, density)
- Save the edited images to the photo library

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+
- iPhone or iPad

## Technical Implementation

### Vision Framework

The app uses Apple's Vision framework to detect facial landmarks, particularly focusing on eyes and eyebrows for precise eyelash placement.

### ARKit

ARKit is used for real-time preview functionality, allowing clients to see how different eyelash styles would look on their face.

### Core Image

Image processing and rendering is done using Core Image filters and custom rendering.

## Privacy Requirements

The app requires the following permissions:

- Camera access - to take photos
- Photo Library access - to select and save photos
- Face ID / Face tracking - for facial feature detection

## Development Notes

This application was designed for professional eyelash specialists to showcase different eyelash extension styles to their clients. The app helps clients visualize the final result before any actual work is done.

The automatic placement of eyelashes on the client's eyes is handled through computer vision techniques, using facial landmark detection to precisely position the eyelash models.

The eyelash library contains various styles including:
- Natural
- Volume
- Dramatic
- Cat Eye
- Dolly
- Squirrel

Each style can be further customized by adjusting thickness, length, and density parameters.
