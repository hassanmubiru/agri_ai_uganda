import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "agri_ai.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE detections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        diseaseName TEXT,
        confidence REAL,
        date TEXT,
        imagePath TEXT
      )
    ''');
  }

  Future<int> insertDetection(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('detections', row);
  }

  Future<List<Map<String, dynamic>>> getDetections() async {
    Database db = await database;
    return await db.query('detections', orderBy: "date DESC");
  }
}
