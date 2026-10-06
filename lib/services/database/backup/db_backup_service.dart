/// lib/database/backup/db_backup_service.dart
library;

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../app_database.dart';
import '../db_constants.dart';

class DBBackupService {
  Future<File> createBackup() async {
    final dbPath = AppDatabase.instance.databasePath;

    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      throw Exception('Database file not found');
    }

    final backupDir = await _getBackupDirectory();

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final backupName = generateBackupName();

    final backupPath = join(
      backupDir.path,
      backupName,
    );

    return dbFile.copy(backupPath);
  }

  String generateBackupName() {
    final date = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    return 'backup_$date${DBConstants.backupExtension}';
  }

  Future<Directory> _getBackupDirectory() async {
    final directory = await getApplicationDocumentsDirectory();

    return Directory(
      join(
        directory.path,
        DBConstants.backupFolderName,
      ),
    );
  }

  Future<List<FileSystemEntity>> getBackups() async {
    final backupDir = await _getBackupDirectory();

    if (!await backupDir.exists()) {
      return [];
    }

    return backupDir.listSync()
      ..sort(
            (a, b) => b.statSync().modified.compareTo(
          a.statSync().modified,
        ),
      );
  }

  Future<void> deleteBackup(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> restore(File backupFile) async {
    if (!await backupFile.exists()) {
      throw Exception('Backup file not found');
    }

    final dbPath = AppDatabase.instance.databasePath;

    final dbFile = File(dbPath);

    /// close current database
    await AppDatabase.instance.close();

    /// delete old database
    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    /// restore backup
    await backupFile.copy(dbPath);

    /// reopen initialize database
    await AppDatabase.instance.initialize();
  }
}