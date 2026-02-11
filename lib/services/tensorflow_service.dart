import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agri_ai_uganda/models/crop_disease.dart';

class TensorFlowService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> loadModel() async {
    try {
      // Load model
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
      
      // Load labels
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData.split('\n');
    } catch (e) {
      print("Error loading model or labels: $e");
      // Fallback for placeholder
      _labels = ["Healthy", "Unknown"];
    }
  }

  Future<CropDisease?> classifyImage(String imagePath) async {
    if (_interpreter == null) {
      await loadModel();
    }

    // Mock inference for placeholder model
    // In a real app, we would process valid image bytes here.
    // Since we have a dummy .tflite, running it might crash or fail.
    // We will simulate a result for the MVP demo purposes unless provided with a real model.
    
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Randomly pick a disease for demo if model fails or is dummy
    // REAL LOGIC:
    /*
    var inputImage = File(imagePath).readAsBytesSync();
    // Pre-process input
    var output = List.filled(1 * 15, 0).reshape([1, 15]);
    _interpreter!.run(input, output);
    // parse output to find max
    */
    
    // DEMO LOGIC:
    return CropDisease.fromName(_labels.length > 2 ? _labels[2] : "Maize Streak Virus", 0.95);
  }
  
  void close() {
    _interpreter?.close();
  }
}
