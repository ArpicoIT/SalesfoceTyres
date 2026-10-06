import 'package:flutter/material.dart';

enum AppAlertType {
  info,
  warning,
  error,
  success,
}

// class _AlertStyle {
//   final Color background;
//   final Color border;
//   final Color iconColor;
//   final IconData icon;
//
//
//   const _AlertStyle({
//     required this.background,
//     required this.border,
//     required this.iconColor,
//     required this.icon,
//   });
//
//
//   factory _AlertStyle.from(AppAlertType type) {
//
//     switch(type){
//
//       case AppAlertType.info:
//         return const _AlertStyle(
//           background: Color(0xFFE8F4FD),
//           border: Color(0xFF90CAF9),
//           iconColor: Colors.blue,
//           icon: Icons.info_outline,
//         );
//
//
//       case AppAlertType.warning:
//         return const _AlertStyle(
//           background: Color(0xFFFFF8E1),
//           border: Color(0xFFFFD54F),
//           iconColor: Colors.orange,
//           icon: Icons.warning_amber_outlined,
//         );
//
//
//       case AppAlertType.error:
//         return const _AlertStyle(
//           background: Color(0xFFFFEBEE),
//           border: Color(0xFFEF9A9A),
//           iconColor: Colors.red,
//           icon: Icons.error_outline,
//         );
//
//
//       case AppAlertType.success:
//         return const _AlertStyle(
//           background: Color(0xFFE8F5E9),
//           border: Color(0xFFA5D6A7),
//           iconColor: Colors.green,
//           icon: Icons.check_circle_outline,
//         );
//     }
//   }
// }

class _AlertStyle {
  final Color background;
  final Color border;
  final Color iconColor;
  final IconData icon;

  const _AlertStyle({
    required this.background,
    required this.border,
    required this.iconColor,
    required this.icon,
  });

  factory _AlertStyle.from(
      BuildContext context,
      AppAlertType type,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case AppAlertType.info:
        return _AlertStyle(
          background: Color(
            isDark ? 0xFF0D47A1 : 0xFFE8F4FD,
          ),
          border: Color(
            isDark ? 0xFF1565C0 : 0xFF90CAF9,
          ),
          iconColor: Color(
            isDark ? 0xFF90CAF9 : 0xFF1976D2,
          ),
          icon: Icons.info_outline,
        );

      case AppAlertType.warning:
        return _AlertStyle(
          background: Color(
            isDark ? 0xFF4A3B00 : 0xFFFFF8E1,
          ),
          border: Color(
            isDark ? 0xFFFFC107 : 0xFFFFD54F,
          ),
          iconColor: Color(
            isDark ? 0xFFFFD54F : 0xFFFF9800,
          ),
          icon: Icons.warning_amber_outlined,
        );

      case AppAlertType.error:
        return _AlertStyle(
          background: Color(
            isDark ? 0xFF4A1015 : 0xFFFFEBEE,
          ),
          border: Color(
            isDark ? 0xFFEF5350 : 0xFFEF9A9A,
          ),
          iconColor: Color(
            isDark ? 0xFFEF9A9A : 0xFFD32F2F,
          ),
          icon: Icons.error_outline,
        );

      case AppAlertType.success:
        return _AlertStyle(
          background: Color(
            isDark ? 0xFF0D3B14 : 0xFFE8F5E9,
          ),
          border: Color(
            isDark ? 0xFF66BB6A : 0xFFA5D6A7,
          ),
          iconColor: Color(
            isDark ? 0xFFA5D6A7 : 0xFF388E3C,
          ),
          icon: Icons.check_circle_outline,
        );
    }
  }
}

class AppAlert extends StatelessWidget {
  const AppAlert({
    super.key,
    required this.message,
    this.title,
    this.type = AppAlertType.info,
    this.icon,
    this.actionText,
    this.onAction,
    this.note,
  });

  final String message;
  final String? title;
  final AppAlertType type;
  final IconData? icon;
  /// Action button
  final String? actionText;
  final VoidCallback? onAction;
  final String? note;


  factory AppAlert.info({
    Key? key,
    String? title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
    String? note,
  }) {
    return AppAlert(
      key: key,
      title: title,
      message: message,
      type: AppAlertType.info,
      actionText: actionText,
      onAction: onAction,
      note: note,
    );
  }


  factory AppAlert.warning({
    Key? key,
    String? title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
    String? note,
  }) {
    return AppAlert(
      key: key,
      title: title,
      message: message,
      type: AppAlertType.warning,
      actionText: actionText,
      onAction: onAction,
      note: note,
    );
  }


  factory AppAlert.error({
    Key? key,
    String? title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
    String? note,
  }) {
    return AppAlert(
      key: key,
      title: title,
      message: message,
      type: AppAlertType.error,
      actionText: actionText,
      onAction: onAction,
      note: note,
    );
  }


  factory AppAlert.success({
    Key? key,
    String? title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
    String? note,
  }) {
    return AppAlert(
      key: key,
      title: title,
      message: message,
      type: AppAlertType.success,
      actionText: actionText,
      onAction: onAction,
      note: note,
    );
  }


  @override
  Widget build(BuildContext context) {
    final style = _AlertStyle.from(context, type);
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: style.border,
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(
            icon ?? style.icon,
            color: style.iconColor,
            size: 22,
          ),


          const SizedBox(width: 12),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if(title != null) ...[
                  Text(
                    title!,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                _buildHighlightedText(context, message),
                // Text(
                //   message,
                //   style: Theme.of(context)
                //       .textTheme
                //       .bodyMedium,
                // ),

                if (note != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    note!,
                    style: tt.bodySmall?.copyWith(
                      color: style.iconColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],


                if (actionText != null && onAction != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(actionText!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(
      BuildContext context,
      String text,
      ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final highlightRegex = RegExp(r'\*\*(.*?)\*\*');
    final spans = <TextSpan>[];

    var lastEnd = 0;

    for (final match in highlightRegex.allMatches(text)) {
      // Normal text before the highlighted section.
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
          ),
        );
      }

      // Highlighted text.
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
      );

      lastEnd = match.end;
    }

    // Remaining normal text.
    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
        ),
      );
    }

    return Text.rich(
      TextSpan(
        style: tt.bodyMedium?.copyWith(
          color: cs.onSurface,
          height: 1.45,
        ),
        children: spans,
      ),
    );
  }

}
