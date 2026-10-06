class RoutePaths {
  RoutePaths._();
  /// Common base path
  static const String base = '/app';

  /// Routes

  static const String landing = '$base/landing';
  static const String home = '$base/home';

  static const String downloads = '$base/downloads';
  static const String sync = '$base/sync-data';
  static const String backupRestore = '$base/backup-restore';
  static const String collections = '$base/collections';
  static const String startCollection = '$base/start-collection';
  static const String receiptSetOff = '$base/start-collection/receipt-setoff';
  static const String bankDeposits = '$base/bank-deposits';
  static const String visitLocations = '$base/visit-locations';
  static const String inquiries = '$base/inquiries';
  static const String visitInquiry = '$base/inquiry-visit';
  static const String collectionInquiry = '$base/inquiry-collection';
  static const String invoiceInquiry = '$base/inquiry-invoice';
  static const String bankDepositInquiry = '$base/inquiry-bank-deposit';
  static const String tasks = '$base/tasks';
  static const String profile = '$base/profile';
  static const String settings = '$base/settings';
  static const String contactSupport = '$base/contact-support';
  static const String aboutUs = '$base/about-us';

  static const String dashboard = '$base/dashboard';
}