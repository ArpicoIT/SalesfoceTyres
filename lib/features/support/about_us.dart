import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../shared/components/app/app_scaffold.dart';

class AboutUsView extends StatefulWidget {
  const AboutUsView({super.key});

  @override
  State<AboutUsView> createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  String _appName = 'Sales Force Tyres';
  String _version = 'Version loading...';
  // String _buildNumber = 'Build loading...';

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  void _getAppInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appName = packageInfo.appName;
        _version = 'Version: ${packageInfo.version}+${packageInfo.buildNumber}';
        // _buildNumber = 'Build ${packageInfo.buildNumber}';
      });
    } catch (e) {
      setState(() {
        _version = 'Version: Unknown';
        // _buildNumber = 'Build: Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'About Us',
      defaultPadding: true,
      scrollableBody: Column(
        crossAxisAlignment: .center,
        spacing: 10,
        children: [
          // App Logo and Name
          _buildAppHeader(),

          // App Information
          _buildAppInfoCard(),

          // Company Information
          _buildCompanyInfoCard(),

          // Copyright Information
          // AppFooter(),
        ],
      ),
    );
  }

  Widget _buildAppHeader() {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: .infinity,
        child: Column(
          crossAxisAlignment: .center,
          children: [
            // App Logo
            AppLogo(source: 'assets/icons/logo.png'),
            const SizedBox(height: 10),
            // App Name
            Text(
              _appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Version Info
            Text(
              _version,
              style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
            ),
            // Text(
            //   _buildNumber,
            //   style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About This App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sales Force Tyres is a comprehensive mobile application designed to streamline sales operations, inventory management, and customer relationship management for field sales representatives.',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Key Features:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            _buildFeatureItem('Collection of Payments'),
            _buildFeatureItem('Customer Visit Tracking'),
            _buildFeatureItem('Real-time Data Synchronization'),
            _buildFeatureItem('Offline Capabilities'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: cs.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Developed By',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Arpico Group IT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arpico Group is one of Sri Lanka\'s leading retail chains with over 50 years of experience in providing quality products and services to customers across the island.',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Richard Pieris & Company PLC',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A flagship company of the Arpico Group, Richard Pieris & Company PLC has been at the forefront of retail innovation in Sri Lanka.',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
