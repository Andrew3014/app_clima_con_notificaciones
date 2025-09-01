import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'favorites.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favorites(id INTEGER PRIMARY KEY, city TEXT UNIQUE)',
        );
      },
      version: 1,
    );
  }

  static Future<void> addFavorite(String city) async {
    final db = await database;
    await db.insert('favorites', {'city': city},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> removeFavorite(String city) async {
    final db = await database;
    await db.delete('favorites', where: 'city = ?', whereArgs: [city]);
  }

  static Future<List<String>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) => maps[i]['city'] as String);
  }
}

