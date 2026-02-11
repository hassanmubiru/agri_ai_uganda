import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img; // Needs 'image' package
import 'package:agri_ai_uganda/models/crop_disease.dart';

class TensorFlowService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
      _isModelLoaded = true;
      print("Model loaded successfully. Labels count: ${_labels.length}");
    } catch (e) {
      print("Error loading model or labels: $e");
    }
  }

  Future<CropDisease?> classifyImage(String imagePath) async {
    if (!_isModelLoaded) await loadModel();
    if (_interpreter == null) return null;

    try {
      // 1. Read and decode image
      final imageData = File(imagePath).readAsBytesSync();
      img.Image? originalImage = img.decodeImage(imageData);
      if (originalImage == null) return null;

      // 2. Resize to 224x224 (Standard for MobileNet/ResNet)
      img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

      // 3. Convert to Float32 List [1, 224, 224, 3] and Normalize
      var input = Float32List(1 * 224 * 224 * 3);
      var buffer = Float32List.view(input.buffer);
      int pixelIndex = 0;
      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          var pixel = resizedImage.getPixel(x, y);
          // Normalize pixel values to [0, 1]
          buffer[pixelIndex++] = pixel.r / 255.0;
          buffer[pixelIndex++] = pixel.g / 255.0;
          buffer[pixelIndex++] = pixel.b / 255.0;
        }
      }

      // 4. Run Inference
      // Output shape: [1, num_classes]
      var output = List<double>.filled(_labels.length, 0).reshape([1, _labels.length]);
      final isolateInterpreter = await IsolateInterpreter.create(address: _interpreter!.address);
      await isolateInterpreter.run(input.reshape([1, 224, 224, 3]), output);

      // 5. Parse Results
      List<double> probabilities = List<double>.from(output[0]);
      int maxIndex = 0;
      double maxScore = 0;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxScore) {
          maxScore = probabilities[i];
          maxIndex = i;
        }
      }
      
      String diseaseName = _labels.length > maxIndex ? _labels[maxIndex] : "Unknown";
      
      // Clean up label name (e.g. "corn maize healthy" -> "Corn (Healthy)")
      diseaseName = _formatLabel(diseaseName);

      return CropDisease.fromName(diseaseName, maxScore);

    } catch (e) {
      print("Inference Error: $e");
      return null;
    }
  }
  
  String _formatLabel(String label) {
     // Simple formatter to make labels more readable
     // e.g. "corn maize common rust" -> "Corn (Common Rust)"
     return label.trim().toUpperCase(); 
  }

  void close() {
    _interpreter?.close();
  }
}
