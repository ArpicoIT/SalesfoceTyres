
import '../../../shared/enum.dart';
import '../db_tables.dart';
import '../db_columns.dart';

class TaskTable {
  static const table = DBTables.TASKS;

  static final create = '''
  CREATE TABLE IF NOT EXISTS $table(
    ${DBColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DBColumns.SBU_CODE} TEXT,
    ${DBColumns.LOC_CODE} TEXT,
    ${DBColumns.USER_ID} TEXT,
    ${DBColumns.REMARK} TEXT,
    ${DBColumns.MSTAT} TEXT DEFAULT 'OPEN',
    ${DBColumns.SYNSTS} TEXT DEFAULT ${SyncStatus.NONE.name},
    ${DBColumns.CREATED_BY} TEXT,
    ${DBColumns.CREATED_AT} TEXT,
    ${DBColumns.UPDATED_BY} TEXT,
    ${DBColumns.UPDATED_AT} TEXT
  )
  ''';
}
