import 'dart:convert';

import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage interface for offline persistence.
/// 
/// **Feature: flutter-2025-final-enhancements**
/// **Validates: Requirements 2.1, 2.2**
abstract interface class PersistenceStorage {
  Future<Result<void>> save<T>(String key, T value, {required String Function(T) encode});
  Future<Result<T?>> load<T>(String key, {required T Function(String) decode});
  Future<Result<void>> delete(String key);
  Future<Result<void>> clear();
}

/// SharedPreferences-based persistence storage.
/// 
/// Note: For production, consider using riverpod_sqflite when stable.
/// This implementation provides a simpler alternative using SharedPreferences.
class SharedPreferencesPersistence implements PersistenceStorage {
  SharedPreferencesPersistence(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesPersistence> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesPersistence(prefs);
  }

  @override
  Future<Result<void>> save<T>(String key, T value, {required String Function(T) encode}) async {
    try {
      final encoded = encode(value);
      await _prefs.setString(key, encoded);
      return const Success(null);
    } on FormatException catch (e, st) {
      return Failure(CacheFailure('Encoding error: ${e.message}', stackTrace: st));
    } on Exception catch (e, st) {
      return Failure(CacheFailure('Failed to save: $e', stackTrace: st));
    }
  }

  @override
  Future<Result<T?>> load<T>(String key, {required T Function(String) decode}) async {
    try {
      final encoded = _prefs.getString(key);
      if (encoded == null) return const Success(null);
      return Success(decode(encoded));
    } on FormatException catch (e, st) {
      return Failure(CacheFailure('Decoding error: ${e.message}', stackTrace: st));
    } on Exception catch (e, st) {
      return Failure(CacheFailure('Failed to load: $e', stackTrace: st));
    }
  }


  @override
  Future<Result<void>> delete(String key) async {
    try {
      await _prefs.remove(key);
      return const Success(null);
    } on Exception catch (e, st) {
      return Failure(CacheFailure('Failed to delete: $e', stackTrace: st));
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      await _prefs.clear();
      return const Success(null);
    } on Exception catch (e, st) {
      return Failure(CacheFailure('Failed to clear: $e', stackTrace: st));
    }
  }
}

/// JSON-based persistence helper.
/// 
/// **Feature: flutter-2025-final-enhancements, Property 2: Persistence Round-Trip**
/// **Validates: Requirements 2.3**
class JsonPersistence<T> {
  JsonPersistence({
    required this.storage,
    required this.key,
    required this.toJson,
    required this.fromJson,
  });

  final PersistenceStorage storage;
  final String key;
  final Map<String, dynamic> Function(T) toJson;
  final T Function(Map<String, dynamic>) fromJson;

  Future<Result<void>> save(T value) => storage.save<T>(
    key,
    value,
    encode: (v) => jsonEncode(toJson(v)),
  );

  Future<Result<T?>> load() => storage.load<T>(
    key,
    decode: (s) {
      final decoded = jsonDecode(s);
      if (decoded is Map<String, dynamic>) {
        return fromJson(decoded);
      }

      if (decoded is Map) {
        final json = <String, dynamic>{};
        for (final entry in decoded.entries) {
          final key = entry.key;
          if (key is! String) {
            throw const FormatException('Invalid JSON object');
          }
          json[key] = entry.value;
        }
        return fromJson(json);
      }

      throw const FormatException('Invalid JSON object');
    },
  );

  Future<Result<void>> delete() => storage.delete(key);
}

/// User preferences model for persistence example.
/// 
/// **Feature: flutter-2025-final-enhancements**
/// **Validates: Requirements 2.2, 2.3**
@immutable
class UserPreferences {

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
    theme: json['theme'] as String? ?? 'system',
    locale: json['locale'] as String? ?? 'en',
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
  );
  const UserPreferences({
    this.theme = 'system',
    this.locale = 'en',
    this.notificationsEnabled = true,
    this.fontSize = 14.0,
  });

  final String theme;
  final String locale;
  final bool notificationsEnabled;
  final double fontSize;

  Map<String, dynamic> toJson() => {
    'theme': theme,
    'locale': locale,
    'notificationsEnabled': notificationsEnabled,
    'fontSize': fontSize,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          theme == other.theme &&
          locale == other.locale &&
          notificationsEnabled == other.notificationsEnabled &&
          fontSize == other.fontSize;

  @override
  int get hashCode => Object.hash(theme, locale, notificationsEnabled, fontSize);
}
