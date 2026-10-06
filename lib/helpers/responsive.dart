import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive.of(this);
}

class Responsive {
  const Responsive._(this.context);

  final BuildContext context;

  static Responsive of(BuildContext context) => Responsive._(context);

  MediaQueryData get _media => MediaQuery.of(context);

  Size get size => _media.size;

  double get width => size.width;

  double get height => size.height;

  EdgeInsets get padding => _media.padding;

  EdgeInsets get viewInsets => _media.viewInsets;

  EdgeInsets get viewPadding => _media.viewPadding;

  double get pixelRatio => _media.devicePixelRatio;

  double get textScaleFactor => _media.textScaler.textScaleFactor;

  Orientation get orientation => _media.orientation;

  bool get isPortrait => orientation == Orientation.portrait;

  bool get isLandscape => orientation == Orientation.landscape;

  bool get isKeyboardVisible => viewInsets.bottom > 0;

  bool get isPhone => width < 600;

  bool get isTablet => width >= 600 && width < 1024;

  bool get isDesktop => width >= 1024;

  bool get isMobile => isPhone;

  double wp(double percent) => width * percent / 100;

  double hp(double percent) => height * percent / 100;

  double dp(double phone, [double? tablet, double? desktop]) {
    if (isDesktop) return desktop ?? tablet ?? phone;
    if (isTablet) return tablet ?? phone;
    return phone;
  }

  T value<T>({
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? phone;
    if (isTablet) return tablet ?? phone;
    return phone;
  }
}