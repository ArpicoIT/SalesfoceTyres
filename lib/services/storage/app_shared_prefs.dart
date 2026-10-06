import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'storage_encryptor.dart';

class AppSharedPrefs {
  AppSharedPrefs._();
  static final AppSharedPrefs instance = AppSharedPrefs._();

  SharedPreferences? _preferences;
  bool _encrypted = false;

  Future<void> initialize({bool encrypted = false}) async {
    _preferences ??= await SharedPreferences.getInstance();
    _encrypted = encrypted;
  }

  SharedPreferences get prefs {
    if (_preferences == null) {
      throw Exception('AppStorage not initialized');
    }

    return _preferences!;
  }

  /// CLEAR
  Future<void> clear() async {
    await prefs.clear();
  }

  bool contains(String key) {
    return prefs.containsKey(key);
  }

  Future<void> write(String key, dynamic value) async {
    if (!key.contains('.')) {
      String data = value is String ? value : jsonEncode(value);

      if (_encrypted) {
        data = StorageEncryptor.encrypt(data);
      }

      await prefs.setString(key, data);
      return;
    }

    final parts = key.split('.');
    final rootKey = parts.first;

    final Map<String, dynamic> root = read<Map<String, dynamic>>(rootKey) ?? {};

    Map<String, dynamic> current = root;

    for (int i = 1; i < parts.length - 1; i++) {
      current =
          current.putIfAbsent(parts[i], () => <String, dynamic>{})
              as Map<String, dynamic>;
    }

    current[parts.last] = value;

    await write(rootKey, root);
  }

  T? read<T>(String key) {
    if (!key.contains('.')) {
      final data = prefs.getString(key);

      if (data == null) return null;

      String decoded = data;

      if (_encrypted) {
        decoded = StorageEncryptor.decrypt(data);
      }

      if (T == String) {
        return decoded as T;
      }

      return jsonDecode(decoded) as T;
    }

    final parts = key.split('.');
    dynamic current = read<dynamic>(parts.first);

    for (int i = 1; i < parts.length; i++) {
      if (current is! Map<String, dynamic>) {
        return null;
      }

      current = current[parts[i]];
    }

    return current as T?;
  }

  Future<void> remove(String key) async {
    if (!key.contains('.')) {
      await prefs.remove(key);
      return;
    }

    final parts = key.split('.');
    final rootKey = parts.first;

    final Map<String, dynamic>? root = read<Map<String, dynamic>>(rootKey);

    if (root == null) return;

    Map<String, dynamic> current = root;

    for (int i = 1; i < parts.length - 1; i++) {
      final next = current[parts[i]];

      if (next is! Map<String, dynamic>) {
        return;
      }

      current = next;
    }

    current.remove(parts.last);

    await write(rootKey, root);
  }

  /*/// WRITE
  Future<void> write(String key, dynamic value) async {
    String data;

    if (value is String) {
      data = value;
    } else {
      data = jsonEncode(value);
    }

    if (_encrypted) {
      data = StorageEncryptor.encrypt(data);
    }

    await prefs.setString(key, data);
  }

  /// READ
  T? read<T>(String key) {
    final data = prefs.getString(key);

    if (data == null) {
      return null;
    }

    String decoded = data;

    if (_encrypted) {
      decoded = StorageEncryptor.decrypt(data);
    }

    if (T == String) {
      return decoded as T;
    }

    return jsonDecode(decoded) as T;
  }

  /// REMOVE
  Future<void> remove(String key) async {
    await prefs.remove(key);
  }*/

  /*Future<void> nestedWrite(
      String rootKey,
      String key,
      dynamic value,
      ) async {
    final Map<String, dynamic> data =
        read<Map<String, dynamic>>(rootKey) ?? {};

    data[key] = value;

    await write(rootKey, data);
  }

  T? nestedRead<T>(
      String rootKey,
      String key,
      ) {
    final Map<String, dynamic>? data =
    read<Map<String, dynamic>>(rootKey);

    if (data == null || !data.containsKey(key)) {
      return null;
    }

    return data[key] as T?;
  }

  Future<void> nestedRemove(
      String rootKey,
      String key,
      ) async {
    final Map<String, dynamic>? data =
    read<Map<String, dynamic>>(rootKey);

    if (data == null) return;

    data.remove(key);

    if (data.isEmpty) {
      await remove(rootKey);
    } else {
      await write(rootKey, data);
    }
  }*/
}
