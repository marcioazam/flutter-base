import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/generics/cache_entry.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// Cache statistics for monitoring.
class CacheStats {
  int hits = 0;
  int misses = 0;
  int evictions = 0;
  int size = 0;

  double get hitRate => hits + misses > 0 ? hits / (hits + misses) : 0;

  void recordHit() => hits++;
  void recordMiss() => misses++;
  void recordEviction() => evictions++;

  void reset() {
    hits = 0;
    misses = 0;
    evictions = 0;
  }

  @override
  String toString() =>
      'CacheStats(hits: $hits, misses: $misses, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, size: $size)';
}

/// Generic cache repository with TTL support.
/// T = Entity type, ID = Identifier type
abstract class CacheRepository<T, ID> {

  CacheRepository({this.defaultTtl});
  final Map<ID, CacheEntry<T>> _cache = {};
  final CacheStats _stats = CacheStats();
  final Duration? defaultTtl;

  /// Gets cache statistics.
  CacheStats get stats => _stats;

  /// Gets or fetches a value, caching the result.
  Future<Result<T>> getOrFetch(
    ID id,
    Future<Result<T>> Function() fetcher, {
    Duration? ttl,
  }) async {
    final entry = _cache[id];

    if (entry != null && !entry.isExpired) {
      _stats.recordHit();
      return Success(entry.value);
    }

    _stats.recordMiss();

    final result = await fetcher();

    return result.fold(
      Failure.new,
      (value) {
        _cacheValue(id, value, ttl: ttl ?? defaultTtl);
        return Success(value);
      },
    );
  }

  /// Gets cached value if available and not expired.
  Result<T> getCached(ID id) {
    final entry = _cache[id];

    if (entry == null) {
      _stats.recordMiss();
      return const Failure(CacheFailure('Item not in cache'));
    }

    if (entry.isExpired) {
      _cache.remove(id);
      _stats.recordMiss();
      _stats.recordEviction();
      return const Failure(CacheFailure('Cache entry expired'));
    }

    _stats.recordHit();
    return Success(entry.value);
  }

  /// Caches a value with optional TTL.
  void cache(ID id, T value, {Duration? ttl}) {
    _cacheValue(id, value, ttl: ttl ?? defaultTtl);
  }

  /// Invalidates a specific cache entry.
  void invalidate(ID id) {
    if (_cache.remove(id) != null) {
      _stats.recordEviction();
      _stats.size = _cache.length;
    }
  }

  /// Invalidates all cache entries.
  void invalidateAll() {
    final count = _cache.length;
    _cache.clear();
    _stats.evictions += count;
    _stats.size = 0;
  }

  /// Invalidates all expired entries.
  int invalidateExpired() {
    final expiredKeys = _cache.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
      _stats.recordEviction();
    }

    _stats.size = _cache.length;
    return expiredKeys.length;
  }

  /// Returns true if cache contains non-expired entry for ID.
  bool contains(ID id) {
    final entry = _cache[id];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(id);
      _stats.recordEviction();
      _stats.size = _cache.length;
      return false;
    }
    return true;
  }

  /// Returns all cached IDs.
  Iterable<ID> get cachedIds => _cache.keys;

  /// Returns cache size.
  int get size => _cache.length;

  void _cacheValue(ID id, T value, {Duration? ttl}) {
    _cache[id] = CacheEntry.withTtl(value, ttl: ttl);
    _stats.size = _cache.length;
  }
}

/// In-memory cache repository implementation.
class InMemoryCacheRepository<T, ID> extends CacheRepository<T, ID> {
  InMemoryCacheRepository({super.defaultTtl});
}
