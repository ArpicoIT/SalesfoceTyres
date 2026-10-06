import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../styles/app_button_style.dart';
import 'app_colors.dart';

class AppTheme {
  final BuildContext context;
  const AppTheme._(this.context);
  static AppTheme of(BuildContext context) => AppTheme._(context);

  ThemeData get light => _theme(.light);

  ThemeData get dark => _theme(.dark);


  ThemeData _theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: GoogleFonts.poppins().fontFamily, // inter, roboto, ibmPlexSans
    colorScheme: _colorScheme(brightness),
    inputDecorationTheme: _inputDecorationTheme(brightness),

    // bottomSheetTheme: BottomSheetThemeData(
    //   backgroundColor: brightness == .dark ? AppColors.surfaceDark : AppColors.surfaceLight,
    // ),
    // outlinedButtonTheme: OutlinedButtonThemeData(
    //   style: ButtonStyle(
    //     minimumSize: WidgetStatePropertyAll(AppButtonStyle.size(context)),
    //     padding: WidgetStatePropertyAll(AppButtonStyle.padding(context)),
    //   ),
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(AppButtonStyle.size(context)),
        padding: WidgetStatePropertyAll(AppButtonStyle.padding(context)),
      ),
    ),
  );

  ColorScheme _colorScheme(Brightness brightness) => ColorScheme.fromSeed(
    seedColor: brightness == .dark ? AppColors.primaryDark : AppColors.primaryLight, // AppColors.primaryLight,
    primary: brightness == .dark ? AppColors.primaryDark : AppColors.primaryLight,
    brightness: brightness,
  );

  InputDecorationThemeData _inputDecorationTheme(Brightness brightness) {
    final colorScheme = _colorScheme(brightness);

    return InputDecorationThemeData(
      fillColor: colorScheme.surfaceContainerLow,
      // contentPadding: const EdgeInsets.symmetric(
      //   horizontal: 16,
      //   vertical: 14,
      // ),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.76),
      ),
      labelStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
      ),
      floatingLabelStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.6,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.6,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 0.6,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1.5,
        ),
      ),

      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.4,
        ),
      ),
      // errorStyle: TextStyle(
      //   color: colorScheme.error,
      //   fontSize: 12,
      // ),
    );
  }
}
