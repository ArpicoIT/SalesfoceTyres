import 'package:flutter/material.dart';

import '../../../shared/components/button/app_button.dart';

class SaveActionPanel extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool canSave;
  final bool canCancel;


  const SaveActionPanel({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.canSave = true,
    this.canCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: .symmetric(vertical: 12, horizontal: 24),
      child: Row(
        spacing: 24,
        children: [
          Expanded(child: AppButton.of(context).cancel(onPressed: onCancel, enabled: canCancel, label: 'Back')),
          Expanded(
            child: AppButton.of(context).save(
              onPressed: onSave,
              enabled: canSave,
            ),
          ),
        ],
      ),
    );
  }
}
