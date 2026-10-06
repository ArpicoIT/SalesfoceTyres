import '../../../shared/enum.dart';
import '../db_tables.dart';
import '../db_columns.dart';

class VisitLocationTable {
  static const table = DBTables.VISIT_LOCATIONS;

  static final create = '''
  CREATE TABLE IF NOT EXISTS $table(
    ${DBColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DBColumns.SBU_CODE} VARCHAR(5),
    ${DBColumns.LOC_CODE} VARCHAR(5),
    ${DBColumns.CS_CODE} VARCHAR(10),
    ${DBColumns.REMARK} VARCHAR(255),
    ${DBColumns.GPS_LAT} REAL,
    ${DBColumns.GPS_LNG} REAL,
    ${DBColumns.TXN_DATE} DATE,
    ${DBColumns.SYNSTS} VARCHAR(4) NOT NULL DEFAULT ${SyncStatus.NONE.name},
    ${DBColumns.TAB_CODE} VARCHAR(10),
    ${DBColumns.CREATED_BY} VARCHAR(16),
    ${DBColumns.CREATED_AT} TEXT
  )
  ''';
}
