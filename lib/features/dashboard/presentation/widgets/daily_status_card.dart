import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../helpers/number_helper.dart';
import '../../data/dashboard_summary.dart';
import 'dashboard_card.dart';
import 'summary_stat_tile.dart';

/// Today's collections + visits side by side.
class DailyStatusCard extends StatelessWidget {
  const DailyStatusCard({
    super.key,
    required this.summary,
    required this.isPhone,
  });

  final DashboardSummary summary;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: isPhone ? 'Daily status' : null,
      padding: isPhone
          ? const EdgeInsets.all(16)
          : const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SummaryStatTile(
                compact: isPhone,
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.success,
                title: "Today's Collections",
                value: summary.collectionCount.toString(),
                caption: NumberHelper.formatCurrency(summary.collectionAmount),
                captionColor: AppColors.success,
              ),
            ),
            const VerticalDivider(width: 32, color: AppColors.border),
            Expanded(
              child: SummaryStatTile(
                compact: isPhone,
                icon: Icons.location_on,
                color: AppColors.info,
                title: "Today's Visits",
                value: summary.visitCount.toString(),
                caption: 'Today',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
