import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/verse.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'scripture_memorizer.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT NOT NULL,
        book TEXT NOT NULL,
        text TEXT NOT NULL,
        translation TEXT NOT NULL,
        familiarityScore INTEGER NOT NULL DEFAULT 0,
        lastReviewed TEXT,
        nextReviewDue TEXT,
        consecutiveCorrect INTEGER NOT NULL DEFAULT 0,
        timesStruggled INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');
    
    // Seed database
    for (var verse in seedVerses) {
      await db.insert('verses', verse.toMap());
    }
  }

  Future<int> insertVerse(Verse verse) async {
    Database db = await database;
    return await db.insert('verses', verse.toMap());
  }

  Future<int> updateVerse(Verse verse) async {
    Database db = await database;
    return await db.update(
      'verses',
      verse.toMap(),
      where: 'id = ?',
      whereArgs: [verse.id],
    );
  }

  Future<Verse?> getVerseById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'verses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Verse.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Verse>> getAllVerses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('verses');
    return List.generate(maps.length, (i) {
      return Verse.fromMap(maps[i]);
    });
  }

  Future<List<Verse>> getWeakestVerses(int limit) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'verses',
      orderBy: 'familiarityScore ASC',
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return Verse.fromMap(maps[i]);
    });
  }

  Future<List<Verse>> getOverdueVerses() async {
    Database db = await database;
    String now = DateTime.now().toIso8601String();
    List<Map<String, dynamic>> maps = await db.query(
      'verses',
      where: 'nextReviewDue <= ?',
      whereArgs: [now],
    );
    return List.generate(maps.length, (i) {
      return Verse.fromMap(maps[i]);
    });
  }

  Future<List<Verse>> getVersesByFamiliarity(int minScore, int maxScore, {int? limit}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'verses',
      where: 'familiarityScore >= ? AND familiarityScore <= ?',
      whereArgs: [minScore, maxScore],
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return Verse.fromMap(maps[i]);
    });
  }

  Future<void> resetAllVerses() async {
    Database db = await database;
    await db.update('verses', {
      'familiarityScore': 0,
      'lastReviewed': null,
      'nextReviewDue': null,
      'consecutiveCorrect': 0,
      'timesStruggled': 0,
      'isActive': 1,
    });
  }
}
