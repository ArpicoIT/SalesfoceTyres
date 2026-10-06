import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPrefsHelper {
  static const _keyDarkMode = 'settings_dark_mode';

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool? darkMode = prefs.getBool(_keyDarkMode);

    if(darkMode == null){
      return ThemeMode.system;
    }

    return darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyDarkMode, isDark);
  }
}