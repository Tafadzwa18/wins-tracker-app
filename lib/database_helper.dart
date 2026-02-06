import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._int();
  static Database? _database;

  DatabaseHelper._int();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wins.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wins(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        tag TEXT,
        isFavorite INTEGER DEFAULT 0
      )
    ''');
  }

  // CREATE - Add a new win
  Future<int> insertWin(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('wins', row);
  }

  // READ - This is what your Timeline was missing!
  Future<List<Map<String, dynamic>>> queryAllWins() async {
    Database db = await instance.database;
    return await db.query('wins', orderBy: 'timestamp DESC');
  }

  // Update the favorite status of a win
    Future<int> toggleFavorite(int id, bool isCurrentlyFavorite) async {
    Database db = await instance.database;
    return await db.update(
      'wins',
      {'isFavorite': isCurrentlyFavorite ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a specific win by ID
  Future<int> deleteWin(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'wins',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
}