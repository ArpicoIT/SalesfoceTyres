import 'package:arpicoiam/iam.dart';
import 'package:intl/intl.dart';

import '../../../services/database/db_columns.dart';
import '../../../services/database/db_helper.dart';
import '../../../services/database/db_tables.dart';
import '../../../services/database/repositories/collection_db_repository.dart';
import '../../../services/database/repositories/visit_location_db_repository.dart';
import 'dashboard_summary.dart';

/// Reads today's dashboard figures from the local database.
///
/// Same queries as the old `DashboardView._loadData`, moved out of the UI.
class DashboardRepository {
  const DashboardRepository();

  Future<DashboardSummary> loadTodaySummary(UserModel user) async {
    // Today's collection count and amount.
    final todayHeaders = await CollectionDbRepository.getTodayCollections(user);
    final collectionAmount = todayHeaders.fold<double>(
      0.0,
      (sum, header) => sum + ((header.totalAmount as num?)?.toDouble() ?? 0.0),
    );

    // Collection summary by pay mode.
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final rows = await DBHelper.query(
      DBTables.COLLECTION_HEADERS,
      columns: [
        DBColumns.PAY_MODE,
        'SUM(${DBColumns.TOTAL_AMOUNT}) as total',
        'COUNT(*) as count',
      ],
      where: '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? '
          'AND ${DBColumns.CREATED_BY} = ? AND ${DBColumns.TXN_DATE} = ?',
      whereArgs: [user.sbuCode, user.locCode, user.userId, today],
      groupBy: DBColumns.PAY_MODE,
    );

    // Today's visit count.
    final visitCount = await VisitLocationDbRepository.getTodayCount(user);

    return DashboardSummary(
      collectionCount: todayHeaders.length,
      collectionAmount: collectionAmount,
      visitCount: visitCount,
      paymentBreakdown: rows.map(PaymentModeSummary.fromRow).toList(),
    );
  }
}
