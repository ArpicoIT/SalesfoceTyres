import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool hasPadding;
  final EdgeInsets margin;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.hasPadding = true,
    this.margin = .zero,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: margin,
      // shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      // color: cs.primaryContainer.withAlpha(60),
      child: SizedBox(
        width: .infinity,
        child: Column(
          crossAxisAlignment: .start,
          spacing: 20,
          children: [
            Padding(
              padding: .fromLTRB(12, 12, 12, 0),
              child: Text(
                title,
                style: tt.titleMedium?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: .w500,
                ),
              ),
            ),
            Padding(
              padding: hasPadding ? .fromLTRB(12, 0, 12, 12) : .zero,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}