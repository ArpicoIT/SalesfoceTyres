import '../db_tables.dart';
import '../db_columns.dart';

class BankBranchTable {
  static const table = DBTables.BANKS_BRANCHES;

  static final create = '''
  CREATE TABLE IF NOT EXISTS $table(
    ${DBColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DBColumns.SBU_CODE} VARCHAR(5),
    ${DBColumns.LOC_CODE} VARCHAR(5),
    ${DBColumns.BANK_CODE} VARCHAR(10),
    ${DBColumns.BRANCH_CODE} VARCHAR(10),
    ${DBColumns.BRANCH_NAME} VARCHAR(100),
    ${DBColumns.CREATED_BY} VARCHAR(16),
    ${DBColumns.CREATED_AT} TEXT
  )
  ''';
}