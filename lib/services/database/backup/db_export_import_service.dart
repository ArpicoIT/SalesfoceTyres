/// lib/database/backup/db_export_import_service.dart
library;

import 'package:sqflite/sqflite.dart';

import '../app_database.dart';
import '../db_tables.dart';

class DBExportImportService {
  Future<Map<String, dynamic>> exportJson() async {
    final db = AppDatabase.instance.database;

    final result = <String, dynamic>{};

    final tables = [
      DBTables.USERS,
      DBTables.TASKS,
      DBTables.INQUIRIES,
      DBTables.COLLECTIONS,
    ];

    for (final table in tables) {
      final data = await db.query(table);

      result[table] = data;
    }

    return result;
  }

  Future<void> importJson(
      Map<String, dynamic> json,
      ) async {
    final db = AppDatabase.instance.database;

    final batch = db.batch();

    for (final entry in json.entries) {
      final table = entry.key;

      final rows = List<Map<String, dynamic>>.from(
        entry.value,
      );

      /// clear existing data
      batch.delete(table);

      /// insert imported rows
      for (final row in rows) {
        batch.insert(
          table,
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(
      noResult: true,
    );
  }
}