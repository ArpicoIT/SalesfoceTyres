import 'package:flutter/material.dart';

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