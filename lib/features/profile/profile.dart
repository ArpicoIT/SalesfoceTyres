import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/date_time_helper.dart';
import '../../shared/components/app/app_scaffold.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserModel? _currentUser;
  String _appVersion = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final snackBar = AppSnackBar.instance;
    try {
      _currentUser = await IAMService.instance.currentUserOrNull();

      if (_currentUser == null) {
        snackBar.error(message: 'User not found');
      }

      await PackageInfo.fromPlatform().then((info) {
        _appVersion = '${info.version}+${info.buildNumber}';
        return;
      });
    } catch (e) {
      snackBar.error(message: 'Profile initialization error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Profile',
      isLoading: _isLoading,
      defaultPadding: true,
      scrollableBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          _buildProfileHeader(cs),
          _buildUserDetailsCard(cs),
          _buildSystemInfoCard(cs),
          const SizedBox(height: 24),
          _buildLogoutButton(cs),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_circle,
              size: 56,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.userName ?? _currentUser?.userId ?? 'User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${_currentUser?.userId ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsCard(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person,
              'User Name',
              _currentUser?.userName ?? 'N/A',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.badge,
              'User ID',
              _currentUser?.userId ?? 'N/A',
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.business, 'SBU', _currentUser?.sbuStr ?? 'N/A'),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.location_on,
              'Location',
              _currentUser?.locStr ?? 'N/A',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.tablet,
              'Tab Code',
              _currentUser?.tabCode ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: .start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfoCard(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.info_outline, 'App Version', _appVersion),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.update,
              'Last Login',
              DateTimeHelper.getDisplayDateTime(_currentUser?.lastLogin),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
          if (confirmed == true && mounted) {
            IAMService.instance.logout();
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
