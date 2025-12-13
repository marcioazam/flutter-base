import 'dart:async';

import 'package:flutter_base_2025/core/cache/cache_entry.dart';

/// Generic cache data source with TTL support.
///
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 3.4**
abstract interface class CacheDataSource<T> {
  /// Gets a cached value by key.
  Future<T?> get(String key);

  /// Sets a value with optional TTL.
  Future<void> set(String key, T value, {Duration? ttl});

  /// Invalidates a specific key.
  Future<void> invalidate(String key);

  /// Invalidates all cached values.
  Future<void> invalidateAll();

  /// Checks if a key exists and is not expired.
  Future<bool> has(String key);
}

/// In-memory cache implementation with TTL support.
class MemoryCacheDataSource<T> implements CacheDataSource<T> {
  MemoryCacheDataSource({
    Duration? defaultTtl,
    Duration cleanupInterval = const Duration(minutes: 5),
  }) : _defaultTtl = defaultTtl {
    _startCleanupTimer(cleanupInterval);
  }
  final Map<String, CacheEntry<T>> _cache = {};
  final Duration? _defaultTtl;
  Timer? _cleanupTimer;

  void _startCleanupTimer(Duration interval) {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(interval, (_) => _cleanupExpired());
  }

  void _cleanupExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  @override
  Future<T?> get(String key) async {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  @override
  Future<void> set(String key, T value, {Duration? ttl}) async {
    _cache[key] = CacheEntry.withTtl(value, ttl: ttl ?? _defaultTtl);
  }

  @override
  Future<void> invalidate(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> invalidateAll() async {
    _cache.clear();
  }

  @override
  Future<bool> has(String key) async {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Gets all non-expired keys.
  List<String> get keys {
    _cleanupExpired();
    return _cache.keys.toList();
  }

  /// Gets the number of cached items.
  int get length {
    _cleanupExpired();
    return _cache.length;
  }

  /// Disposes the cache and cleanup timer.
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}

/// LRU cache implementation with TTL and max size.
class LruCacheDataSource<T> implements CacheDataSource<T> {
  LruCacheDataSource({
    this.maxSize = 100,
    Duration? defaultTtl,
    Duration cleanupInterval = const Duration(minutes: 5),
  }) : _defaultTtl = defaultTtl {
    _startCleanupTimer(cleanupInterval);
  }
  final int maxSize;
  final Duration? _defaultTtl;
  final Map<String, CacheEntry<T>> _cache = {};
  final List<String> _accessOrder = [];
  Timer? _cleanupTimer;

  void _startCleanupTimer(Duration interval) {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(interval, (_) => _cleanupExpired());
  }

  void _cleanupExpired() {
    final expiredKeys = _cache.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
      _accessOrder.remove(key);
    }
  }

  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  void _evictIfNeeded() {
    while (_cache.length >= maxSize && _accessOrder.isNotEmpty) {
      final lruKey = _accessOrder.removeAt(0);
      _cache.remove(lruKey);
    }
  }

  @override
  Future<T?> get(String key) async {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      _accessOrder.remove(key);
      return null;
    }

    _updateAccessOrder(key);
    return entry.value;
  }

  @override
  Future<void> set(String key, T value, {Duration? ttl}) async {
    if (!_cache.containsKey(key)) {
      _evictIfNeeded();
    }

    _cache[key] = CacheEntry.withTtl(value, ttl: ttl ?? _defaultTtl);
    _updateAccessOrder(key);
  }

  @override
  Future<void> invalidate(String key) async {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  @override
  Future<void> invalidateAll() async {
    _cache.clear();
    _accessOrder.clear();
  }

  @override
  Future<bool> has(String key) async {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      _accessOrder.remove(key);
      return false;
    }

    return true;
  }

  int get length {
    _cleanupExpired();
    return _cache.length;
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
    _accessOrder.clear();
  }
}
