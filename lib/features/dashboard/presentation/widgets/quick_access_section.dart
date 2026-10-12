import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'dashboard_card.dart';

class QuickAction {
  const QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

/// Phone: card with vertical tiles. Tablet: heading + wide tiles with chevron.
class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({
    super.key,
    required this.actions,
    required this.isPhone,
  });

  static const int _columns = 3;

  final List<QuickAction> actions;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    if (isPhone) {
      return DashboardCard(
        title: 'Quick access',
        child: _buildGrid(gap: 8, tileBuilder: (a) => _PhoneTile(action: a)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick access',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildGrid(gap: 16, tileBuilder: (a) => _TabletTile(action: a)),
      ],
    );
  }

  Widget _buildGrid({
    required double gap,
    required Widget Function(QuickAction) tileBuilder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth =
            (constraints.maxWidth - gap * (_columns - 1)) / _columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final action in actions)
              SizedBox(width: tileWidth, child: tileBuilder(action)),
          ],
        );
      },
    );
  }
}

class _TileShell extends StatelessWidget {
  const _TileShell({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.action, required this.size});

  final QuickAction action;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: action.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(action.icon, color: action.color, size: size * 0.5),
    );
  }
}

class _PhoneTile extends StatelessWidget {
  const _PhoneTile({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return _TileShell(
      onTap: action.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionIcon(action: action, size: 44),
            const SizedBox(height: 8),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletTile extends StatelessWidget {
  const _TabletTile({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return _TileShell(
      onTap: action.onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _ActionIcon(action: action, size: 56),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
