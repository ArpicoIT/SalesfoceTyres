import '../../../shared/enum.dart';
import '../db_tables.dart';
import '../db_columns.dart';

class CollectionHeaderTable {
  static const table = DBTables.COLLECTION_HEADERS;

  static final create = '''
  CREATE TABLE IF NOT EXISTS $table(
    ${DBColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DBColumns.SBU_CODE} VARCHAR(5) NOT NULL,
    ${DBColumns.LOC_CODE} VARCHAR(5),
    ${DBColumns.DOC_CODE} VARCHAR(10) NOT NULL,
    ${DBColumns.DOC_NO} VARCHAR(10) NOT NULL,
    ${DBColumns.CS_CODE} VARCHAR(10) NOT NULL,
    ${DBColumns.PAY_MODE} VARCHAR(10) NOT NULL,
    ${DBColumns.TOTAL_AMOUNT} DECIMAL(14,4) NOT NULL,
    ${DBColumns.CHQ_NO} VARCHAR(255),
    ${DBColumns.CHQ_DATE} DATE,
    ${DBColumns.BANK_CODE} VARCHAR(255),
    ${DBColumns.BRANCH_CODE} VARCHAR(255),
    ${DBColumns.DD_REF_NO} VARCHAR(50),
    ${DBColumns.REMARK} VARCHAR(255),
    ${DBColumns.GPS_LAT} REAL,
    ${DBColumns.GPS_LNG} REAL,
    ${DBColumns.TXN_DATE} DATE,
    ${DBColumns.SYNSTS} VARCHAR(4) NOT NULL DEFAULT ${SyncStatus.NONE.name},
    ${DBColumns.DEPOSITED} INTEGER NOT NULL DEFAULT ${0},
    ${DBColumns.TAB_CODE} VARCHAR(10),
    ${DBColumns.CREATED_BY} VARCHAR(16),
    ${DBColumns.CREATED_AT} TEXT
  )
  ''';

  // previous
  // ${DBColumns.GPS_LAT VARCHAR(45)
}