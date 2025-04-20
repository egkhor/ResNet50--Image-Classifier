//
//  ContentView.swift
//  ImageClassifierApp
//
//  Created by Isaac Eng Gian Khor on 20/04/2025.
//
//
//  ContentView.swift
//  ImageClassifierApp
//
//  Created by Isaac Eng Gian Khor on 20/04/2025.
//
import SwiftUI
import CoreML
import Vision
import PhotosUI

struct ContentView: View {
    @State private var image: UIImage?
    @State private var classificationResult: String = "No prediction yet"
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isClassifying = false // For loading indicator
    @Environment(\.colorScheme) var colorScheme // For dark mode support

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Display the selected or captured image
                ZStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: 5)
                            .overlay(
                                isClassifying ? ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                : nil
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay(
                                Text("No image selected")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            )
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)

                // Display the classification result
                Text(classificationResult)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)

                // Buttons to select image or take photo
                HStack(spacing: 20) {
                    CustomButton(title: "Select Photo", color: .blue) {
                        imagePickerSourceType = .photoLibrary
                        showingImagePicker = true
                    }

                    CustomButton(title: "Take Photo", color: .green) {
                        imagePickerSourceType = .camera
                        showingCamera = true
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Image Classifier")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea()
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $image, sourceType: .photoLibrary)
                    .onChange(of: image) { _ in classifyImage() }
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $image, sourceType: .camera)
                    .onChange(of: image) { _ in classifyImage() }
            }
        }
        .navigationViewStyle(.stack) // Ensure stack navigation on iPhone
    }

    // Function to classify the image using ResNet-50
    private func classifyImage() {
        guard let image = image else {
            classificationResult = "No image to classify"
            return
        }

        // Convert UIImage to CVPixelBuffer for Core ML
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            classificationResult = "Error: Could not convert image"
            return
        }

        // Load the ResNet-50 model
        do {
            isClassifying = true
            defer { isClassifying = false }

            let model = try ResNet50(configuration: MLModelConfiguration())
            let input = ResNet50Input(image: pixelBuffer)

            // Make prediction
            let output = try model.prediction(input: input)
            let predictedClass = output.classLabel
            let probabilities = output.classLabel_probs // Note: This line may fail due to space
            let confidence = probabilities[predictedClass] ?? 0.0

            // Map the predicted class to a human-readable label
            if let classIndex = Int(predictedClass.replacingOccurrences(of: "class_", with: "")), classIndex < ImageNetLabels.labels.count {
                let predictedLabel = ImageNetLabels.labels[classIndex]
                classificationResult = "Predicted: \(predictedLabel) (Confidence: \(String(format: "%.2f", confidence)))"
            } else {
                classificationResult = "Predicted: \(predictedClass) (Confidence: \(String(format: "%.2f", confidence)))"
            }
        } catch {
            classificationResult = "Error: \(error.localizedDescription)"
        }
    }
}

// Reusable custom button with animation
struct CustomButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    @State private var isTapped = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isTapped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isTapped = false
            }
            action()
        }) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.opacity(isTapped ? 0.7 : 0.9))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: isTapped ? 2 : 5)
                .scaleEffect(isTapped ? 0.95 : 1.0)
        }
    }
}

// Helper to pick images from photo library or camera
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// Extension to convert UIImage to CVPixelBuffer for Core ML
extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let width = 224
        let height = 224
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )!

        let image = resized(to: CGSize(width: width, height: height))
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }

    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        ContentView()
            .preferredColorScheme(.dark)
    }
}
