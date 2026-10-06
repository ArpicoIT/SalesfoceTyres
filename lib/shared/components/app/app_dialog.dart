import 'package:flutter/material.dart';

/// Types of application alerts.
enum AppAlertType { info, warning, error, success }

/// Centralized dialog helper for the application.
class AppDialog {
  AppDialog._();

  /// Shows a generic dialog.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
  }) {
    return showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
    );
  }

  /// Shows an alert dialog with a single action.
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    AppAlertType type = .info,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) async {
    await show<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) {
        final config = _AlertConfig.fromType(context, type);

        return AlertDialog(
          title: Row(
            spacing: 12,
            children: [
              _AlertIcon(config: config),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onPressed?.call();
              },
              style: FilledButton.styleFrom(
                backgroundColor: config.onColor,
              ),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  /// Shows a confirmation dialog.
  ///
  /// Returns:
  /// - `true` when confirmed
  /// - `false` when cancelled
  /// - `null` when dismissed
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    Widget? content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    AppAlertType? type,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) async {
    final config = (type != null) ? _AlertConfig.fromType(context, type) : null;
    confirmColor = (config != null) ? config.onColor : confirmColor;

    final result = await show<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) {
        return AlertDialog(
          title: Row(
            spacing: 12,
            children: [
              if(config != null)
                _AlertIcon(config: config),
              Expanded(child: Text(title)),
            ],
          ),
          content: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            spacing: 12,
            children: [
              Text(message),
              ?content
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                onCancel?.call();
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
              child: Text(cancelText),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onConfirm?.call();
              },
              style: FilledButton.styleFrom(backgroundColor: confirmColor),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result;
  }
}

/// Configuration for an alert type.
class _AlertConfig {
  const _AlertConfig({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color onColor;

  factory _AlertConfig.fromType(BuildContext context, AppAlertType type) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (type) {
      case AppAlertType.info:
        final color = colorScheme.primary;
        return _AlertConfig(
          icon: Icons.info_rounded,
          color: color,
          backgroundColor: color.withValues(alpha: 0.12),
          onColor: color,
        );

      case AppAlertType.warning:
        const color = Colors.orange;
        return _AlertConfig(
          icon: Icons.warning_rounded,
          color: color,
          backgroundColor: color.withValues(alpha: 0.12),
          onColor: color,
        );

      case AppAlertType.error:
        const color = Colors.red;
        return _AlertConfig(
          icon: Icons.error_rounded,
          color: color,
          backgroundColor: color.withValues(alpha: 0.12),
          onColor: color,
        );

      case AppAlertType.success:
        const color = Colors.green;
        return _AlertConfig(
          icon: Icons.check_circle_rounded,
          color: color,
          backgroundColor: color.withValues(alpha: 0.12),
          onColor: color,
        );
    }
  }
}

/// Circular shaded icon used by alert dialogs.
class _AlertIcon extends StatelessWidget {
  const _AlertIcon({required this.config});

  final _AlertConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(config.icon, size: 24, color: config.onColor),
    );
  }
}

/// Convenient BuildContext extensions for application dialogs.
extension AppDialogContextExtension on BuildContext {
  /// Shows a generic dialog.
  Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
  }) {
    return AppDialog.show<T>(
      context: this,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
    );
  }

  /// Shows an alert dialog.
  Future<void> showAlertDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    AppAlertType type = .info,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) {
    return AppDialog.showAlertDialog(
      context: this,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
      type: type,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
    );
  }

  /// Shows a confirmation dialog.
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    Widget? content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    AppAlertType? type,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) {
    return AppDialog.showConfirmDialog(
      context: this,
      title: title,
      message: message,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      confirmColor: confirmColor,
      type: type,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
    );
  }
}
