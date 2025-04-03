import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pill.dart';

class Repository {
  static const String tableName = 'pills';
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'medicine_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $tableName(
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
          ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Drop the old table and create a new one
          await db.execute('DROP TABLE IF EXISTS $tableName');
          await db.execute(
            '''
            CREATE TABLE $tableName(
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
            ''',
          );
        }
      },
    );
  }

  Future<int> addPill(Pill pill) async {
    final db = await database;
    return await db.insert(
      tableName,
      pill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Pill>> getAllPills() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Pill.fromMap(maps[i]);
    });
  }

  Future<Pill?> getPillById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
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
      tableName,
      pill.toMap(),
      where: 'id = ?',
      whereArgs: [pill.id],
    );
  }

  Future<int> deletePill(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllPills() async {
    final db = await database;
    await db.delete(tableName);
  }
} 