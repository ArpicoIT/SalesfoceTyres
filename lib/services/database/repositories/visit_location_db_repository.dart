import 'package:arpicoiam/iam.dart';
import 'package:intl/intl.dart';

import '../../../models/visit_model.dart';
import '../../../helpers/date_time_helper.dart';
import '../../../helpers/json_helper.dart';
import '../db_columns.dart';
import '../db_helper.dart';
import '../db_tables.dart';
import '../../../shared/enum.dart';

class VisitLocationDbRepository {
  VisitLocationDbRepository._();

  /// Insert a visit location record
  static Future<VisitModel> insert(UserModel currentUser, VisitModel visit) async {
    visit = visit.copyWith(
      sbuCode: currentUser.sbuCode,
      locCode: currentUser.locCode,
      tabCode: currentUser.tabCode,
      txnDate: DateTimeHelper.getTxnDate(),
      synSts: .PEND,
      createdBy: currentUser.userId,
      createdAt: DateTimeHelper.getDateTime(),
    );
    final id = await DBHelper.insert(DBTables.VISIT_LOCATIONS, visit.toSqlJson());
    return visit.copyWith(id: id);
  }

  static Future<List<VisitModel>> getTodayVisits(UserModel currentUser) async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await DBHelper.query(
      DBTables.VISIT_LOCATIONS,
      where:
          '''${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? AND ${DBColumns.CREATED_BY} = ? AND ${DBColumns.TXN_DATE} = ?''',
      whereArgs: [currentUser.sbuCode, currentUser.locCode, currentUser.userId, today],
      orderBy: '${DBColumns.CREATED_AT} DESC',
    );

    return JsonHelper.jsonListToModelList(result, VisitModel.fromJson);
  }

  /// Get all visit locations
  static Future<List<Map<String, dynamic>>> getAll(
    UserModel currentUser,
  ) async {
    return DBHelper.query(
      DBTables.VISIT_LOCATIONS,
      where: '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ?',
      whereArgs: [currentUser.sbuCode, currentUser.locCode],
      orderBy: '${DBColumns.CREATED_AT} DESC',
    );
  }

  /// Get visit locations by date range
  static Future<List<Map<String, dynamic>>> getByDateRange(
    UserModel currentUser, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = DateFormat('yyyy-MM-dd').format(startDate);
    final end = DateFormat('yyyy-MM-dd').format(endDate);

    return DBHelper.query(
      DBTables.VISIT_LOCATIONS,
      where:
          '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? '
          'AND ${DBColumns.TXN_DATE} >= ? AND ${DBColumns.TXN_DATE} <= ?',
      whereArgs: [currentUser.sbuCode, currentUser.locCode, start, end],
      orderBy: '${DBColumns.CREATED_AT} DESC',
    );
  }

  /// Get pending/failed visit locations for sync
  static Future<List<Map<String, dynamic>>> getPendingSync(
    UserModel currentUser,
  ) async {
    return DBHelper.query(
      DBTables.VISIT_LOCATIONS,
      where:
          '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? '
          'AND (${DBColumns.SYNSTS} = ? OR ${DBColumns.SYNSTS} = ?)',
      whereArgs: [
        currentUser.sbuCode,
        currentUser.locCode,
        SyncStatus.PEND.name,
        SyncStatus.FAIL.name,
      ],
      orderBy: '${DBColumns.CREATED_AT} DESC',
    );
  }

  /// Update sync status
  static Future<int> updateSyncStatus({
    required int id,
    required SyncStatus status,
  }) async {
    return DBHelper.update(
      DBTables.VISIT_LOCATIONS,
      values: {DBColumns.SYNSTS: status.name},
      columns: [DBColumns.SYNSTS],
      where: '${DBColumns.ID} = ?',
      whereArgs: [id],
    );
  }

  /// Get today's visit count
  static Future<int> getTodayCount(UserModel currentUser) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return DBHelper.count(
      DBTables.VISIT_LOCATIONS,
      where:
          '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? '
          'AND ${DBColumns.TXN_DATE} = ?',
      whereArgs: [currentUser.sbuCode, currentUser.locCode, today],
    );
  }
}
