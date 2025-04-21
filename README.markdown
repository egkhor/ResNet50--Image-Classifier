# ImageClassifierApp

## Overview

`ImageClassifierApp` is an iOS application developed by **EGK IsaacLab Industry4.0** for real-time image classification using the ResNet-50 model. This app allows users to classify images either by selecting from their photo library or capturing new photos with the device camera. It leverages Core ML for on-device inference, ensuring privacy and performance, and aligns with Industry 4.0 principles by providing smart, data-driven insights through machine learning. The app features a modern user interface with interactive elements, a loading indicator, and dark mode support, making it both functional and visually appealing.

The app uses the `ResNet50.mlpackage`, a Core ML model converted from a pre-trained PyTorch ResNet-50 model, to classify images into one of 1,000 ImageNet categories. It displays the predicted class label and confidence score, helping users identify objects in photos with high accuracy.

## Features

- **Real-Time Image Classification**: Classifies images using ResNet-50 with on-device inference.
- **Photo Selection and Capture**: Allows users to select images from the photo library or capture new photos using the camera.
- **Modern UI**:
  - Rounded corners, shadows, and a clean layout for a polished look.
  - Interactive buttons with press animations.
  - Loading indicator during classification.
  - Dark mode support for better accessibility.
- **Output Display**: Shows the predicted class label and confidence score (e.g., "Predicted: tabby cat (Confidence: 0.92)").
- **Core ML Integration**: Optimized for iOS 15.0+ using the ML Program format (`.mlpackage`).

## Model Details

- **Model**: `ResNet50.mlpackage`
- **Architecture**: ResNet-50 (converted from PyTorch to Core ML).
- **Input**:
  - `image`: Color image (224x224 pixels, RGB).
  - Preprocessing: Scaled by 1/255, with bias adjustments for ImageNet normalization (`[-0.485/0.229, -0.456/0.224, -0.406/0.225]`).
- **Output**:
  - `logits`: Raw logits (MultiArray of shape `(1, 1000)`), processed in Swift to compute probabilities and predicted class.
- **Classes**: 1,000 ImageNet categories (mapped to human-readable labels via `ImageNetLabels.swift`).
- **Size**: Approximately 100 MB (typical for ResNet-50 in Core ML format).

## Requirements

- **Platform**: iOS 15.0 or later (required for ML Program models like `.mlpackage`).
- **Dependencies**:
  - Core ML framework (built into iOS).
  - Vision framework (for image processing).
  - PhotosUI framework (for photo library access).
- **Hardware**: iPhone with an A12 Bionic chip or later for optimal performance.
- **Files**:
  - `ResNet50.mlpackage`: The Core ML model file.
  - `ImageNetLabels.swift`: A file containing the list of 1,000 ImageNet class labels.

## Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/EGK-IsaacLab/ImageClassifierApp.git
   cd ImageClassifierApp
   ```

2. **Open in Xcode**:
   - Open `ImageClassifierApp.xcodeproj` in Xcode (version 15.0 or later recommended).

3. **Add the Model**:
   - Drag `ResNet50.mlpackage` into the Xcode project.
   - Ensure it’s added to the app’s target under "Build Phases" > "Copy Bundle Resources."

4. **Add ImageNet Labels**:
   - Ensure `ImageNetLabels.swift` is included in the project with the full list of 1,000 ImageNet labels. You can download the labels from the ImageNet website or use a pre-existing list.

5. **Build and Run**:
   - Build the app in Xcode (Cmd + B).
   - Run on an iPhone or simulator (Cmd + R).

## Usage

### 1. Launch the App
- Open the app on your iPhone.
- The main screen displays a placeholder with the text "No image selected," a classification result area, and two buttons: "Select Photo" and "Take Photo."

### 2. Classify an Image
- **Select Photo**:
  - Tap the "Select Photo" button to choose an image from your photo library.
  - The app will display the selected image and classify it automatically.
- **Take Photo**:
  - Tap the "Take Photo" button to capture a new image using the camera.
  - The app will display the captured image and classify it.
- While the image is being classified, a loading indicator appears over the image.

### 3. View Results
- The classification result is displayed below the image, showing the predicted class and confidence score (e.g., "Predicted: tabby cat (Confidence: 0.92)").
- If an error occurs (e.g., image conversion fails), an error message is shown instead.

### 4. Example Scenario
- A user captures a photo of a dog.
- The app processes the image using ResNet-50 and displays: "Predicted: golden retriever (Confidence: 0.95)."
- The user can then select another photo or take a new one to classify a different object.

## Technical Details

### Model Conversion
The `ResNet50.mlpackage` was converted from a pre-trained PyTorch ResNet-50 model using `coremltools`. Key steps:
- Traced the PyTorch model with a dummy input (1, 3, 224, 224).
- Converted to Core ML with explicit output (`logits`) to avoid issues with `ClassifierConfig`.
- Saved as an ML Program model (`.mlpackage`) for iOS 15.0+ compatibility.
See `convert_resnet_to_coreml.py` in the repository for the conversion script.

### Post-Processing
The app processes raw logits in Swift:
- Applies softmax to convert logits to probabilities.
- Finds the predicted class (argmax) and its confidence.
- Maps the class index to a human-readable label using `ImageNetLabels.swift`.

## Troubleshooting

- **Model Not Found**:
  - Ensure `ResNet50.mlpackage` is added to the Xcode project and target.
  - Clean the build folder (Cmd + Shift + K) and rebuild.
- **ImageNet Labels Missing**:
  - Verify that `ImageNetLabels.swift` contains the full list of 1,000 ImageNet labels.
- **Performance Issues**:
  - Ensure the device has an A12 Bionic chip or later for optimal Core ML performance.
  - Test on a physical device rather than a simulator for accurate performance.
- **Camera/Photo Library Access**:
  - Check that the app has permissions for camera and photo library access (add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to `Info.plist` if missing).

## Contributing

1. Fork the repository: `https://github.com/EGK-IsaacLab/ImageClassifierApp.git`.
2. Create a feature branch (`git checkout -b feature/new-feature`).
3. Commit changes (`git commit -m "Add new feature"`).
4. Push to the branch (`git push origin feature/new-feature`).
5. Open a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## About EGK IsaacLab Industry4.0

**EGK IsaacLab Industry4.0** is a team dedicated to advancing smart automation and data-driven solutions through Industry 4.0 principles. We focus on leveraging machine learning, IoT, and predictive analytics to create impactful applications, such as this image classifier for real-time object recognition.

## References

- Core ML Documentation: [Apple Developer](https://developer.apple.com/documentation/coreml).
- ImageNet Labels: Download from the [ImageNet website](http://image-net.org).
- Industry 4.0 Principles: General knowledge on smart automation and machine learning applications.