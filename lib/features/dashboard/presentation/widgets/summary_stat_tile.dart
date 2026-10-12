import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Icon + title + big number + caption. [compact] = phone, otherwise tablet.
class SummaryStatTile extends StatelessWidget {
  const SummaryStatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.caption,
    this.captionColor = AppColors.textSecondary,
    this.compact = true,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String caption;
  final Color captionColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: compact ? 40 : 72,
      height: compact ? 40 : 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 12 : 20),
      ),
      child: Icon(icon, color: color, size: compact ? 22 : 36),
    );

    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: compact ? 12 : 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );

    final valueText = Text(
      value,
      style: TextStyle(
        fontSize: compact ? 32 : 44,
        height: 1.1,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );

    final captionText = Text(
      caption,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: compact ? 14 : 16,
        fontWeight: captionColor == AppColors.textSecondary
            ? FontWeight.w400
            : FontWeight.w600,
        color: captionColor,
      ),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              iconBox,
              const SizedBox(width: 8),
              Expanded(child: titleText),
            ],
          ),
          const SizedBox(height: 12),
          valueText,
          const SizedBox(height: 4),
          captionText,
        ],
      );
    }

    return Row(
      children: [
        iconBox,
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText,
              const SizedBox(height: 4),
              valueText,
              const SizedBox(height: 4),
              captionText,
            ],
          ),
        ),
      ],
    );
  }
}
