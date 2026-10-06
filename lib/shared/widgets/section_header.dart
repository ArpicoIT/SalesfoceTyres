import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  final bool showRefresh;
  final bool showFilter;

  final VoidCallback? onRefresh;
  final VoidCallback? onFilter;

  final List<Widget>? actions;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showRefresh = false,
    this.showFilter = false,
    this.onRefresh,
    this.onFilter,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),

        if (showFilter)
          IconButton(
            tooltip: 'Filter',
            onPressed: onFilter,
            icon: const Icon(Icons.filter_list),
          ),

        if (showRefresh)
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),

        ...?actions,
      ],
    );
  }
}