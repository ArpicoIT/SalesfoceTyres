import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class DBHelper {
  DBHelper._();

  static Future<Database> get _db async => AppDatabase.instance.database;

  // INSERT
  static Future<int> insert(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    final db = await _db;

    return db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
  }

  // BATCH INSERT
  static Future<void> batchInsert(
    String table,
    List<Map<String, Object?>> values, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    if (values.isEmpty) return;

    final db = await _db;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final value in values) {
        batch.insert(table, value, conflictAlgorithm: conflictAlgorithm);
      }

      await batch.commit(noResult: true);
    });
  }

  // BATCH REPLACE (Clear table and insert new values)
  static Future<void> batchReplace(
    String table,
    List<Map<String, Object?>> values, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    final db = await _db;

    await db.transaction((txn) async {
      final batch = txn.batch();

      // Clear existing data
      batch.delete(table);

      // Insert new data
      for (final value in values) {
        batch.insert(table, value, conflictAlgorithm: conflictAlgorithm);
      }

      await batch.commit(noResult: true);
    });
  }

  // UPDATE
  static Future<int> update(
      String table, {
        required Map<String, Object?> values,
        List<String>? columns,
        required String? where,
        required List<Object?>? whereArgs,
        ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
      }) async {
    final db = await _db;

    final columnSet = columns?.toSet();

    final updateValues = columnSet == null || columnSet.isEmpty
        ? values
        : Map.fromEntries(
      values.entries.where(
            (entry) => columnSet.contains(entry.key),
      ),
    );

    return db.update(
      table,
      updateValues,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  // DELETE
  static Future<int> delete(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await _db;

    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  // CLEAR MULTIPLE TABLES
  static Future<void> clearTables(List<String> tables) async {
    if (tables.isEmpty) return;

    final db = await _db;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final table in tables) {
        batch.delete(table);
      }

      await batch.commit(noResult: true);
    });
  }

  // ROW QUERY
  static Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await _db;

    return db.rawQuery(sql, arguments);
  }

  // QUERY
  static Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
    String? groupBy,
  }) async {
    final db = await _db;

    return db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      groupBy: groupBy,
    );
  }

  // QUERY SINGLE
  static Future<Map<String, dynamic>?> querySingle(
    String table, {
    List<String>? columns,
    required String where,
    required List<Object?> whereArgs,
    String? groupBy,
  }) async {
    final result = await query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      limit: 1,
      groupBy: groupBy,
    );

    return result.isEmpty ? null : result.first;
  }

  // EXISTS
  static Future<bool> exists(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final result = await query(
      table,
      columns: ['1'],
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // COUNT
  static Future<int> count(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _db;

    final result = await db.rawQuery('''
      SELECT COUNT(*) AS count
      FROM $table
      ${where != null ? 'WHERE $where' : ''}
      ''', whereArgs);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // TRANSACTION
  static Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    final db = await _db;
    return db.transaction(action);
  }
}
