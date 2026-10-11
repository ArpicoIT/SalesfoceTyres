import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'quick_access_section.dart';

/// Phone bottom bar. Index 0 is the dashboard itself; the rest reuse the
/// quick actions so routes are defined in exactly one place.
class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        elevation: 0,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.info,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index > 0) actions[index - 1].onTap();
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Dashboard',
          ),
          for (final action in actions)
            BottomNavigationBarItem(
              icon: Icon(action.icon),
              label: action.label,
            ),
        ],
      ),
    );
  }
}
