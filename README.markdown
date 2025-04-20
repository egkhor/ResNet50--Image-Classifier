# In-Demand Machine Learning Models for 2025

This repository contains six machine learning models that are highly demanded in 2025, covering tabular data, computer vision, NLP, and time-series tasks. Additionally, we provide examples of applying the ResNet-50 Image Classifier in real-world applications, including an iOS app with an enhanced UI.

## Models Included

1. **XGBoost Classifier** (`xgboost_classifier.py`): Classifies tennis swing types using tabular data.
2. **ResNet-50 Image Classifier** (`resnet_classifier.py`): Classifies images using a pre-trained ResNet-50 model.
3. **BERT Text Classifier** (`bert_classifier.py`): Performs sentiment analysis on text using BERT.
4. **Random Forest Classifier** (`random_forest_classifier.py`): Detects fraud using tabular data.
5. **LSTM Network** (`lstm_forecasting.py`): Forecasts energy demand using time-series data.
6. **YOLOv8 Object Detection** (`yolov8_object_detection.py`): Performs real-time object detection on images.

## Applications for ResNet-50 Image Classifier

### 1. Mobile App for Real-Time Image Classification
- **Files**: `convert_resnet_to_tflite.py`, `main.dart`
- **Description**: Build a Flutter app to classify objects in real-time using a phone camera.
- **Setup**:
  - Convert the ResNet-50 model to TensorFlow Lite: `python convert_resnet_to_tflite.py`
  - Set up a Flutter project and add `main.dart` along with assets (`resnet50.tflite`, `imagenet_labels.txt`).
  - Run the app on a mobile device: `flutter run`

### 2. Web App for Medical Image Analysis
- **Files**: `convert_to_tfjs.py`, `app.py`, `templates/index.html`
- **Description**: Build a Flask web app to classify medical images in the browser.
- **Setup**:
  - Convert the ResNet-50 model to TensorFlow.js: `python convert_to_tfjs.py`
  - Place the `resnet50_tfjs` folder in the `static/` directory.
  - Run the Flask app: `python app.py`
  - Open the webpage in a browser to upload and classify images.

### 3. Smart Camera for Home Security (IoT)
- **Files**: `smart_camera.py`
- **Description**: Deploy ResNet-50 on a Raspberry Pi to build a smart camera for home security.
- **Setup**:
  - Ensure `resnet50.onnx` and `imagenet_labels.txt` are in the same directory.
  - Run on a Raspberry Pi with a camera module: `python smart_camera.py`

### 4. iOS App for Image Classification
- **Files**: `convert_resnet_to_coreml.py`, `convert_resnet_to_coreml_via_onnx.py`, `convert_resnet_to_coreml_neuralnetwork.py`, `ImageClassifierApp/ContentView.swift`, `ImageClassifierApp/ImageNetLabels.swift`, `ResNet50.mlpackage`
- **Description**: Build an iOS app using Xcode to classify images using the device’s camera or photo library. The app features an enhanced UI with a sidebar navigation menu, a loading indicator, animated buttons, and dark mode support. The ResNet-50 model outputs raw logits, which are processed in Swift to compute probabilities and predicted classes.
- **Setup**:
  - Convert the ResNet-50 model to Core ML (ML Program format): `python convert_resnet_to_coreml.py`
  - If you need the legacy Neural Network format (`.mlmodel`), use: `python convert_resnet_to_coreml_neuralnetwork.py`
  - If the direct PyTorch conversion fails, use the ONNX workaround: `python convert_resnet_to_coreml_via_onnx.py`
  - Open the `ImageClassifierApp` Xcode project.
  - Add `ResNet50.mlpackage` (or `ResNet50.mlmodel` if using Neural Network format) to the project.
  - Populate `ImageNetLabels.swift` with the full list of ImageNet labels.
  - Ensure the app’s deployment target is iOS 15.0+ if using `.mlpackage` (required for ML Program models).
  - Build and run on an iPhone or simulator.

## Prerequisites

- Python 3.8+
- Flutter (for mobile app)
- Raspberry Pi with camera module (for smart camera)
- Xcode 15+ (for iOS app)

- Install Python dependencies:

  ```bash
  pip install pandas xgboost scikit-learn joblib torch torchvision transformers pillow numpy tensorflow matplotlib ultralytics opencv-python onnxruntime tensorflowjs flask coremltools onnx
  ```

- Install Flutter dependencies (for mobile app):
  ```bash
  flutter pub add camera tflite
  ```

## Dataset and Files

- **swing_data.csv**: Required for `xgboost_classifier.py`. Format: columns `accelX`, `accelY`, `accelZ`, `gyroX`, `gyroY`, `gyroZ`, `swingType`.
- **fraud_data.csv**: Required for `random_forest_classifier.py`. Format: features and a label column `is_fraud`.
- **energy_demand.csv**: Required for `lstm_forecasting.py`. Format: a column `demand` with time-series data.
- **example_image.jpg**: Required for `resnet_classifier.py`, `yolov8_object_detection.py`, and application scripts. Replace with your image.
- **imagenet_classes.txt** / **imagenet_labels.txt**: Required for ResNet-50 scripts. Download from ImageNet or similar sources.

## Usage

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. Run each script as described in the sections above.

## Troubleshooting

- **NumPy Compatibility Issues**:
  - If you see a warning about NumPy 1.x vs. 2.x compatibility, downgrade NumPy:
    ```bash
    pip install "numpy<2" --force-reinstall
    ```
- **SSL Certificate Errors**:
  - If you encounter an SSL certificate error while downloading weights, install certificates:
    ```bash
    /Applications/Python\ 3.10/Install\ Certificates.command
    ```
  - Alternatively, download the weights manually and load them locally (see `convert_resnet_to_coreml.py` for instructions).
- **Core ML Conversion Issues**:
  - If `coremltools` fails to detect the PyTorch model, ensure you’ve specified `source="pytorch"` in the `ct.convert` call.
  - If the issue persists, use the ONNX workaround: `python convert_resnet_to_coreml_via_onnx.py`.
- **ML Program vs. Neural Network Format**:
  - By default, `coremltools` converts to ML Program format (`.mlpackage`), which requires iOS 15.0+.
  - If you need the legacy Neural Network format (`.mlmodel`), use `convert_resnet_to_coreml_neuralnetwork.py`.
- **Core ML Output Naming Issues**:
  - If `ClassifierConfig` fails with errors about `predicted_probabilities_output`, remove it and manually define outputs (e.g., `logits`) in the `ct.convert` call. Post-process the logits in Swift to compute probabilities.
  - Clean the Xcode build folder (`Cmd + Shift + K`) and rebuild if the model updates don’t take effect.

## Notes

- Ensure you have a GPU for faster inference with ResNet, BERT, LSTM, and YOLOv8 models.
- Replace placeholder files (e.g., `example_image.jpg`) with your data.
- YOLOv8 requires internet access to download the pre-trained weights (`yolov8n.pt`) on first run.
- For the iOS app, ensure `ImageNetLabels.swift` contains the full list of ImageNet class labels for accurate predictions.
- The iOS app now processes raw logits from the ResNet-50 model in Swift, applying softmax to compute probabilities and determine the predicted class.

## License

iOS Application is Developed by Isaac Khor 
MIT License
