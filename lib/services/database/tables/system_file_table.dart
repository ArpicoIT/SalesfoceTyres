import '../db_tables.dart';
import '../db_columns.dart';

class SystemFileTable {
  static const table = DBTables.SYSTEM_FILES;

  static const create = '''
  CREATE TABLE IF NOT EXISTS $table(
    ${DBColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DBColumns.SBU_CODE} VARCHAR(5),
    ${DBColumns.LOC_CODE} VARCHAR(5),
    ${DBColumns.USER_ID} VARCHAR(16),
    ${DBColumns.PARA_CODE} VARCHAR(100),
    ${DBColumns.PARA_NAME} VARCHAR(100),
    ${DBColumns.COMMENT} VARCHAR(255),
    ${DBColumns.CREATED_BY} VARCHAR(16),
    ${DBColumns.CREATED_AT} TEXT
  )
  ''';

  // ${DBColumns.LOGDAT} DATETIME,
  // ${DBColumns.LOCKIN} DATETIME,
}

