import '../db_tables.dart';
import '../db_columns.dart';

class CreditNoteTable {
  static const table = DBTables.CREDIT_NOTES;

  static final create = '''
  CREATE TABLE IF NOT EXISTS $table(
    ${DBColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DBColumns.SBU_CODE} VARCHAR(5),
    ${DBColumns.LOC_CODE} VARCHAR(5),
    ${DBColumns.LOC_NAME} VARCHAR(255),
    ${DBColumns.DOC_CODE} VARCHAR(10),
    ${DBColumns.DOC_NO} VARCHAR(10),
    ${DBColumns.CS_CODE} VARCHAR(10),
    ${DBColumns.REP_ID} VARCHAR(30),
    ${DBColumns.TXN_DATE} DATE,
    ${DBColumns.ORIGINAL_AMOUNT} DECIMAL(14,4) NOT NULL,
    ${DBColumns.DUE_AMOUNT} DECIMAL(14,4) NOT NULL,
    ${DBColumns.BALANCE_AMOUNT} DECIMAL(14,4) NOT NULL, 
    ${DBColumns.SETOFF_AMOUNT} DECIMAL(14,4) NOT NULL,
    ${DBColumns.ROWSTS} VARCHAR(3) NOT NULL,
    ${DBColumns.SYNSTS} VARCHAR(4) NOT NULL,
    ${DBColumns.CREATED_BY} VARCHAR(16),
    ${DBColumns.CREATED_AT} TEXT
  )
  ''';

  // ${DBColumns.SYNSTS} VARCHAR(4) NOT NULL DEFAULT ${SyncStatus.NONE.name},
}