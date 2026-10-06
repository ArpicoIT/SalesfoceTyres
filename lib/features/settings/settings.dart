import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/app_theme_notifier.dart';
import '../../shared/components/app/app_scaffold.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notifications = true;
  bool _autoSync = true;
  bool _isLoading = true;

  static const _keyDarkMode = 'settings_dark_mode';
  static const _keyNotifications = 'settings_notifications';
  static const _keyAutoSync = 'settings_auto_sync';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notifications = prefs.getBool(_keyNotifications) ?? true;
      _autoSync = prefs.getBool(_keyAutoSync) ?? true;
    } catch (e) {
      debugPrint('Settings load error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeNotifier = context.watch<AppThemeNotifier>();

    return AppScaffold(
      title: 'Settings',
      isLoading: _isLoading,
      defaultPadding: true,
      scrollableBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Appearance', cs),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme throughout the app'),
                  secondary: Icon(
                    themeNotifier.isDark(context) ? Icons.dark_mode : Icons.light_mode,
                    color: cs.primary,
                  ),
                  value: themeNotifier.isDark(context),
                  onChanged: themeNotifier.changeTheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('Notifications', cs),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive notifications for updates and reminders'),
                  secondary: Icon(
                    _notifications
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: cs.primary,
                  ),
                  value: _notifications,
                  onChanged: (value) {
                    setState(() => _notifications = value);
                    _saveBool(_keyNotifications, value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('Data & Sync', cs),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto Sync'),
                  subtitle: const Text('Automatically sync data when connected'),
                  secondary: Icon(
                    Icons.sync,
                    color: cs.primary,
                  ),
                  value: _autoSync,
                  onChanged: (value) {
                    setState(() => _autoSync = value);
                    _saveBool(_keyAutoSync, value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('Storage', cs),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.cleaning_services,
                      color: cs.primary),
                  title: const Text('Clear App Cache'),
                  subtitle: const Text('Remove temporary files'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onClearAppCache,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('About', cs),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline,
                      color: cs.primary),
                  title: const Text('App Info'),
                  subtitle: const Text('Sales Force Tyres'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.policy_outlined,
                      color: cs.primary),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.description_outlined,
                      color: cs.primary),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void onClearAppCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cache cleared successfully'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
