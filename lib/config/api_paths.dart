
class ApiPaths {
  ApiPaths._();

  static const api = '';

  static final String downloadData = '$api/download';
  static final String collectionSummary = '$api/collection-summary';

  /// Receipt slips
  static final String uploadReceiptSlips = '$api/receipt-images';
  static final String downloadReceiptSlips = '$api/receipt-images';


  /// Search, Inquiry
  static final String receiptSearch = '$api/receipt-search';
  static final String invoiceSearch = '$api/invoice-search';
  static final String visitSearch = '$api/visit-search';

  /// Sync
  static final String syncVisitLocation = "$api/visit";
  static final String syncReceiptHeader = "$api/receipt-header";
  static final String syncReceiptDetail = "$api/receipt-detail";

  static final String trackLocation = "$api/track_location";
  static final String invoiceApproval = "$api/approval-requests";

  /// Dashboard
  static final String dashboard = '$api/dashboard';

  /// Contact support
  static final String contactSupport = '$api/contact-support';

}
