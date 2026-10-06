import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'db_constants.dart';
import 'db_migrations.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _database;
  String? _databasePath;

  Future<void> initialize() async {
    _databasePath ??= await _initializeDBPath();
    _database ??= await _initializeDb();
  }

  String get databasePath {
    if (_databasePath == null) {
      throw Exception(
        'AppDatabase Path not initialized',
      );
    }
    return _databasePath!;
  }

  Database get database {
    if (_database == null) {
      throw Exception(
        'AppDatabase not initialized',
      );
    }

    return _database!;
  }

  Future<Database> _initializeDb() async {
    return openDatabase(
      databasePath,
      version: DBConstants.databaseVersion,
      onCreate: DBMigrations.onCreate,
      onUpgrade: DBMigrations.onUpgrade,
    );
  }

  Future<String> _initializeDBPath() async {
    return join(
      await getDatabasesPath(),
      DBConstants.databaseName,
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> deleteDatabaseFile() async {
    await close();

    await deleteDatabase(databasePath);
  }
}