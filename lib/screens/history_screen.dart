import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:agri_ai_uganda/services/database_helper.dart';
import 'package:agri_ai_uganda/utils/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _dbHelper.getDetections();
    if(mounted) {
      setState(() {
         _history = data;
         _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detection History')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _history.isEmpty
            ? const Center(child: Text("No records found."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: item['imagePath'] != null && File(item['imagePath']).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(item['imagePath']), width: 50, height: 50, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(item['diseaseName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('MMM d, y h:mm a').format(DateTime.parse(item['date']))),
                      trailing: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: (item['confidence'] ?? 0.0) > 0.8 ? Colors.red[100] : Colors.green[100],
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: Text(
                             "${((item['confidence'] ?? 0) * 100).toStringAsFixed(0)}%",
                             style: TextStyle(
                                 color: (item['confidence'] ?? 0.0) > 0.8 ? Colors.red : Colors.green,
                                 fontWeight: FontWeight.bold,
                                 fontSize: 12
                             )
                         ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadHistory,
        backgroundColor: AppColors.earthBrown,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
