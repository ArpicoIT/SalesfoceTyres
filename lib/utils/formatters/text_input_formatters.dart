import 'package:flutter/services.dart';

class TextInputFormatters {
  TextInputFormatters._(); // prevent instantiation

  /// Only letters (A-Z, a-z)
  static List<TextInputFormatter> lettersOnly() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
    ];
  }

  /// Only numbers (0-9)
  static List<TextInputFormatter> digitsOnly() {
    return [
      FilteringTextInputFormatter.digitsOnly,
    ];
  }

  /// Only numbers (0-9) with decimal point
  static List<TextInputFormatter> amountOnly({int decimalRange = 2}) {
    return [
      FilteringTextInputFormatter.allow(
        RegExp(r'^\d*\.?\d{0,' + decimalRange.toString() + r'}'),
      ),
    ];
  }

  /// Alphanumeric (A-Z, a-z, 0-9)
  static List<TextInputFormatter> alphanumeric() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
    ];
  }

  /// Alphanumeric + space
  static List<TextInputFormatter> alphanumericWithSpace() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
    ];
  }

  /// Custom regex formatter (flexible for future use)
  static List<TextInputFormatter> allowPattern(String pattern) {
    return [
      FilteringTextInputFormatter.allow(RegExp(pattern)),
    ];
  }

  /// Limit length helper
  static List<TextInputFormatter> limit(int maxLength) {
    return [
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static TextInputFormatter discountInputFormatter({
    required double maxValue,
  }) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) {
        return newValue;
      }

      final value = double.tryParse(newValue.text);

      // Allow intermediate input such as "1.".
      if (value == null) {
        return newValue.text.endsWith('.')
            ? newValue
            : oldValue;
      }

      return value <= maxValue ? newValue : oldValue;
    });
  }

  /// Combine multiple formatters easily
  static List<TextInputFormatter> combine(List<TextInputFormatter> list) {
    return list;
  }

  static List<TextInputFormatter> noteFormatter() {
    return [
      FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z0-9\s.,!?@#&()\-_/;:+=%*$]'),
      )
    ];
  }

}