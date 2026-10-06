import '../../../models/download_model.dart';
import '../db_columns.dart';
import '../db_helper.dart';

class DownloadDbRepository {
  DownloadDbRepository._();

  static Future<void> replaceDownloadData(
    String tableName,
    List<Map<String, dynamic>> data,
  ) async {
    await DBHelper.batchReplace(
      tableName,
      data,
    ); // conflictAlgorithm: ConflictAlgorithm.replace
  }

  static Future<void> insertDownloadData(
    String tableName,
    List<Map<String, dynamic>> data,
  ) async {
    if (data.isEmpty) {
      return;
    }

    await DBHelper.batchInsert(tableName, data);
  }

  static Future<void> clearDownloadData(List<String> tables) async =>
      await DBHelper.clearTables(tables);

  static Future<DownloadMetadata> getDownloadMetadata(String tableName) async {
    final result = await DBHelper.rawQuery('''
    SELECT
      COUNT(*) AS total,
      MAX(${DBColumns.CREATED_AT}) AS last_download_at
    FROM $tableName
    ''');

    if (result.isEmpty) {
      return DownloadMetadata(table: tableName, count: 0, lastDownloadAt: null);
    }

    final row = result.first;

    final total = (row['total'] as num?)?.toInt() ?? 0;
    final lastDownloadAtString = row['last_download_at']?.toString();

    return DownloadMetadata(
      table: tableName,
      count: total,
      lastDownloadAt: lastDownloadAtString == null
          ? null
          : DateTime.tryParse(lastDownloadAtString),
    );
  }

  // static Future<void> clearAllDownloadData() async {
  //   await DBHelper.clearTables([
  //     DBTables.PROGRAM_PARA,
  //     DBTables.CUSTOMERS,
  //     DBTables.INVOICES,
  //     DBTables.CREDIT_NOTES,
  //     DBTables.BANKS,
  //     DBTables.BANKS_BRANCHES,
  //   ]);
  // }
}

/*static Future<void> updateParams(UserModel currentUser, {
    int total = 0,
    required String paraCode,
    required String paraName,
  }) async {
    final db = AppDatabase.instance.database;
    final table = DBTables.PROGRAM_PARA;

    final String userId = currentUser.userId ?? '';
    final String sbuCode = currentUser.sbuCode ?? '';
    final String locCode = currentUser.locCode ?? '';
    final String lastDownloadAt = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      final batch = txn.batch();

      final existing = await txn.query(
        table,
        where:
            '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? AND ${DBColumns.PARA_CODE} = ?',
        whereArgs: [sbuCode, locCode, paraCode],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        // EXIST → update using copyWith
        final updatedModel = ProgramParaModel.fromJson(existing.first).copyWith(
          // you can merge DB + new model if needed
          // example:
          // someField: existing.first['someField']
          comment: '$lastDownloadAt;$total',
        );

        batch.update(
          table,
          updatedModel.toJson(),
          where:
              '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? AND ${DBColumns.PARA_CODE} = ?',
          whereArgs: [sbuCode, locCode, paraCode],
        );
      } else {
        // NOT EXIST → insert
        batch.insert(
          table,
          ProgramParaModel(
            sbuCode: sbuCode,
            locCode: locCode,
            paraCode: paraCode,
            comment: '$lastDownloadAt;$total',
            userId: userId,
            paraName: paraName,
            logdat: DateTime.now(),
            lockin: DateTime.now().millisecondsSinceEpoch,
            createdBy: userId,
            createdAt: DateTime.now(),
          ).toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  static Future<List<ProgramParaModel>> getParams(UserModel currentUser, {
    required List<String> paraCodes,
  }) async {
    final db = AppDatabase.instance.database;
    final table = DBTables.PROGRAM_PARA;

    final String userId = currentUser.userId ?? '';
    final String sbuCode = currentUser.sbuCode ?? '';
    final String locCode = currentUser.locCode ?? '';

    if (paraCodes.isEmpty) return [];

    final placeholders = paraCodes.map((_) => '?').join(',');

    final result = await db.query(
      table,
      where:
          '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? AND ${DBColumns.USER_ID} = ? AND ${DBColumns.PARA_CODE} IN ($placeholders)',
      whereArgs: [sbuCode, locCode, userId, ...paraCodes],
    );

    return ModelHelper.jsonListToModelList(
      result,
      (json) => ProgramParaModel.fromJson(json),
    );
  }*/
