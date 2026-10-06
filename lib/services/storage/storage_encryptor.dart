import 'dart:convert';

class StorageEncryptor {
  static String encrypt(String value) {
    return base64Encode(
      utf8.encode(value),
    );
  }

  static String decrypt(String value) {
    return utf8.decode(
      base64Decode(value),
    );
  }
}