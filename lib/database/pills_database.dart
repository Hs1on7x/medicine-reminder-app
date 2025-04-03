import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pill.dart';

class PillsDatabase {
  static final PillsDatabase instance = PillsDatabase._init();
  static Database? _database;

  PillsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pills.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop the old table and create a new one
      await db.execute('DROP TABLE IF EXISTS pills');
      await _createDB(db, newVersion);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE pills(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      image TEXT,
      color INTEGER NOT NULL,
      times TEXT NOT NULL,
      days TEXT NOT NULL,
      isActive INTEGER NOT NULL,
      lastTaken TEXT
    )
    ''');
  }

  Future<Pill> create(Pill pill) async {
    final db = await instance.database;
    final id = await db.insert('pills', pill.toMap());
    return pill.copyWith(id: id);
  }

  Future<Pill> readPill(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'pills',
      columns: ['id', 'name', 'description', 'image', 'color', 'times', 'days', 'isActive', 'lastTaken'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Pill.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Pill>> readAllPills() async {
    final db = await instance.database;
    final result = await db.query('pills');
    return result.map((json) => Pill.fromMap(json)).toList();
  }

  Future<int> update(Pill pill) async {
    final db = await instance.database;
    print('Updating pill in database: ID=${pill.id}, Name=${pill.name}');
    print('Pill data: ${pill.toMap()}');
    
    return db.update(
      'pills',
      pill.toMap(),
      where: 'id = ?',
      whereArgs: [pill.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'pills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
} 