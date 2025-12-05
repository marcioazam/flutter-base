import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_logger.dart';

/// Remote configuration service.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 43.1, 43.2, 43.4, 43.5**
abstract interface class RemoteConfigService {
  /// Initializes the service with default values.
  Future<void> initialize(Map<String, dynamic> defaults);

  /// Fetches latest config from remote.
  Future<bool> fetch();

  /// Activates fetched config.
  Future<void> activate();

  /// Fetches and activates in one call.
  Future<bool> fetchAndActivate();

  /// Gets a string value.
  String getString(String key);

  /// Gets an int value.
  int getInt(String key);

  /// Gets a bool value.
  bool getBool(String key);

  /// Gets a double value.
  double getDouble(String key);

  /// Gets a JSON value.
  Map<String, dynamic>? getJson(String key);

  /// Gets all config values.
  Map<String, dynamic> getAll();

  /// Gets the last fetch time.
  DateTime? get lastFetchTime;

  /// Gets the fetch status.
  RemoteConfigStatus get status;
}

/// Remote config fetch status.
enum RemoteConfigStatus {
  notFetched,
  fetching,
  success,
  failure,
  throttled,
}

/// Local remote config service implementation.
class LocalRemoteConfigService implements RemoteConfigService {
  final Map<String, dynamic> _defaults = {};
  final Map<String, dynamic> _fetched = {};
  final Map<String, dynamic> _active = {};

  SharedPreferences? _prefs;
  DateTime? _lastFetchTime;
  RemoteConfigStatus _status = RemoteConfigStatus.notFetched;

  static const String _cacheKey = 'remote_config_cache';
  static const String _lastFetchKey = 'remote_config_last_fetch';

  final Duration _minFetchInterval;
  final Duration _cacheTtl;

  LocalRemoteConfigService({
    Duration minFetchInterval = const Duration(hours: 1),
    Duration cacheTtl = const Duration(hours: 12),
  })  : _minFetchInterval = minFetchInterval,
        _cacheTtl = cacheTtl;

  @override
  Future<void> initialize(Map<String, dynamic> defaults) async {
    _prefs = await SharedPreferences.getInstance();
    _defaults.addAll(defaults);
    _active.addAll(defaults);

    _loadCache();
    AppLogger.info('RemoteConfigService initialized');
  }

  void _loadCache() {
    final cached = _prefs?.getString(_cacheKey);
    if (cached != null) {
      try {
        final decoded = jsonDecode(cached) as Map<String, dynamic>;
        _active.addAll(decoded);
        AppLogger.debug('Loaded cached remote config');
      } catch (e) {
        AppLogger.warning('Failed to load cached config: $e');
      }
    }

    final lastFetch = _prefs?.getInt(_lastFetchKey);
    if (lastFetch != null) {
      _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetch);
    }
  }

  Future<void> _saveCache() async {
    await _prefs?.setString(_cacheKey, jsonEncode(_active));
    await _prefs?.setInt(
        _lastFetchKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<bool> fetch() async {
    if (_status == RemoteConfigStatus.fetching) {
      return false;
    }

    if (_lastFetchTime != null) {
      final elapsed = DateTime.now().difference(_lastFetchTime!);
      if (elapsed < _minFetchInterval) {
        _status = RemoteConfigStatus.throttled;
        AppLogger.debug('Remote config fetch throttled');
        return false;
      }
    }

    _status = RemoteConfigStatus.fetching;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      _fetched.clear();
      _fetched.addAll(_defaults);

      _lastFetchTime = DateTime.now();
      _status = RemoteConfigStatus.success;

      AppLogger.info('Remote config fetched successfully');
      return true;
    } catch (e) {
      _status = RemoteConfigStatus.failure;
      AppLogger.error('Remote config fetch failed', error: e);
      return false;
    }
  }

  @override
  Future<void> activate() async {
    if (_fetched.isNotEmpty) {
      _active.addAll(_fetched);
      await _saveCache();
      AppLogger.debug('Remote config activated');
    }
  }

  @override
  Future<bool> fetchAndActivate() async {
    final success = await fetch();
    if (success) {
      await activate();
    }
    return success;
  }

  @override
  String getString(String key) {
    final value = _active[key] ?? _defaults[key];
    if (value is String) return value;
    return value?.toString() ?? '';
  }

  @override
  int getInt(String key) {
    final value = _active[key] ?? _defaults[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  bool getBool(String key) {
    final value = _active[key] ?? _defaults[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  @override
  double getDouble(String key) {
    final value = _active[key] ?? _defaults[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Map<String, dynamic>? getJson(String key) {
    final value = _active[key] ?? _defaults[key];
    if (value is Map<String, dynamic>) return value;
    if (value is String) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Map<String, dynamic> getAll() => Map.unmodifiable(_active);

  @override
  DateTime? get lastFetchTime => _lastFetchTime;

  @override
  RemoteConfigStatus get status => _status;

  /// Sets a config value (for testing/development).
  @visibleForTesting
  void setValue(String key, dynamic value) {
    _active[key] = value;
  }

  /// Clears all cached config.
  @visibleForTesting
  Future<void> clearCache() async {
    await _prefs?.remove(_cacheKey);
    await _prefs?.remove(_lastFetchKey);
    _active.clear();
    _active.addAll(_defaults);
    _fetched.clear();
    _lastFetchTime = null;
    _status = RemoteConfigStatus.notFetched;
  }
}

/// Singleton for global access.
class RemoteConfigServiceProvider {
  static RemoteConfigService? _instance;

  static RemoteConfigService get instance {
    _instance ??= LocalRemoteConfigService();
    return _instance!;
  }

  static void setInstance(RemoteConfigService service) {
    _instance = service;
  }
}
