import 'package:flutter/material.dart';

import '../../../helpers/responsive.dart';

class ResponsiveFormField extends StatelessWidget {
  final String title;
  final Widget child;
  final double labelWidth;
  final double spacing;

  const ResponsiveFormField({
    super.key,
    required this.title,
    required this.child,
    this.labelWidth = 140,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final tt = Theme.of(context).textTheme;
    // final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final label = Text(
      "$title${responsive.isPhone ? "" : " :"}",
      style: tt.bodyMedium?.copyWith(
        fontWeight: .w500,
      ),
    );

    if (responsive.isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          SizedBox(height: spacing / 2),
          child,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: labelWidth, height: kMinInteractiveDimension, alignment: .centerLeft, child: label,),
        SizedBox(width: spacing),
        Expanded(child: child),
      ],
    );
  }
}
