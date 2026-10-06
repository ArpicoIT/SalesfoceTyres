
import 'package:flutter/material.dart';

class AppButtonStyle {
  static double height(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return 52; // mobile
    } else if (width < 1024) {
      return 56; // tablet
    } else {
      return 44; // desktop/web
    }
  }

  static Size size(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return Size.fromHeight(52); // mobile
    } else if (width < 1024) {
      return Size.fromHeight(56); // tablet
    } else {
      return Size.fromHeight(44); // desktop/web
    }
  }

  static EdgeInsets padding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (width < 1024) {
      return const EdgeInsets.symmetric(horizontal: 20);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
  }
}