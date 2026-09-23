import 'dart:convert';
import 'package:universal_web/web.dart';
import 'constants.dart';
import 'helpers.dart';

/// Uses localStorage to store and retrieve data.
class NakiStorage {
  /// Stores data in localStorage.
  static void set(String key, dynamic value) {
    if (kIsServer) return;

    try {
      final _value = value is String
          ? value
          : const JsonEncoder().convert(value);

      window.localStorage.setItem('naki-$key', _value);
    } catch (e) {
      debugPrint('NakiStorage.set Error: $e');
    }
  }

  /// Retrieves data from localStorage.
  static T? get<T>(String key) {
    if (kIsServer) return null;

    try {
      final value = window.localStorage.getItem('naki-$key');

      if (value == null) return null;

      if (T == String) return value as T;

      return const JsonDecoder().convert(value) as T;
    } catch (e) {
      debugPrint('NakiStorage.get Error: $e');
      return null;
    }
  }

  /// Deletes data from localStorage.
  static void delete(String key) {
    if (kIsServer) return;
    window.localStorage.removeItem('naki-$key');
  }

  /// Clears all Naki-owned data from localStorage.
  static void clearAll() {
    if (kIsServer) return;

    final keys = <String>[];

    for (var i = 0; i < window.localStorage.length; i++) {
      final key = window.localStorage.key(i);
      if (key != null && key.startsWith('naki-')) keys.add(key);
    }

    for (final key in keys) {
      window.localStorage.removeItem(key);
    }
  }
}
