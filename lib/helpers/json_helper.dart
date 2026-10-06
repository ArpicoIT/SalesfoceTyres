class JsonHelper {
  static List<T> jsonListToModelList<T>(
    List<Map<String, dynamic>> list,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return list.map((e) => fromJson(e)).toList();
  }

  static List<Map<String, dynamic>> modelListToJsonList<T>(
    List<T> list,
    Map<String, dynamic> Function(T model) toJson,
  ) {
    return list.map((e) => toJson(e)).toList();
  }

  static List<Map<String, dynamic>> jsonListToSqlJsonList<T>(
    List<Map<String, dynamic>> list,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(T model) toJson,
  ) {
    return list.map((e) => toJson(fromJson(e))).toList();
  }

  // static double? toDouble(dynamic value) {
  //   if (value == null) return null;
  //
  //   if (value is double) return value;
  //   if (value is int) return value.toDouble();
  //   if (value is num) return value.toDouble();
  //
  //   if (value is String) {
  //     return double.tryParse(value.trim());
  //   }
  //
  //   return null;
  // }

  static double? getDouble(
      Map<String, dynamic> json,
      List<String> keys, {
        num? defaultValue,
      }) {
    for (final key in keys) {
      final value = json[key];

      if (value == null) continue;

      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();

      if (value is String) {
        final result = double.tryParse(value.trim());
        if (result != null) return result;
      }
    }

    return defaultValue?.toDouble();
  }

  static bool? getBool(
      Map<String, dynamic> json,
      List<String> keys, {
        bool? defaultValue,
      }) {
    for (final key in keys) {
      final value = json[key];

      if (value == null) continue;

      if (value is bool) {
        return value;
      }

      if (value is num) {
        if (value == 1) return true;
        if (value == 0) return false;
      }

      if (value is String) {
        switch (value.trim().toLowerCase()) {
          case 'true':
          case '1':
          case 'yes':
          case 'y':
            return true;

          case 'false':
          case '0':
          case 'no':
          case 'n':
            return false;
        }
      }
    }

    return defaultValue;
  }

  static DateTime? getDateTime(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value == null) continue;

      if (value is DateTime) return value;

      return DateTime.tryParse(value.toString());
    }

    return null;
  }

  static T? getValue<T extends Object>(Map<String, dynamic> json, List<String> keys, {T? defaultValue}) {
    dynamic value;

    for (final key in keys) {
      value = json[key];
      if (value != null) break;
    }

    if (value == null) {
      return defaultValue;
    }

    if(value is T){
      return value;
    }

    return null;
  }

  static T? getEnum<T extends Enum>(
      Map<String, dynamic> json,
      List<String> keys,
      List<T> values, {
        T? defaultValue,
        bool Function(T item, dynamic value)? matcher,
      }) {
    dynamic value;

    for (final key in keys) {
      value = json[key];
      if (value != null) break;
    }

    if (value == null) {
      return defaultValue;
    }

    final match = matcher ??
            (T item, dynamic value) => item.name == value.toString();

    for (final item in values) {
      if (match(item, value)) {
        return item;
      }
    }

    return defaultValue;
  }

  // static T enumValue<T extends Enum>(
  //     dynamic value,
  //     List<T> values, {
  //       required T defaultValue,
  //     }) {
  //   if (value == null) {
  //     return defaultValue;
  //   }
  //
  //   return values.firstWhere(
  //         (e) => e.name == value.toString(),
  //     orElse: () => defaultValue,
  //   );
  // }
}
