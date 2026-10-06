import 'package:intl/intl.dart';

import '../app/exceptions/app_exception.dart';

class NumberHelper {
  static NumberFormat amountFormat() {
    return NumberFormat.currency(symbol: '', decimalDigits: 2, locale: 'en_US');
  }

  static String discountFormat(num? value) {
    return '${(value ?? 0).toStringAsFixed(2)}%';
  }

  static double safeParseDouble(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null) return 0.0;

    return double.parse(parsed.toStringAsFixed(2));
  }

  static String formatCurrency(num? value) {
    return NumberFormat.currency(
      symbol: 'Rs. ',
      decimalDigits: 2,
      locale: 'en_US',
    ).format(value ?? 0);
  }

  static String formatCompact(num? value) {
    if (value == null || value == 0) return '0';
    return NumberFormat.compact(locale: 'en_US').format(value);
  }

  static String getSerialNumber(String? tabCode) {
    if (tabCode == null || tabCode.isEmpty) {
      throw AppException.tabCodeMissing();
    }
    return '$tabCode${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Converts a formatted number string (e.g., "1,245,458.00", "$ 1 245,50") to a [double].
  ///
  /// Returns [fallback] if parsing fails or input is null/empty.
  static double parseAmountFormatToDouble(
      String? value, {
        double fallback = 0.0,
      }) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    // 1. Trim whitespace
    String cleanValue = value.trim();

    // 2. Identify decimal separator type (Comma vs. Dot)
    // If string has both ',' and '.', determine which is the decimal separator based on last occurrence.
    final lastComma = cleanValue.lastIndexOf(',');
    final lastDot = cleanValue.lastIndexOf('.');

    if (lastComma > lastDot) {
      // European style (e.g., "1.245,50") -> Remove dots, replace comma with dot
      cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '.');
    } else {
      // Standard style (e.g., "1,245.50") -> Strip commas
      cleanValue = cleanValue.replaceAll(',', '');
    }

    // 3. Remove all remaining non-numeric characters except digits, '-', and '.'
    cleanValue = cleanValue.replaceAll(RegExp(r'[^0-9.-]'), '');

    // 4. Return parsed double or fallback
    return double.tryParse(cleanValue) ?? fallback;
  }

  static double parseDiscountFormatToDouble(
      String? value, {
        double fallback = 0.0,
      }) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    final parsed = double.tryParse(
      value.replaceAll('%', '').trim(),
    );

    return parsed ?? fallback;
  }
}