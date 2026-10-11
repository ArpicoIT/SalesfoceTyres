import '../../../services/database/db_columns.dart';

/// Aggregated collections for a single payment mode.
class PaymentModeSummary {
  const PaymentModeSummary({
    required this.payMode,
    required this.total,
    required this.count,
  });

  factory PaymentModeSummary.fromRow(Map<String, dynamic> row) {
    return PaymentModeSummary(
      payMode: row[DBColumns.PAY_MODE]?.toString() ?? 'Unknown',
      total: (row['total'] as num?)?.toDouble() ?? 0,
      count: (row['count'] as num?)?.toInt() ?? 0,
    );
  }

  final String payMode;
  final double total;
  final int count;
}

/// Everything the dashboard needs to render.
class DashboardSummary {
  const DashboardSummary({
    this.collectionCount = 0,
    this.collectionAmount = 0,
    this.visitCount = 0,
    this.paymentBreakdown = const [],
  });

  static const DashboardSummary empty = DashboardSummary();

  final int collectionCount;
  final double collectionAmount;
  final int visitCount;
  final List<PaymentModeSummary> paymentBreakdown;

  bool get hasPaymentBreakdown => paymentBreakdown.isNotEmpty;
}
