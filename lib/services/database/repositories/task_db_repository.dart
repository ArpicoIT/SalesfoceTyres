import 'package:arpicoiam/iam.dart';

import '../db_columns.dart';
import '../db_constants.dart';
import '../db_helper.dart';
import '../db_tables.dart';

class TaskDbRepository {
  TaskDbRepository._();

  /// Insert a new task
  static Future<int> insert(UserModel currentUser,{
    required String remark,
  }) async {
    final now = DateTime.now().toIso8601String();

    return DBHelper.insert(DBTables.TASKS, {
      DBColumns.SBU_CODE: currentUser.sbuCode,
      DBColumns.LOC_CODE: currentUser.locCode,
      DBColumns.USER_ID: currentUser.userId,
      DBColumns.REMARK: remark,
      DBColumns.MSTAT: DBConstants.TASK_OPEN,
      DBColumns.CREATED_BY: currentUser.userId,
      DBColumns.CREATED_AT: now,
    });
  }

  /// Get all tasks (optionally filtered by status)
  static Future<List<Map<String, dynamic>>> getAll(UserModel currentUser, {
    String? status,
  }) async {
    if (status != null && status != 'All') {
      return DBHelper.query(
        DBTables.TASKS,
        where: '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? AND ${DBColumns.MSTAT} = ?',
        whereArgs: [currentUser.sbuCode, currentUser.locCode, status],
        orderBy: '${DBColumns.CREATED_AT} DESC',
      );
    }

    return DBHelper.query(
      DBTables.TASKS,
      where: '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ?',
      whereArgs: [currentUser.sbuCode, currentUser.locCode],
      orderBy: '${DBColumns.CREATED_AT} DESC',
    );
  }

  /// Update task status
  static Future<int> updateStatus(UserModel currentUser, {
    required int id,
    required String status,
  }) async {
    return DBHelper.update(
      DBTables.TASKS,
      values: {
        DBColumns.MSTAT: status,
        DBColumns.UPDATED_BY: currentUser.userId,
        DBColumns.UPDATED_AT: DateTime.now().toIso8601String(),
      },
      where: '${DBColumns.ID} = ?',
      whereArgs: [id],
    );
  }

  /// Delete a task
  static Future<int> delete(int id) async {
    return DBHelper.delete(
      DBTables.TASKS,
      where: '${DBColumns.ID} = ?',
      whereArgs: [id],
    );
  }

  /// Count tasks by status
  static Future<Map<String, int>> getStatusCounts(UserModel currentUser) async {
    final all = await getAll(currentUser);

    return {
      'total': all.length,
      DBConstants.TASK_OPEN: all.where((e) => e[DBColumns.MSTAT] == DBConstants.TASK_OPEN).length,
      DBConstants.TASK_IN_PROGRESS: all.where((e) => e[DBColumns.MSTAT] == DBConstants.TASK_IN_PROGRESS).length,
      DBConstants.TASK_CLOSED: all.where((e) => e[DBColumns.MSTAT] == DBConstants.TASK_CLOSED).length,
    };
  }
}
