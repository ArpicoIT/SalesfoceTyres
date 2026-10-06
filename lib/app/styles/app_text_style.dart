import 'package:flutter/material.dart';

class AppTextStyle {
  final BuildContext context;
  AppTextStyle._(this.context);
  static AppTextStyle of(BuildContext context) => AppTextStyle._(context);

  TextStyle get smallAppBar {
    final brightness = Theme.of(context).brightness;
    final color = brightness == Brightness.dark ? Colors.white : Colors.black;
    return TextStyle(fontSize: 18, color: color, fontWeight: .w400);
  }
}