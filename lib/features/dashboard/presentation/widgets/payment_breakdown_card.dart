import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../helpers/number_helper.dart';
import '../../data/dashboard_summary.dart';
import 'dashboard_card.dart';

/// Bar chart + legend of today's collections per payment mode.
class PaymentBreakdownCard extends StatelessWidget {
  const PaymentBreakdownCard({
    super.key,
    required this.breakdown,
    this.chartHeight = 200,
  });

  final List<PaymentModeSummary> breakdown;
  final double chartHeight;

  static Color colorAt(int index) =>
      AppColors.chartSeries[index % AppColors.chartSeries.length];

  @override
  Widget build(BuildContext context) {
    final grandTotal = breakdown.fold<double>(0, (sum, e) => sum + e.total);

    return DashboardCard(
      title: 'Payment breakdown',
      trailing: const _PeriodChip(label: 'Today'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: chartHeight,
            child: _PaymentBarChart(breakdown: breakdown),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < breakdown.length; i++)
            _LegendRow(
              color: colorAt(i),
              label: breakdown[i].payMode,
              amount: breakdown[i].total,
              percent: grandTotal > 0
                  ? (breakdown[i].total / grandTotal * 100).round()
                  : 0,
            ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.amount,
    required this.percent,
  });

  final Color color;
  final String label;
  final double amount;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${NumberHelper.formatCurrency(amount)} ($percent%)',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBarChart extends StatelessWidget {
  const _PaymentBarChart({required this.breakdown});

  final List<PaymentModeSummary> breakdown;

  @override
  Widget build(BuildContext context) {
    final labels = breakdown.map((e) => e.payMode).toList();
    final maxY = breakdown.fold<double>(
      0,
      (max, e) => e.total > max ? e.total : max,
    );

    const axisLabelStyle = TextStyle(
      fontSize: 10,
      color: AppColors.textSecondary,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY * 1.2 : 1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${labels[group.x]}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: NumberHelper.formatCurrency(rod.toY),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(labels[index], style: axisLabelStyle),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                NumberHelper.formatCompact(value),
                style: axisLabelStyle,
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        barGroups: [
          for (var i = 0; i < breakdown.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: breakdown[i].total,
                  color: PaymentBreakdownCard.colorAt(i),
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
