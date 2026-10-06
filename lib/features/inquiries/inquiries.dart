import 'package:flutter/material.dart';

import '../../app/route_paths.dart';
import '../../shared/components/app/app_scaffold.dart';

class InquiriesView extends StatelessWidget {
  const InquiriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Inquiries',
      defaultPadding: true,
      scrollableBody: Column(
        crossAxisAlignment: .stretch,
        spacing: 12,
        children: [
          _buildInquiryCard(
            context,
            icon: Icons.receipt_long,
            title: 'Collection Inquiry',
            subtitle: 'Search collection receipts',
            color: Colors.blue,
            onTap: () => Navigator.of(context)
                .pushNamed(RoutePaths.collectionInquiry),
          ),
          _buildInquiryCard(
            context,
            icon: Icons.location_on,
            title: 'Visit Inquiry',
            subtitle: 'Search customer visit records',
            color: Colors.green,
            onTap: () => Navigator.of(context)
                .pushNamed(RoutePaths.visitInquiry),
            enabled: false
          ),
          _buildInquiryCard(
              context,
              icon: Icons.monetization_on,
              title: 'Bank Deposit Inquiry',
              subtitle: 'Search bank deposits',
              color: Colors.purple,
              onTap: () => Navigator.of(context)
                  .pushNamed(RoutePaths.bankDepositInquiry),
              enabled: false
          ),
          // _buildInquiryCard(
          //   context,
          //   icon: Icons.monetization_on,
          //   title: 'Invoice Inquiry',
          //   subtitle: 'Search customer invoices',
          //   color: Colors.orange,
          //   onTap: () => Navigator.of(context)
          //       .pushNamed(RoutePaths.invoiceInquiry),
          // ),

        ],
      ),
    );
  }

  Widget _buildInquiryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
        bool enabled = true
  }) {
    final cs = Theme.of(context).colorScheme;

    color = enabled ? color : cs.onSurfaceVariant.withValues(alpha: .5);
    final titleColor = enabled ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: .5);
    final subtitleColor = enabled ? cs.onSurfaceVariant : cs.onSurfaceVariant.withValues(alpha: .5);
    final iconColor = enabled ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: .5);

    return Card(
      elevation: 1,
      margin: .zero,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
