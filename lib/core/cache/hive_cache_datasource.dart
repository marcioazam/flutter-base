import 'dart:async';

import 'package:flutter_base_2025/core/cache/hive_cache_config.dart';
import 'package:flutter_base_2025/core/cache/hive_cache_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Generic Hive-based cache data source.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 2.3, 2.4, 2.5, 2.6, 4.2**
///
/// Provides cache operations with TTL support using JSON serialization.
class HiveCacheDataSource<T> {
  HiveCacheDataSource({
    required Box<Map<dynamic, dynamic>> box,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    HiveCacheConfig config = const HiveCacheConfig(),
  })  : _box = box,
        _fromJson = fromJson,
        _toJson = toJson,
        _config = config;

  final Box<Map<dynamic, dynamic>> _box;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;
  final HiveCacheConfig _config;
  Timer? _cleanupTimer;

  /// Get a cached entry by key.
  /// Returns null if not found or expired.
  Future<HiveCacheEntry<T>?> get(String key, {bool allowStale = false}) async {
    final raw = _box.get(key);
    if (raw == null) return null;

    try {
      final json = Map<String, dynamic>.from(raw);
      final entry = HiveCacheEntry.fromJson(json, _fromJson);

      if (entry.isExpired && !allowStale) {
        await delete(key);
        return null;
      }

      return entry;
    } on FormatException {
      await delete(key);
      return null;
    } on Exception {
      // Catch any other parsing/casting exceptions
      await delete(key);
      return null;
    }
  }

  /// Get just the data, ignoring metadata.
  Future<T?> getData(String key, {bool allowStale = false}) async {
    final entry = await get(key, allowStale: allowStale);
    return entry?.data;
  }

  /// Store a value with optional TTL.
  /// Automatically evicts oldest entries if maxEntries is exceeded.
  Future<void> put(String key, T value, {Duration? ttl}) async {
    if (_box.length >= _config.maxEntries && !_box.containsKey(key)) {
      await _evictOldest();
    }

    final entry = HiveCacheEntry.withTtl(
      data: value,
      ttl: ttl ?? _config.defaultTtl,
      key: key,
    );

    final json = entry.toJson(_toJson);
    await _box.put(key, json);
  }

  /// Store multiple values at once.
  Future<void> putAll(Map<String, T> entries, {Duration? ttl}) async {
    for (final entry in entries.entries) {
      await put(entry.key, entry.value, ttl: ttl);
    }
  }

  /// Get multiple values at once.
  Future<Map<String, T?>> getMany(
    List<String> keys, {
    bool allowStale = false,
  }) async {
    final results = <String, T?>{};
    for (final key in keys) {
      results[key] = await getData(key, allowStale: allowStale);
    }
    return results;
  }

  /// Evict the oldest entry based on cachedAt timestamp.
  Future<void> _evictOldest() async {
    String? oldestKey;
    DateTime? oldestTime;

    for (final key in keys) {
      final raw = _box.get(key);
      if (raw == null) continue;

      try {
        final json = Map<String, dynamic>.from(raw);
        final cachedAt = DateTime.parse(json['cachedAt'] as String);
        if (oldestTime == null || cachedAt.isBefore(oldestTime)) {
          oldestTime = cachedAt;
          oldestKey = key;
        }
      } on FormatException {
        await delete(key);
        return;
      }
    }

    if (oldestKey != null) {
      await delete(oldestKey);
    }
  }

  /// Delete an entry by key.
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  /// Clear all entries.
  Future<void> clear() async {
    await _box.clear();
  }

  /// Check if an entry exists and is not expired.
  Future<bool> contains(String key) async {
    final entry = await get(key);
    return entry != null;
  }

  /// Check if an entry is expired.
  Future<bool> isExpired(String key) async {
    final raw = _box.get(key);
    if (raw == null) return true;

    try {
      final json = Map<String, dynamic>.from(raw);
      final expiresAt = DateTime.parse(json['expiresAt'] as String);
      return DateTime.now().isAfter(expiresAt);
    } on FormatException {
      return true;
    }
  }

  /// Get all keys in the cache.
  List<String> get keys => _box.keys.cast<String>().toList();

  /// Get the number of entries.
  int get length => _box.length;

  /// Watch for changes to a specific key.
  Stream<T?> watch(String key) => _box.watch(key: key).asyncMap((event) async {
        if (event.deleted || event.value == null) {
          return null;
        }
        final entry = await get(key);
        return entry?.data;
      });

  /// Watch for any changes in the cache.
  Stream<BoxEvent> watchAll() => _box.watch();

  /// Remove all expired entries.
  Future<int> removeExpired() async {
    var removed = 0;
    final keysToRemove = <String>[];

    for (final key in keys) {
      if (await isExpired(key)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      await delete(key);
      removed++;
    }

    return removed;
  }

  /// Get all non-expired entries.
  Future<List<HiveCacheEntry<T>>> getAll() async {
    final entries = <HiveCacheEntry<T>>[];

    for (final key in keys) {
      final entry = await get(key);
      if (entry != null) {
        entries.add(entry);
      }
    }

    return entries;
  }

  /// Start periodic cleanup of expired entries.
  void startPeriodicCleanup({
    Duration interval = const Duration(hours: 1),
  }) {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(interval, (_) => removeExpired());
  }

  /// Stop periodic cleanup.
  void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Dispose resources (stop cleanup timer).
  void dispose() {
    stopPeriodicCleanup();
  }
}
