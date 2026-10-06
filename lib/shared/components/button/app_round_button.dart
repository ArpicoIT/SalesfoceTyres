import 'package:flutter/material.dart';



class AppRoundButton {
  AppRoundButton._(this.context);

  final BuildContext context;

  static AppRoundButton of(BuildContext context) {
    return AppRoundButton._(context);
  }

  static const double defaultSize = 64;
  static const double defaultIconSize = 26;
  static const double labelSpacing = 8;
  static const double loaderSize = 22;

  ThemeData get _theme => Theme.of(context);

  ColorScheme get _colors => _theme.colorScheme;

  // ---------------------------------------------------------------------------
  // Filled
  // ---------------------------------------------------------------------------

  Widget filled({
    required VoidCallback? onPressed,
    required IconData icon,
    String? label,
    bool loading = false,
    bool enabled = true,
    double size = defaultSize,
    double iconSize = defaultIconSize,
    Color? color,
    String loadingLabel = 'Loading...',
  }) {
    return _build(
      onPressed: onPressed,
      icon: icon,
      label: label,
      loading: loading,
      enabled: enabled,
      size: size,
      iconSize: iconSize,
      color: color,
      style: _filledStyle(color),
      loadingLabel: loadingLabel,
    );
  }

  // ---------------------------------------------------------------------------
  // Tonal
  // ---------------------------------------------------------------------------

  Widget tonal({
    required VoidCallback? onPressed,
    required IconData icon,
    String? label,
    bool loading = false,
    bool enabled = true,
    double size = defaultSize,
    double iconSize = defaultIconSize,
    Color? color,
    String loadingLabel = 'Loading...',
  }) {
    return _build(
      onPressed: onPressed,
      icon: icon,
      label: label,
      loading: loading,
      enabled: enabled,
      size: size,
      iconSize: iconSize,
      color: color,
      style: _tonalStyle(color),
      loadingLabel: loadingLabel,
    );
  }

  // ---------------------------------------------------------------------------
  // Secondary
  // ---------------------------------------------------------------------------

  Widget secondary({
    required VoidCallback? onPressed,
    required IconData icon,
    String? label,
    bool loading = false,
    bool enabled = true,
    double size = defaultSize,
    double iconSize = defaultIconSize,
    Color? color,
    String loadingLabel = 'Loading...',
  }) {
    return _build(
      onPressed: onPressed,
      icon: icon,
      label: label,
      loading: loading,
      enabled: enabled,
      size: size,
      iconSize: iconSize,
      color: color,
      style: _secondaryStyle(color),
      loadingLabel: loadingLabel,
    );
  }

  // ---------------------------------------------------------------------------
  // Outlined
  // ---------------------------------------------------------------------------

  Widget outlined({
    required VoidCallback? onPressed,
    required IconData icon,
    String? label,
    bool loading = false,
    bool enabled = true,
    double size = defaultSize,
    double iconSize = defaultIconSize,
    Color? color,
    String loadingLabel = 'Loading...',
  }) {
    return _build(
      onPressed: onPressed,
      icon: icon,
      label: label,
      loading: loading,
      enabled: enabled,
      size: size,
      iconSize: iconSize,
      color: color,
      style: _outlinedStyle(color),
      loadingLabel: loadingLabel,
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Widget save({
    required VoidCallback? onPressed,
    bool loading = false,
    bool enabled = true,
    String? label,
    double size = defaultSize,
    double iconSize = defaultIconSize,
  }) {
    return filled(
      onPressed: onPressed,
      icon: Icons.save_rounded,
      label: label,
      loading: loading,
      enabled: enabled,
      size: size,
      iconSize: iconSize,
      loadingLabel: 'Saving...',
    );
  }

  Widget search({
    required VoidCallback? onPressed,
    bool loading = false,
    bool enabled = true,
    String? label,
    double size = defaultSize,
    double iconSize = defaultIconSize,
  }) {
    return filled(
      onPressed: onPressed,
      icon: Icons.search_rounded,
      label: label,
      loading: loading,
      enabled: enabled,
      size: size,
      iconSize: iconSize,
      loadingLabel: 'Searching...',
    );
  }

  Widget download({
    required VoidCallback? onPressed,
    bool loading = false,
    bool enabled = true,
    String? label,
    double size = defaultSize,
    double iconSize = defaultIconSize,
  }) {
    return filled(
      onPressed: onPressed,
      icon: Icons.download_rounded,
      label: label,
      loading: loading,
      enabled: enabled,
      size: size,
      iconSize: iconSize,
      color: const Color(0xFF2E7D32),
      loadingLabel: 'Downloading...',
    );
  }

  Widget cancel({
    required VoidCallback? onPressed,
    bool loading = false,
    bool enabled = true,
    String? label,
    double size = defaultSize,
    double iconSize = defaultIconSize,
  }) {
    return secondary(
      onPressed: onPressed,
      icon: Icons.close_rounded,
      label: label,
      loading: loading,
      enabled: enabled,
      size: size,
      iconSize: iconSize,
      loadingLabel: 'Cancelling...',
    );
  }

  // ---------------------------------------------------------------------------
  // Shared builder
  // ---------------------------------------------------------------------------

  Widget _build({
    required VoidCallback? onPressed,
    required IconData icon,
    required ButtonStyle style,
    String? label,
    bool loading = false,
    bool enabled = true,
    double size = defaultSize,
    double iconSize = defaultIconSize,
    Color? color,
    String loadingLabel = 'Loading...',
  }) {
    final isDisabled = !enabled || loading;

    final button = IconButton(
      onPressed: isDisabled ? null : onPressed,
      icon: loading
          ? const _LoadingIndicator()
          : Icon(icon, size: iconSize),
      style: style,
      constraints: BoxConstraints.tightFor(
        width: size,
        height: size,
      ),
      padding: EdgeInsets.zero,
    );

    if (label == null || label.isEmpty) {
      return button;
    }

    return _withLabel(
      button: button,
      label: loading ? loadingLabel : label,
      enabled: enabled
    );
  }

  // ---------------------------------------------------------------------------
  // Styles
  // ---------------------------------------------------------------------------

  ButtonStyle _filledStyle(Color? color) {
    final backgroundColor = color ?? _colors.primary;

    return IconButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: _foregroundColor(backgroundColor),
      disabledBackgroundColor:
      backgroundColor.withValues(alpha: 0.12),
      disabledForegroundColor:
      backgroundColor.withValues(alpha: 0.38),
      shape: const CircleBorder(),
    );
  }

  ButtonStyle _tonalStyle(Color? color) {
    final backgroundColor =
        color?.withValues(alpha: 0.15) ??
            _colors.secondaryContainer;

    final foregroundColor =
        color ?? _colors.onSecondaryContainer;

    return IconButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor:
      backgroundColor.withValues(alpha: 0.12),
      disabledForegroundColor:
      foregroundColor.withValues(alpha: 0.38),
      shape: const CircleBorder(),
    );
  }

  ButtonStyle _secondaryStyle(Color? color) {
    final backgroundColor =
        color?.withValues(alpha: 0.15) ??
            _colors.surfaceContainerHigh;

    final foregroundColor =
        color ?? _colors.onSurface;

    return IconButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor:
      backgroundColor.withValues(alpha: 0.12),
      disabledForegroundColor:
      foregroundColor.withValues(alpha: 0.38),
      shape: const CircleBorder(),
    );
  }

  ButtonStyle _outlinedStyle(Color? color) {
    final foregroundColor =
        color ?? _colors.primary;

    return IconButton.styleFrom(
      foregroundColor: foregroundColor,
      side: BorderSide(
        color: foregroundColor,
      ),
      shape: const CircleBorder(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color _foregroundColor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
        Brightness.dark
        ? Colors.white
        : _colors.onPrimary;
  }

  Widget _withLabel({
    required Widget button,
    required String label,
    required bool enabled
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: labelSpacing),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: enabled ? null : Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: AppRoundButton.loaderSize,
      height: AppRoundButton.loaderSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
      ),
    );
  }
}

// class AppRoundButton {
//   static const double _size = 64;
//   static const double _iconSize = 26;
//   static const double _labelSpacing = 8;
//
//   /// --------------------------------------------------------------------------
//   /// Styles
//   /// --------------------------------------------------------------------------
//
//   static ButtonStyle _primaryStyle(
//       BuildContext context, [
//         Color? overlayColor,
//       ]) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final color = overlayColor ?? colorScheme.primary;
//
//     final foregroundColor = _getForegroundColor(context, color);
//     final disabledForegroundColor = _getForegroundColor(
//       context,
//       color,
//       isDisabled: true,
//     );
//
//     return IconButton.styleFrom(
//       fixedSize: const Size.square(_size),
//       backgroundColor: color,
//       foregroundColor: foregroundColor,
//       disabledBackgroundColor: color.withValues(alpha: 0.4),
//       disabledForegroundColor: disabledForegroundColor,
//       shape: const CircleBorder(),
//       padding: EdgeInsets.zero,
//     );
//   }
//
//   static ButtonStyle _secondaryStyle(
//       BuildContext context, [
//         Color? overlayColor,
//       ]) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final color = overlayColor ?? colorScheme.surfaceContainerHigh;
//
//     final foregroundColor = overlayColor ?? colorScheme.onSurface;
//
//     return IconButton.styleFrom(
//       fixedSize: const Size.square(_size),
//       backgroundColor: color,
//       foregroundColor: foregroundColor,
//       disabledBackgroundColor: colorScheme.surfaceContainerHighest,
//       disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.4),
//       shape: const CircleBorder(),
//       padding: EdgeInsets.zero,
//     );
//   }
//
//   static ButtonStyle _outlinedStyle(
//       BuildContext context, [
//         Color? overlayColor,
//       ]) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final color = overlayColor ?? colorScheme.primary;
//
//     final foregroundColor = _getOutlinedForegroundColor(context, color);
//     final disabledForegroundColor = _getOutlinedForegroundColor(
//       context,
//       color,
//       isDisabled: true,
//     );
//
//     return IconButton.styleFrom(
//       fixedSize: const Size.square(_size),
//       backgroundColor: Colors.transparent,
//       foregroundColor: foregroundColor,
//       disabledForegroundColor: disabledForegroundColor,
//       shape: const CircleBorder(),
//       side: BorderSide(color: color),
//       padding: EdgeInsets.zero,
//     );
//   }
//
//   /// --------------------------------------------------------------------------
//   /// Color helpers
//   /// --------------------------------------------------------------------------
//
//   static Color _getForegroundColor(
//       BuildContext context,
//       Color color, {
//         bool isDisabled = false,
//       }) {
//     if (isDisabled) {
//       return Theme.of(context).brightness == Brightness.dark
//           ? color
//           : color.withValues(alpha: 0.8);
//     }
//
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
//         ? Colors.white
//         : colorScheme.onPrimary;
//   }
//
//   static Color _getOutlinedForegroundColor(
//       BuildContext context,
//       Color color, {
//         bool isDisabled = false,
//       }) {
//     if (isDisabled) {
//       return color.withValues(alpha: 0.6);
//     }
//
//     return color;
//   }
//
//   /// --------------------------------------------------------------------------
//   /// Loading icon
//   /// --------------------------------------------------------------------------
//
//   static Widget _buildLoadingIcon(
//       BuildContext context,
//       Color? overlayColor, {
//         bool isDisabled = false,
//         bool isOutlined = false,
//       }) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final color = overlayColor ?? colorScheme.primary;
//
//     return SizedBox.square(
//       dimension: 22,
//       child: CircularProgressIndicator(
//         strokeWidth: 2.5,
//         color: isOutlined
//             ? _getOutlinedForegroundColor(
//           context,
//           color,
//           isDisabled: isDisabled,
//         )
//             : _getForegroundColor(
//           context,
//           color,
//           isDisabled: isDisabled,
//         ),
//       ),
//     );
//   }
//
//   /// --------------------------------------------------------------------------
//   /// Button
//   /// --------------------------------------------------------------------------
//
//   static Widget primary(
//       BuildContext context, {
//         required VoidCallback? onPressed,
//         required IconData icon,
//         String? label,
//         bool enabled = true,
//         bool loading = false,
//         Color? overlayColor,
//         double size = _size,
//         double iconSize = _iconSize,
//       }) {
//     final isDisabled = !enabled || loading;
//
//     final button = IconButton(
//       onPressed: isDisabled ? null : onPressed,
//       icon: loading
//           ? _buildLoadingIcon(
//         context,
//         overlayColor,
//         isDisabled: isDisabled,
//       )
//           : Icon(
//         icon,
//         size: iconSize,
//       ),
//       style: _primaryStyle(context, overlayColor).copyWith(
//         fixedSize: WidgetStatePropertyAll(
//           Size.square(size),
//         ),
//       ),
//       tooltip: label,
//     );
//
//     return _withLabel(
//       context,
//       button: button,
//       label: label,
//     );
//   }
//
//   static Widget secondary(
//       BuildContext context, {
//         required VoidCallback? onPressed,
//         required IconData icon,
//         String? label,
//         bool enabled = true,
//         bool loading = false,
//         Color? overlayColor,
//         double size = _size,
//         double iconSize = _iconSize,
//       }) {
//     final isDisabled = !enabled || loading;
//
//     final button = IconButton(
//       onPressed: isDisabled ? null : onPressed,
//       icon: loading
//           ? _buildLoadingIcon(
//         context,
//         overlayColor,
//         isDisabled: isDisabled,
//       )
//           : Icon(
//         icon,
//         size: iconSize,
//       ),
//       style: _secondaryStyle(context, overlayColor).copyWith(
//         fixedSize: WidgetStatePropertyAll(
//           Size.square(size),
//         ),
//       ),
//       tooltip: label,
//     );
//
//     return _withLabel(
//       context,
//       button: button,
//       label: label,
//     );
//   }
//
//   static Widget outlined(
//       BuildContext context, {
//         required VoidCallback? onPressed,
//         required IconData icon,
//         String? label,
//         bool enabled = true,
//         bool loading = false,
//         Color? overlayColor,
//         double size = _size,
//         double iconSize = _iconSize,
//       }) {
//     final isDisabled = !enabled || loading;
//
//     final button = IconButton(
//       onPressed: isDisabled ? null : onPressed,
//       icon: loading
//           ? _buildLoadingIcon(
//         context,
//         overlayColor,
//         isDisabled: isDisabled,
//         isOutlined: true,
//       )
//           : Icon(
//         icon,
//         size: iconSize,
//       ),
//       style: _outlinedStyle(context, overlayColor).copyWith(
//         fixedSize: WidgetStatePropertyAll(
//           Size.square(size),
//         ),
//       ),
//       tooltip: label,
//     );
//
//     return _withLabel(
//       context,
//       button: button,
//       label: label,
//     );
//   }
//
//   /// --------------------------------------------------------------------------
//   /// Label
//   /// --------------------------------------------------------------------------
//
//   static Widget _withLabel(
//       BuildContext context, {
//         required Widget button,
//         String? label,
//       }) {
//     if (label == null || label.isEmpty) {
//       return button;
//     }
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         button,
//         const SizedBox(height: _labelSpacing),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.labelMedium,
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
//
//   /// --------------------------------------------------------------------------
//   /// Common buttons
//   /// --------------------------------------------------------------------------
//
//   static Widget save(
//       BuildContext context, {
//         required VoidCallback? onPressed,
//         String label = 'Save',
//         IconData icon = Icons.save_rounded,
//         bool enabled = true,
//         bool loading = false,
//       }) {
//     return primary(
//       context,
//       onPressed: onPressed,
//       icon: icon,
//       label: label,
//       enabled: enabled,
//       loading: loading,
//     );
//   }
//
//   static Widget search(
//       BuildContext context, {
//         required VoidCallback? onPressed,
//         String label = 'Search',
//         IconData icon = Icons.search_rounded,
//         bool enabled = true,
//         bool loading = false,
//       }) {
//     return primary(
//       context,
//       onPressed: onPressed,
//       icon: icon,
//       label: label,
//       enabled: enabled,
//       loading: loading,
//     );
//   }
//
//   static Widget download(
//       BuildContext context, {
//         required VoidCallback? onPressed,
//         String label = 'Download',
//         IconData icon = Icons.download_rounded,
//         bool enabled = true,
//         bool loading = false,
//       }) {
//     return primary(
//       context,
//       onPressed: onPressed,
//       icon: icon,
//       label: label,
//       enabled: enabled,
//       loading: loading,
//       overlayColor: const Color.fromARGB(255, 46, 125, 50),
//     );
//   }
//
//   static Widget cancel(
//       BuildContext context, {
//         required VoidCallback? onPressed,
//         String label = 'Cancel',
//         IconData icon = Icons.close_rounded,
//         bool enabled = true,
//       }) {
//     return secondary(
//       context,
//       onPressed: onPressed,
//       icon: icon,
//       label: label,
//       enabled: enabled,
//     );
//   }
// }