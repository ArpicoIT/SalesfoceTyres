import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../helpers/number_helper.dart';
import '../../data/dashboard_summary.dart';
import 'dashboard_card.dart';

/// Tablet-only card: collection activity vs field activity.
class ActivityOverviewCard extends StatelessWidget {
  const ActivityOverviewCard({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final visits = summary.visitCount;

    return DashboardCard(
      title: 'Activity overview',
      padding: const EdgeInsets.all(20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ActivityColumn(
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.success,
                heading: 'Collection activity',
                metricLabel: "Today's Collections",
                metricValue: summary.collectionCount.toString(),
                footerLabel: 'Total collected',
                footerValue: NumberHelper.formatCurrency(
                  summary.collectionAmount,
                ),
                footerColor: AppColors.success,
                footerIsEmphasized: true,
              ),
            ),
            const VerticalDivider(width: 40, color: AppColors.border),
            Expanded(
              child: _ActivityColumn(
                icon: Icons.location_on,
                color: AppColors.info,
                heading: 'Field activity',
                metricLabel: "Today's Visits",
                metricValue: visits.toString(),
                footerLabel: 'Status',
                footerValue: visits == 0
                    ? 'No visits recorded'
                    : '$visits ${visits == 1 ? 'visit' : 'visits'} recorded',
                footerColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityColumn extends StatelessWidget {
  const _ActivityColumn({
    required this.icon,
    required this.color,
    required this.heading,
    required this.metricLabel,
    required this.metricValue,
    required this.footerLabel,
    required this.footerValue,
    required this.footerColor,
    this.footerIsEmphasized = false,
  });

  final IconData icon;
  final Color color;
  final String heading;
  final String metricLabel;
  final String metricValue;
  final String footerLabel;
  final String footerValue;
  final Color footerColor;
  final bool footerIsEmphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                heading,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          metricLabel,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          metricValue,
          style: TextStyle(
            fontSize: 36,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const Divider(height: 28, color: AppColors.border),
        Text(
          footerLabel,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          footerValue,
          style: TextStyle(
            fontSize: footerIsEmphasized ? 20 : 14,
            fontWeight: footerIsEmphasized ? FontWeight.w700 : FontWeight.w400,
            color: footerColor,
          ),
        ),
      ],
    );
  }
}
