import 'package:flutter/material.dart';

import '../../services/storage/app_prefs_helper.dart';

class AppThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  final Brightness _brightness = Brightness.light;

  ThemeMode get themeMode => _themeMode;
  Brightness get brightness => _brightness;

  bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Future<void> initialize() async {
    _themeMode = await AppSharedPrefsHelper.getThemeMode();
    notifyListeners();
  }

  Future<void> changeTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;

    if (_themeMode == mode) return;

    _themeMode = mode;

    await AppSharedPrefsHelper.saveTheme(isDark);

    notifyListeners();
  }
}
