import 'package:flutter/material.dart';

class PestDetectionScreen extends StatelessWidget {
  const PestDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pest Detection')),
      body: const Center(child: Text('Camera View Here')),
    );
  }
}
