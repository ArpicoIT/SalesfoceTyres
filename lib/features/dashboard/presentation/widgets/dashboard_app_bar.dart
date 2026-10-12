import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

import '../../../../app/theme/app_colors.dart';


class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    super.key,
    required this.userName,
    required this.onRefresh,
    this.showUserChip = false,
    this.toolbarHeight = kToolbarHeight,
  });

  final String userName;
  final VoidCallback onRefresh;
  final bool showUserChip;
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight * 1.01);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: toolbarHeight,
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,

      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const Text(
        'Salesforce Tyres',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
          onPressed: onRefresh,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_rounded),
          tooltip: 'Notifications',
          onPressed: (){},
        ),
        if (showUserChip) _UserChip(userName: userName),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white,
          child: Icon(Icons.person_outline, size: 20, color: AppColors.navy),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Text(
            userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
        const Icon(Icons.keyboard_arrow_down, size: 20),
      ],
    );
  }
}
