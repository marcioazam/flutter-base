import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Initialize Hive with encryption support.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 2.2, 5.2, 5.3**
class HiveInitializer {
  HiveInitializer._();

  static const _encryptionKeyName = 'hive_encryption_key';
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static bool _isInitialized = false;
  static final List<Box<dynamic>> _openBoxes = [];

  /// Initialize Hive for the application.
  static Future<void> init({
    String? subDir,
    List<TypeAdapter<dynamic>> adapters = const [],
  }) async {
    if (_isInitialized) return;

    await Hive.initFlutter(subDir);

    // Register adapters
    for (final adapter in adapters) {
      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter(adapter);
      }
    }

    _isInitialized = true;
  }

  /// Get encryption key for sensitive boxes.
  /// Creates a new key if one doesn't exist.
  static Future<Uint8List> getEncryptionKey() async {
    final existingKey = await _secureStorage.read(key: _encryptionKeyName);

    if (existingKey != null) {
      return base64Decode(existingKey);
    }

    // Generate new key
    final newKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64Encode(newKey),
    );

    return Uint8List.fromList(newKey);
  }

  /// Open an encrypted box for sensitive data.
  static Future<Box<T>> openEncryptedBox<T>(String name) async {
    if (!_isInitialized) {
      throw StateError('HiveInitializer.init() must be called first');
    }

    final encryptionKey = await getEncryptionKey();
    final box = await Hive.openBox<T>(
      name,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    _openBoxes.add(box);
    return box;
  }

  /// Open a regular (unencrypted) box.
  static Future<Box<T>> openBox<T>(String name) async {
    if (!_isInitialized) {
      throw StateError('HiveInitializer.init() must be called first');
    }

    final box = await Hive.openBox<T>(name);
    _openBoxes.add(box);
    return box;
  }

  /// Open a lazy box (loads values on demand).
  static Future<LazyBox<T>> openLazyBox<T>(String name) async {
    if (!_isInitialized) {
      throw StateError('HiveInitializer.init() must be called first');
    }

    final box = await Hive.openLazyBox<T>(name);
    return box;
  }

  /// Close all boxes and cleanup.
  static Future<void> dispose() async {
    for (final box in _openBoxes) {
      await box.close();
    }
    _openBoxes.clear();
    await Hive.close();
    _isInitialized = false;
  }

  /// Check if Hive is initialized.
  static bool get isInitialized => _isInitialized;

  /// Delete a box and its data.
  static Future<void> deleteBox(String name) async {
    await Hive.deleteBoxFromDisk(name);
  }
}
