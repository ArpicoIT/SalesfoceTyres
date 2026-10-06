import '../../../shared/enum.dart';
import '../db_tables.dart';
import '../db_columns.dart';

class CollectionDetailTable {
  static const table = DBTables.COLLECTION_DETAILS;

  static final create = '''
  CREATE TABLE IF NOT EXISTS $table(
    ${DBColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DBColumns.SBU_CODE} VARCHAR(5) NOT NULL,
    ${DBColumns.LOC_CODE} VARCHAR(5) NOT NULL,
    ${DBColumns.DOC_CODE} VARCHAR(10),
    ${DBColumns.DOC_NO} VARCHAR(10),
    ${DBColumns.SEQ_NO} INT(3) NOT NULL,
    ${DBColumns.REC_DOC} VARCHAR(10),
    ${DBColumns.REC_NO} VARCHAR(10),
    ${DBColumns.INV_DOC} VARCHAR(10),
    ${DBColumns.INV_NO} VARCHAR(10),
    ${DBColumns.SETOFF_AMOUNT} DECIMAL(14,4) NOT NULL,
    ${DBColumns.DISCOUNT} DECIMAL(6,2) NOT NULL,
    ${DBColumns.TXN_DATE} DATE,
    ${DBColumns.SYNSTS} VARCHAR(4) NOT NULL DEFAULT ${SyncStatus.NONE.name},
    ${DBColumns.CREATED_BY} VARCHAR(16),
    ${DBColumns.CREATED_AT} TEXT
  )
  ''';
}