import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';

import '../../app/route_paths.dart';

class _DrawerGroup {
  final String title;
  final List<_DrawerItem> items;

  const _DrawerGroup({
    required this.title,
    required this.items,
  });
}

class _DrawerItem {
  final String title;
  final IconData icon;
  final String route;

  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class HomeDrawer extends StatelessWidget {
  final VoidCallback afterRouteCompleted;
  final UserModel? currentUser;

  const HomeDrawer({
    super.key,
    required this.afterRouteCompleted,
    required this.currentUser
  });

  void _onTap(BuildContext context, String route) async {
    await Future.delayed(Duration(seconds: 1), afterRouteCompleted.call);

    if(context.mounted) {
      Navigator.of(context).pushNamed(route);
    }
  }

  List<_DrawerGroup> get _groups => [
    _DrawerGroup(
      title: 'DATA & MANAGEMENT',
      items: [
        _DrawerItem(
          title: 'Downloads',
          icon: Icons.download_rounded,
          route: RoutePaths.downloads,
        ),
        _DrawerItem(
          title: 'Sync Data',
          icon: Icons.sync_rounded,
          route: RoutePaths.sync,
        ),
        _DrawerItem(
          title: 'Backup & Restore',
          icon: Icons.settings_backup_restore_rounded,
          route: RoutePaths.backupRestore,
        ),
      ],
    ),
    _DrawerGroup(
      title: 'OPERATIONS',
      items: [
        // _DrawerItem(
        //   title: 'Collections',
        //   icon: Icons.receipt_long_rounded,
        //   route: RoutePaths.collections,
        // ),
        _DrawerItem(
            title: 'Collections',
            icon: Icons.receipt_long_rounded,
            route: RoutePaths.startCollection,
        ),
        // _DrawerItem(
        //   title: 'Bank Deposits',
        //   icon: Icons.upload_file_rounded,
        //   route: RoutePaths.bankDeposits,
        // ),
        _DrawerItem(
          title: 'Visits',
          icon: Icons.location_on_rounded,
          route: RoutePaths.visitLocations,
        ),
        _DrawerItem(
          title: 'Inquiries',
          icon: Icons.manage_search_rounded,
          route: RoutePaths.inquiries,
        ),
        // DrawerItem(
        //   title: 'Tasks',
        //   icon: Icons.task_alt_rounded,
        //   route: RoutePaths.tasks,
        // ),
      ],
    ),
    _DrawerGroup(
      title: 'ACCOUNT & PREFERENCES',
      items: [
        _DrawerItem(
          title: 'Profile',
          icon: Icons.person_rounded,
          route: RoutePaths.profile,
        ),
        _DrawerItem(
          title: 'Settings',
          icon: Icons.settings_rounded,
          route: RoutePaths.settings,
        ),
      ],
    ),
    _DrawerGroup(
      title: 'SUPPORT',
      items: [
        // DrawerItem(
        //   title: 'Contact Support',
        //   icon: Icons.support_agent_rounded,
        //   route: RoutePaths.contactSupport,
        // ),
        _DrawerItem(
          title: 'About Us',
          icon: Icons.info_rounded,
          route: RoutePaths.aboutUs,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.all(8),
      child: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              // AppLogo(path: 'assets/icons/logo.png', size: 56),
              /// Menu
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _groups.length,
                  separatorBuilder: (_, i) => const Divider(height: 1),
                  itemBuilder: (context, groupIndex) {
                    final group = _groups[groupIndex];
          
                    return _DrawerGroupWidget(
                      title: group.title,
                      children: group.items.map((item) {
                        return ListTile(
                          leading: Icon(item.icon),
                          title: Text(item.title),
                          onTap: () => _onTap(context, item.route),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
          
              const Divider(height: 1),
              /// Logout
              ListTile(
                leading: Icon(Icons.logout_rounded),
                title: Text('Logout'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: IAMService.instance.logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const .symmetric(vertical: 12, horizontal: 8),
      margin: const .all(8),

      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.onPrimary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_circle,
              size: 36,
              color: cs.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              direction: .horizontal,
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: .infinity,
                  child: Text(
                    currentUser?.userName ?? currentUser?.userId ?? 'User',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
                SizedBox(
                  width: .infinity,
                  child: Text(
                    'ID: ${currentUser?.userId ?? 'N/A'}',
                    style: TextStyle(
                      color: cs.onPrimary,
                    ),
                  ),
                ),
                _buildInfoChip(context, Colors.blue.withAlpha(100), 'SBU', currentUser?.sbuCode ?? 'N/A'),
                _buildInfoChip(context, Colors.green.withAlpha(100), 'Location', currentUser?.locCode ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, Color color, String label, String value) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: .symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Text('$label : $value', style: TextStyle(color: Colors.white, fontSize: 12)),

    );
  }
}

class _DrawerGroupWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DrawerGroupWidget({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
