class DBConstants {
  static const String databaseName = 'salesforcetyres.db';
  static const int databaseVersion = 3;
  static const String backupFolderName = 'backup';
  static const String backupExtension = '.db';

  /// Download types
  static const String DOWN_SUSTEM_FILES = "SystemFiles";
  static const String DOWN_CUSTOMERS = "Customers";
  static const String DOWN_INVOICES = "Invoices";
  static const String DOWN_CREDIT_NOTES = "Credit-Notes";
  static const String DOWN_BANKS = "Banks";
  static const String DOWN_BANKS_BRANCHES = "Bank-Branches";

  static const String DOC_RCPD = "RCPD";
  static const String DOC_INVOICE = "INV";
  static const String DOC_CREDIT_NOTE = "CRDN";
  static const String DOC_DISCOUNT = "DISC";
  static const String DOC_CASH_DISCOUNT = "CASHDISC";
  static const String DOC_BULK_DISCOUNT = "BULKDISC";

  /// Task statuses
  static const String TASK_OPEN = 'OPEN';
  static const String TASK_IN_PROGRESS = 'IN_PROGRESS';
  static const String TASK_CLOSED = 'CLOSED';

  /// System constants
  // static const String SYS_MAX_DISCOUNT = 'maxDiscount';
  static const String SYS_MAX_CASH_DISCOUNT = 'maxCashDiscount';
  static const String SYS_MAX_BULK_DISCOUNT = 'maxBulkDiscount';
  static const String SYS_TRADING_DOC_CODES = 'tradingDocCodes';
  static const String SYS_NON_TRADING_DOC_CODES = 'nonTradingDocCodes';
  static const String SYS_MAX_CASH_LIMIT = 'maxCashLimit';
}
