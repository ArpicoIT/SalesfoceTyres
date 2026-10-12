import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

/// Brand + semantic colours used by the redesigned screens.
///
/// Later these should move into `ThemeData` (ColorScheme + ThemeExtension)
/// so dark mode / re-branding is a one-file change.
abstract final class AppColors {
  static Color primaryLight = Color(0xFF00477F);
  static Color primaryDark = Color(0xFF4DA3E8);
  static Color secondaryLight = Color(0xFFFFFFFF);
  static Color secondaryDark = Color(0xFFFFFFFF);

  static const Color navy = Color(0xFF0B2A5B);
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E9F0);

  static const Color textPrimary = Color(0xFF0F1B33);
  static const Color textSecondary = Color(0xFF6B7690);

  static const Color success = Color(0xFF2E9E44);
  static const Color info = Color(0xFF1E66C1);
  static const Color warning = Color(0xFFF59E0B);
  static const Color accent = Color(0xFF7C4DFF);

  /// Colours assigned to payment modes in charts / legends (cycled).
  static const List<Color> chartSeries = [info, success, warning, accent];
}

/*
class AppColors {
  final BuildContext context;
  const AppColors._(this.context);
  static AppColors of(BuildContext context) => AppColors._(context);

  static Color primaryLight = Color(0xFF00477F);
  static Color primaryDark = Color(0xFF4DA3E8);

  static Color secondaryLight = Color(0XFFFFFFFF);
  static Color secondaryDark = Color(0XFFFFFFFF);


  Color get primary => _isDark ? primaryDark : primaryLight;
  Color get secondary => _isDark ? secondaryDark : secondaryLight;

  Color get textColor => _isDark ? Color(0XFFFFFFFF) : Color(0XFF000000);

  // Helper methods
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
}
*/

