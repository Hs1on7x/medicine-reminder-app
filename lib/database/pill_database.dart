import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pill.dart';

class PillDatabase {
  static final PillDatabase _instance = PillDatabase._internal();
  static Database? _database;

  factory PillDatabase() => _instance;

  PillDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'pills_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        image TEXT,
        color INTEGER,
        times TEXT,
        days TEXT,
        isActive INTEGER,
        lastTaken TEXT
      )
    ''');
  }

  Future<int> insertPill(Pill pill) async {
    final db = await database;
    return await db.insert(
      'pills',
      pill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Pill>> getAllPills() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pills');
    return List.generate(maps.length, (i) {
      return Pill.fromMap(maps[i]);
    });
  }

  Future<Pill?> getPill(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pills',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Pill.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePill(Pill pill) async {
    final db = await database;
    return await db.update(
      'pills',
      pill.toMap(),
      where: 'id = ?',
      whereArgs: [pill.id],
    );
  }

  Future<int> deletePill(int id) async {
    final db = await database;
    return await db.delete(
      'pills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 