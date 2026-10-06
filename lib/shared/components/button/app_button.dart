import 'package:flutter/material.dart';


class AppButton {
  AppButton._(this.context);

  final BuildContext context;

  static AppButton of(BuildContext context) {
    return AppButton._(context);
  }

  static const double height = 48;
  static const double minWidth = 120;

  ThemeData get _theme => Theme.of(context);

  ColorScheme get _colors => _theme.colorScheme;

  /// --------------------------------------------------------------------------
  /// Base Helpers
  /// --------------------------------------------------------------------------

  bool _isDisabled({
    required bool enabled,
    required bool loading,
  }) {
    return !enabled || loading;
  }

  Widget _buildIcon({
    IconData? icon,
    required bool loading,
    Color? color,
    bool outlined = false,
  }) {
    if (loading) {
      return _LoadingIndicator(
        color: _loadingColor(
          color: color,
          outlined: outlined,
        ),
      );
    }

    if (icon != null) {
      return Icon(icon);
    }

    return const SizedBox.shrink();
  }

  Color _loadingColor({
    Color? color,
    bool outlined = false,
  }) {
    final buttonColor = color ?? _colors.primary;

    if (outlined) {
      return buttonColor;
    }

    return _foregroundColor(buttonColor);
  }

  Color _foregroundColor(Color backgroundColor) {
    final brightness =
    ThemeData.estimateBrightnessForColor(backgroundColor);

    return brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Size get _minimumSize {
    return const Size(minWidth, height);
  }

  /// --------------------------------------------------------------------------
  /// Styles
  /// --------------------------------------------------------------------------

  ButtonStyle filledStyle({
    Color? color,
  }) {
    final backgroundColor = color ?? _colors.primary;

    return FilledButton.styleFrom(
      minimumSize: _minimumSize,
      backgroundColor: backgroundColor,
      foregroundColor: _foregroundColor(backgroundColor),
      disabledBackgroundColor:
      backgroundColor.withValues(alpha: 0.4),
      disabledForegroundColor:
      _foregroundColor(backgroundColor).withValues(alpha: 0.6),
    );
  }

  ButtonStyle tonalStyle({
    Color? color,
  }) {
    final backgroundColor =
        color ?? _colors.secondaryContainer;

    return FilledButton.styleFrom(
      minimumSize: _minimumSize,
      backgroundColor: backgroundColor,
      foregroundColor:
      color != null
          ? _foregroundColor(backgroundColor)
          : _colors.onSecondaryContainer,
      disabledBackgroundColor:
      backgroundColor.withValues(alpha: 0.4),
    );
  }

  ButtonStyle outlinedStyle({
    Color? color,
  }) {
    final foregroundColor =
        color ?? _colors.primary;

    return OutlinedButton.styleFrom(
      minimumSize: _minimumSize,
      foregroundColor: foregroundColor,
      disabledForegroundColor:
      foregroundColor.withValues(alpha: 0.4),
      side: BorderSide(
        color: foregroundColor,
      ),
    );
  }

  ButtonStyle textStyle({
    Color? color,
  }) {
    final foregroundColor =
        color ?? _colors.primary;

    return TextButton.styleFrom(
      minimumSize: _minimumSize,
      foregroundColor: foregroundColor,
      disabledForegroundColor:
      foregroundColor.withValues(alpha: 0.4),
    );
  }

  ButtonStyle secondaryStyle({
    Color? color,
  }) {
    final foregroundColor =
        color ?? _colors.onSurface;

    final backgroundColor =
        color?.withValues(alpha: 0.15) ??
            _colors.surfaceContainerHigh;

    return FilledButton.styleFrom(
      minimumSize: _minimumSize,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor:
      _colors.surfaceContainerHighest,
      disabledForegroundColor:
      foregroundColor.withValues(alpha: 0.4),
    );
  }

  /// --------------------------------------------------------------------------
  /// Filled Button
  /// --------------------------------------------------------------------------

  Widget filled({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    bool enabled = true,
    bool loading = false,
    String loadingLabel = 'Loading...',
    Color? color,
    IconAlignment iconAlignment = IconAlignment.start,
  }) {
    final isDisabled = _isDisabled(
      enabled: enabled,
      loading: loading,
    );

    return FilledButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: _buildIcon(
        icon: icon,
        loading: loading,
        color: color,
      ),
      label: Text(
        loading ? loadingLabel : label,
      ),
      style: filledStyle(color: color),
      iconAlignment: iconAlignment,
    );
  }


  /// --------------------------------------------------------------------------
  /// Tonal Button
  /// --------------------------------------------------------------------------

  Widget tonal({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    bool enabled = true,
    bool loading = false,
    String loadingLabel = 'Loading...',
    Color? color,
    IconAlignment iconAlignment = IconAlignment.start,
  }) {
    final isDisabled = _isDisabled(
      enabled: enabled,
      loading: loading,
    );

    return FilledButton.tonalIcon(
      onPressed: isDisabled ? null : onPressed,
      icon: _buildIcon(
        icon: icon,
        loading: loading,
        color: color,
      ),
      label: Text(
        loading ? loadingLabel : label,
      ),
      style: tonalStyle(color: color),
      iconAlignment: iconAlignment,
    );
  }

  /// --------------------------------------------------------------------------
  /// Outlined Button
  /// --------------------------------------------------------------------------

  Widget outlined({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    bool enabled = true,
    bool loading = false,
    String loadingLabel = 'Loading...',
    Color? color,
    IconAlignment iconAlignment = IconAlignment.start,
  }) {
    final isDisabled = _isDisabled(
      enabled: enabled,
      loading: loading,
    );

    return OutlinedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: _buildIcon(
        icon: icon,
        loading: loading,
        color: color,
        outlined: true,
      ),
      label: Text(
        loading ? loadingLabel : label,
      ),
      style: outlinedStyle(color: color),
      iconAlignment: iconAlignment,
    );
  }

  /// --------------------------------------------------------------------------
  /// Text Button
  /// --------------------------------------------------------------------------

  Widget text({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    bool enabled = true,
    bool loading = false,
    String loadingLabel = 'Loading...',
    Color? color,
    IconAlignment iconAlignment = IconAlignment.start,
  }) {
    final isDisabled = _isDisabled(
      enabled: enabled,
      loading: loading,
    );

    return TextButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: _buildIcon(
        icon: icon,
        loading: loading,
        color: color,
        outlined: true,
      ),
      label: Text(
        loading ? loadingLabel : label,
      ),
      style: textStyle(color: color),
      iconAlignment: iconAlignment,
    );
  }

  /// --------------------------------------------------------------------------
  /// Secondary Button
  /// --------------------------------------------------------------------------

  Widget secondary({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    bool enabled = true,
  }) {
    return FilledButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: icon != null
          ? Icon(icon)
          : const SizedBox.shrink(),
      label: Text(label),
      style: secondaryStyle(),
    );
  }

  /// --------------------------------------------------------------------------
  /// Common Actions
  /// --------------------------------------------------------------------------

  Widget save({
    required VoidCallback? onPressed,
    String label = 'Save',
    IconData icon = Icons.save_rounded,
    bool enabled = true,
    bool loading = false,
    bool showIcon = true,
  }) {
    return filled(
      onPressed: onPressed,
      label: label,
      icon: showIcon ? icon : null,
      enabled: enabled,
      loading: loading,
      loadingLabel: 'Saving...',
    );
  }

  Widget search({
    required VoidCallback? onPressed,
    String label = 'Search',
    IconData icon = Icons.search_rounded,
    bool enabled = true,
    bool loading = false,
    bool showIcon = true,
  }) {
    return filled(
      onPressed: onPressed,
      label: label,
      icon: showIcon ? icon : null,
      enabled: enabled,
      loading: loading,
      loadingLabel: 'Searching...',
    );
  }

  Widget download({
    required VoidCallback? onPressed,
    String label = 'Download',
    IconData icon = Icons.download_rounded,
    bool enabled = true,
    bool loading = false,
    bool showIcon = true,
  }) {
    return filled(
      onPressed: onPressed,
      label: label,
      icon: showIcon ? icon : null,
      enabled: enabled,
      loading: loading,
      loadingLabel: 'Downloading...',
      color: Colors.green,
    );
  }

  Widget cancel({
    required VoidCallback? onPressed,
    String label = 'Cancel',
    bool enabled = true,
  }) {
    return secondary(
      onPressed: onPressed,
      label: label,
      enabled: enabled,
    );
  }
}

/// --------------------------------------------------------------------------
/// Loading Indicator
/// --------------------------------------------------------------------------

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color,
      ),
    );
  }
}

/*class PrimaryButtons {
  static const double _height = 48;
  static const double _minWidth = 120;

  /// --------------------------------------------------------------------------
  /// Styles
  /// --------------------------------------------------------------------------

  static ButtonStyle _primaryStyle(
    BuildContext context, [
    Color? overlayColor,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = overlayColor ?? colorScheme.primary;

    final foregroundColor = _getFilledButtonForegroundColor(context, color);
    final disabledForegroundColor = _getFilledButtonForegroundColor(
      context,
      color,
      isDisabled: true,
    );

    return ElevatedButton.styleFrom(
      minimumSize: const Size(_minWidth, _height),
      backgroundColor: color,
      foregroundColor: foregroundColor,
      iconColor: foregroundColor,
      disabledBackgroundColor: color.withValues(alpha: 0.4),
      disabledForegroundColor: disabledForegroundColor,
      disabledIconColor: disabledForegroundColor,
    );
  }

  static ButtonStyle _secondaryStyle(
    BuildContext context, [
    Color? overlayColor,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.styleFrom(
      minimumSize: const Size(_minWidth, _height),
      backgroundColor:
          overlayColor?.withValues(alpha: 0.2) ??
          colorScheme.surfaceContainerHigh,
      foregroundColor: overlayColor ?? colorScheme.onSurface,
      disabledBackgroundColor: colorScheme.surfaceContainerHighest,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.4),
    );
  }

  static ButtonStyle _primaryOutlinedStyle(
    BuildContext context, [
    Color? overlayColor,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = overlayColor ?? colorScheme.primary;

    final foregroundColor = _getOutlinedButtonForegroundColor(context, color);
    final disabledForegroundColor = _getOutlinedButtonForegroundColor(
      context,
      color,
      isDisabled: true,
    );

    return OutlinedButton.styleFrom(
      minimumSize: const Size(_minWidth, _height),
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor,
      iconColor: foregroundColor,
      disabledBackgroundColor: Colors.transparent,
      disabledForegroundColor: disabledForegroundColor,
      disabledIconColor: disabledForegroundColor,
      side: BorderSide(color: color),
    );
  }

  static ButtonStyle _secondaryOutlinedStyle(
    BuildContext context, [
    Color? overlayColor,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = overlayColor ?? colorScheme.onSurface;

    return OutlinedButton.styleFrom(
      minimumSize: const Size(_minWidth, _height),
      foregroundColor: color,
      side: BorderSide(color: color),
      disabledForegroundColor: color.withValues(alpha: 0.4),
      disabledBackgroundColor: Colors.transparent,
    );
  }

  static ButtonStyle _tonalStyle(
      BuildContext context,
      Color? overlayColor,
      ) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.styleFrom(
      backgroundColor: overlayColor ?? colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
    );
  }

  static ButtonStyle _textButtonStyle(
      BuildContext context, [
        Color? overlayColor,
      ]) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = overlayColor ?? colorScheme.primary;

    final foregroundColor = _getFilledButtonForegroundColor(context, color);
    final disabledForegroundColor = _getFilledButtonForegroundColor(
      context,
      color,
      isDisabled: true,
    );

    return ElevatedButton.styleFrom(
      minimumSize: const Size(_minWidth, _height),
      // backgroundColor: color,
      // foregroundColor: foregroundColor,
      // iconColor: foregroundColor,
      // disabledBackgroundColor: color.withValues(alpha: 0.4),
      // disabledForegroundColor: disabledForegroundColor,
      // disabledIconColor: disabledForegroundColor,
    );
  }

  /// --------------------------------------------------------------------------
  /// Color helper methods
  /// --------------------------------------------------------------------------

  static Color _getFilledButtonForegroundColor(
    BuildContext context,
    Color color, {
    bool isDisabled = false,
  }) {
    if (isDisabled) {
      return Theme.of(context).brightness == Brightness.dark
          ? color
          : color.withValues(alpha: 0.8);
    }
    final colorScheme = Theme.of(context).colorScheme;
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : colorScheme.onPrimary;
  }

  static Color _getOutlinedButtonForegroundColor(
    BuildContext context,
    Color color, {
    bool isDisabled = false,
  }) {
    if (isDisabled) {
      return color.withValues(alpha: 0.6);
    }
    return color;
  }

  /// --------------------------------------------------------------------------
  /// Loading icon
  /// --------------------------------------------------------------------------

  static Widget _buildLoadingIcon(
    BuildContext context,
    Color? overlayColor, {
    bool isDisabled = false,
    bool isOutlined = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = overlayColor ?? colorScheme.primary;

    return SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: isOutlined
            ? _getOutlinedButtonForegroundColor(
                context,
                color,
                isDisabled: isDisabled,
              )
            : _getFilledButtonForegroundColor(
                context,
                color,
                isDisabled: isDisabled,
              ),
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// Buttons
  /// --------------------------------------------------------------------------

  static Widget elevated(
    BuildContext context, {
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    bool enabled = true,
    bool loading = false,
    String loadingText = 'Loading...',
    Color? overlayColor,
    IconAlignment? iconAlignment
  }) {
    final isDisabled = !enabled || loading;

    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: loading
          ? _buildLoadingIcon(context, overlayColor, isDisabled: isDisabled)
          : icon != null
          ? Icon(icon)
          : const SizedBox.shrink(),
      label: Text(loading ? loadingText : label),
      style: _primaryStyle(context, overlayColor),
      iconAlignment: iconAlignment
    );
  }

  static Widget tonal(
      BuildContext context, {
        required VoidCallback? onPressed,
        required String label,
        IconData? icon,
        bool enabled = true,
        bool loading = false,
        String loadingText = 'Loading...',
        Color? overlayColor,
        IconAlignment? iconAlignment,
      }) {
    final isDisabled = !enabled || loading;

    return FilledButton.tonalIcon(
      onPressed: isDisabled ? null : onPressed,
      icon: loading
          ? _buildLoadingIcon(
        context,
        overlayColor,
        isDisabled: isDisabled,
      )
          : icon != null
          ? Icon(icon)
          : const SizedBox.shrink(),
      label: Text(loading ? loadingText : label),
      style: _tonalStyle(context, overlayColor),
      iconAlignment: iconAlignment,
    );
  }

  static Widget text(
      BuildContext context, {
        required VoidCallback? onPressed,
        required String label,
        IconData? icon,
        bool enabled = true,
        bool loading = false,
        String loadingText = 'Loading...',
        Color? overlayColor,
        IconAlignment? iconAlignment
      }) {
    final isDisabled = !enabled || loading;

    return TextButton.icon(
        onPressed: isDisabled ? null : onPressed,
        icon: loading
            ? _buildLoadingIcon(context, overlayColor, isDisabled: isDisabled)
            : icon != null
            ? Icon(icon)
            : const SizedBox.shrink(),
        label: Text(loading ? loadingText : label),
        style: _textButtonStyle(context, overlayColor),
        iconAlignment: iconAlignment
    );
  }

  static Widget cancel(
    BuildContext context, {
    required VoidCallback? onPressed,
    String label = 'Cancel',
    bool enabled = true,
  }) {
    return FilledButton.icon(
      onPressed: enabled ? onPressed : null,
      label: Text(label),
      style: _secondaryStyle(context),
    );
  }

  static Widget outlined(
    BuildContext context, {
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
    bool enabled = true,
    bool loading = false,
    String loadingText = 'Loading...',
    Color? overlayColor,
  }) {
    final isDisabled = !enabled || loading;

    return OutlinedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: loading
          ? _buildLoadingIcon(
              context,
              null,
              isDisabled: isDisabled,
              isOutlined: true,
            )
          : icon != null
          ? Icon(icon)
          : const SizedBox.shrink(),
      label: Text(loading ? loadingText : label),
      style: _primaryOutlinedStyle(context, overlayColor),
    );
  }

  /// Button components
  static Widget save(
    BuildContext context, {
    required VoidCallback? onPressed,
    String label = 'Save',
    IconData icon = Icons.save_rounded,
    bool enabled = true,
    bool loading = false,
    bool hasIcon = true,
  }) {
    return elevated(
      context,
      onPressed: onPressed,
      label: label,
      icon: hasIcon ? icon : null,
      enabled: enabled,
      loading: loading,
      loadingText: 'Saving...',
    );
  }

  static Widget search(
      BuildContext context, {
        required VoidCallback? onPressed,
        String label = 'Search',
        IconData icon = Icons.search_rounded,
        bool enabled = true,
        bool loading = false,
        bool hasIcon = true,
      }) {
    return elevated(
      context,
      onPressed: onPressed,
      label: label,
      icon: hasIcon ? icon : null,
      enabled: enabled,
      loading: loading,
      loadingText: 'Searching...',
    );
  }

  static Widget download(
      BuildContext context, {
        required VoidCallback? onPressed,
        String label = 'Download',
        IconData icon = Icons.download_rounded,
        bool enabled = true,
        bool loading = false,
        bool hasIcon = true,
      }) {
    return elevated(
      context,
      onPressed: onPressed,
      label: label,
      icon: hasIcon ? icon : null,
      enabled: enabled,
      loading: loading,
      loadingText: 'Downloading...',
      overlayColor: const Color.fromARGB(255, 46, 125, 50),
    );
  }

}*/

// static Widget download(
//   BuildContext context, {
//   required VoidCallback? onPressed,
//   String label = 'Download',
//   bool enabled = true,
//   Color overlayColor = const Color.fromARGB(255, 46, 125, 50),
// }) {
//   return ElevatedButton.icon(
//     onPressed: enabled ? onPressed : null,
//     icon: const Icon(Icons.download_rounded),
//     label: Text(label),
//     style: _primaryStyle(context, overlayColor),
//   );
// }

/*static Widget clear(
    BuildContext context, {
    required VoidCallback? onPressed,
    String label = 'Clear',
    bool enabled = true,
    Color overlayColor = const Color.fromARGB(255, 211, 47, 47),
  }) {
    return FilledButton.icon(
      onPressed: enabled ? onPressed : null,
      label: Text(label),
      style: _secondaryStyle(context, overlayColor),
    );
  }*/

// =========================
// 🔥 ACTION BUTTON (LOADER BUTTON)
// =========================

/*static Widget action(
    BuildContext context, {
    required VoidCallback? onPressed,
    required String text,
    String? loadingText,
    IconData? icon,
    bool loading = false,
    bool enabled = true,
  }) {
    final isDisabled = !enabled || loading;

    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      style: _primaryStyle(context),
      icon: loading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(loading ? (loadingText ?? "Loading...") : text),
    );
  }*/

/*static Widget submit(
    BuildContext context, {
    required VoidCallback? onPressed,
    String text = 'Submit',
    bool enabled = true,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      label: Text(text),
      style: _primaryStyle(context),
    );
  }*/