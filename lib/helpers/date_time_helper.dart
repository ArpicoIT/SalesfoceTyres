import 'package:intl/intl.dart';

class DateTimeHelper {
  DateTimeHelper._();

  static const String txnDatePattern = 'yyyy-MM-dd';
  static const String displayDatePattern = 'MMM dd, yyyy'; // dd/MM/yyyy
  static const String displayDateTimePattern = 'MMM dd, yyyy HH:mm aa'; // dd/MM/yyyy HH:mm
  static const String displayTimePattern = 'HH:mm aa'; // HH:mm
  static const String timePattern = 'HH:mm:ss';

  static DateTime? _toDateTime(dynamic input) {
    if (input == null) return null;

    if (input is DateTime) {
      return input;
    }

    if (input is String) {
      return DateTime.tryParse(input);
    }

    return null;
  }

  /// 2026-07-21
  static String getTxnDate([DateTime? date]) {
    return DateFormat(txnDatePattern).format(date ?? DateTime.now());
  }

  /// 2026-07-21T10:30:45.123
  static String getISODate([DateTime? date]) {
    return (date ?? DateTime.now()).toIso8601String();
  }

  /// 2026-07-21 10:30:45
  static DateTime getDateTime([DateTime? date]) {
    return date ?? DateTime.now();
  }

  /// Jul 21, 2026
  static String getDisplayDate([dynamic date]) {
    final dt = _toDateTime(date) ?? DateTime.now();
    return DateFormat(displayDatePattern).format(dt);
  }

  /// Jul 21, 2026 10:30 AM
  static String getDisplayDateTime([dynamic date]) {
    final dt = _toDateTime(date) ?? DateTime.now();
    return DateFormat(displayDateTimePattern).format(dt);
  }

  /// Jul 21, 2026 10:30 AM
  static String getDisplayTime([dynamic date]) {
    final dt = _toDateTime(date) ?? DateTime.now();
    return DateFormat(displayTimePattern).format(dt);
  }

  /// 10:30:45
  static String getTime([DateTime? date]) {
    return DateFormat(timePattern).format(date ?? DateTime.now());
  }

  static DateTime? parse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String? format(String? value, {String pattern = displayDateTimePattern}) {
    final date = parse(value);
    if (date == null) return null;

    return DateFormat(pattern).format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  static DateTime startOfDay([DateTime? date]) {
    final d = date ?? DateTime.now();

    return DateTime(d.year, d.month, d.day);
  }

  static DateTime endOfDay([DateTime? date]) {
    final d = date ?? DateTime.now();

    return DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
  }
}
