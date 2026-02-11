import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:agri_ai_uganda/services/tensorflow_service.dart';
import 'package:agri_ai_uganda/models/crop_disease.dart';
import 'package:agri_ai_uganda/utils/constants.dart';
import 'package:agri_ai_uganda/services/database_helper.dart';

class PestDetectionScreen extends StatefulWidget {
  const PestDetectionScreen({super.key});

  @override
  State<PestDetectionScreen> createState() => _PestDetectionScreenState();
}

class _PestDetectionScreenState extends State<PestDetectionScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final TensorFlowService _tfService = TensorFlowService();
  bool _isScanning = false;
  CropDisease? _result;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _tfService.loadModel();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _tfService.close();
    super.dispose();
  }

  Future<void> _scanLeaf() async {
    try {
      setState(() => _isScanning = true);
      await _initializeControllerFuture;

      final image = await _controller!.takePicture();

      if (!mounted) return;

      final disease = await _tfService.classifyImage(image.path);

      if (disease != null) {
        await DatabaseHelper().insertDetection({
          'diseaseName': disease.name,
          'confidence': disease.confidence,
          'date': DateTime.now().toIso8601String(),
          'imagePath': image.path,
        });
      }

      setState(() {
        _isScanning = false;
        _result = disease;
      });
      
      if (_result != null) {
        _showResultDialog(_result!);
      }

    } catch (e) {
      print(e);
      setState(() => _isScanning = false);
    }
  }

  void _showResultDialog(CropDisease disease) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              disease.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.darkBrown,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Utils.severityColor(disease.confidence),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Confidence: ${(disease.confidence * 100).toStringAsFixed(1)}%",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text("Treatment", style: Theme.of(context).textTheme.titleLarge),
            Text(disease.treatment),
             const SizedBox(height: 16),
            Text("Local Remedy (Luganda)", style: Theme.of(context).textTheme.titleLarge),
             Text(disease.localRemedy, style: const TextStyle(fontStyle: FontStyle.italic)),
             const SizedBox(height: 32),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: () => Navigator.pop(context),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppColors.primaryGreen,
                   padding: const EdgeInsets.symmetric(vertical: 16),
                 ),
                 child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 18)),
               ),
             )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: _isScanning ? null : _scanLeaf,
                backgroundColor: AppColors.primaryGreen,
                child: _isScanning
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Point camera at a leaf",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Utils {
   static Color severityColor(double confidence) {
     if(confidence > 0.8) return Colors.red;
     if(confidence > 0.5) return Colors.orange;
     return Colors.green;
   }
}
