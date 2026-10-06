import '../db_tables.dart';
import '../db_columns.dart';

class CustomerTable {
  static const table = DBTables.CUSTOMERS;

  static const create = '''
  CREATE TABLE IF NOT EXISTS $table(
    ${DBColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DBColumns.SBU_CODE} VARCHAR(5),
    ${DBColumns.CS_CODE} VARCHAR(10),
    ${DBColumns.CS_NAME} VARCHAR(60),
    ${DBColumns.ADDRESS_1} VARCHAR(30),
    ${DBColumns.ADDRESS_2} VARCHAR(30),
    ${DBColumns.ADDRESS_3} VARCHAR(30),
    ${DBColumns.CITY} VARCHAR(30),
    ${DBColumns.MOBILE} VARCHAR(15),
    ${DBColumns.REP_ID} VARCHAR(30),
    ${DBColumns.CREDIT_LIMIT} DECIMAL(14,4) NOT NULL DEFAULT ${0},
    ${DBColumns.CREDIT_BALANCE} DECIMAL(14,4) NOT NULL DEFAULT ${0},
    ${DBColumns.CREATED_BY} VARCHAR(16),
    ${DBColumns.CREATED_AT} TEXT
  )
  ''';
}