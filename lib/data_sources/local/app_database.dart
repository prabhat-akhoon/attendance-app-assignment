import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/constants.dart';

/// Owns the single sqflite connection for the app. This is the one
/// intentional singleton in the codebase — every other data source takes
/// a [Database] (or this holder) via constructor injection.
class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, kDatabaseName);

    return openDatabase(
      path,
      version: kDatabaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE app_users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        staff_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE staff (
        id TEXT PRIMARY KEY,
        employee_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        face_enrolled_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE face_embeddings (
        id TEXT PRIMARY KEY,
        staff_id TEXT UNIQUE NOT NULL,
        embedding TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (staff_id) REFERENCES staff (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance_records (
        id TEXT PRIMARY KEY,
        staff_id TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        selfie_path TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        match_score REAL NOT NULL,
        FOREIGN KEY (staff_id) REFERENCES staff (id) ON DELETE CASCADE
      )
    ''');

    await db.insert('app_users', {
      'id': 'seed-admin',
      'username': kSeedAdminUsername,
      'password': kSeedAdminPassword,
      'role': 'admin',
      'staff_id': null,
    });
  }
}
