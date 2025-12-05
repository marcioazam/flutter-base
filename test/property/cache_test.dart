import 'package:flutter_base_2025/core/generics/cache_repository.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown, setUpAll, tearDownAll;

// Configure Glados for 100 iterations
final _explore = ExploreConfig(numRuns: 100);

/// **Feature: flutter-state-of-art-2025-final, Property 13: Cache TTL Expiration**
/// **Validates: Requirements 1.5**
void main() {
  group('Cache TTL Properties', () {
    /// **Property 13: Cache TTL Expiration**
    /// *For any* cached item with TTL, after TTL expires, getOrFetch should
    /// call the fetcher function.
    test('Cache entry expires after TTL', () async {
      final cache = InMemoryCacheRepository<String, String>(
        defaultTtl: const Duration(milliseconds: 50),
      );

      var fetchCount = 0;
      Future<Result<String>> fetcher() async {
        fetchCount++;
        return Success('value-$fetchCount');
      }

      // First fetch - should call fetcher
      final result1 = await cache.getOrFetch('key', fetcher);
      expect(result1.valueOrNull, equals('value-1'));
      expect(fetchCount, equals(1));

      // Immediate second fetch - should use cache
      final result2 = await cache.getOrFetch('key', fetcher);
      expect(result2.valueOrNull, equals('value-1'));
      expect(fetchCount, equals(1));

      // Wait for TTL to expire
      await Future.delayed(const Duration(milliseconds: 60));

      // Third fetch - should call fetcher again
      final result3 = await cache.getOrFetch('key', fetcher);
      expect(result3.valueOrNull, equals('value-2'));
      expect(fetchCount, equals(2));
    });

    Glados<int>(any.int, _explore).test(
      'Cache hit rate increases with repeated access to same key',
      (value) async {
        final cache = InMemoryCacheRepository<int, String>();

        Future<Result<int>> fetcher() async => Success(value);

        // First access - miss
        await cache.getOrFetch('key', fetcher);

        // Multiple accesses - hits
        for (var i = 0; i < 5; i++) {
          await cache.getOrFetch('key', fetcher);
        }

        expect(cache.stats.hits, equals(5));
        expect(cache.stats.misses, equals(1));
        expect(cache.stats.hitRate, greaterThan(0.8));
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'Cache contains returns true for non-expired entries',
      (value) {
        final cache = InMemoryCacheRepository<String, String>();
        cache.cache('key', value);

        expect(cache.contains('key'), isTrue);
        expect(cache.contains('nonexistent'), isFalse);
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'Invalidate removes entry from cache',
      (value) {
        final cache = InMemoryCacheRepository<String, String>();
        cache.cache('key', value);

        expect(cache.contains('key'), isTrue);

        cache.invalidate('key');

        expect(cache.contains('key'), isFalse);
      },
    );

    test('InvalidateAll clears entire cache', () {
      final cache = InMemoryCacheRepository<String, String>();

      cache.cache('key1', 'value1');
      cache.cache('key2', 'value2');
      cache.cache('key3', 'value3');

      expect(cache.size, equals(3));

      cache.invalidateAll();

      expect(cache.size, equals(0));
      expect(cache.contains('key1'), isFalse);
      expect(cache.contains('key2'), isFalse);
      expect(cache.contains('key3'), isFalse);
    });

    test('InvalidateExpired removes only expired entries', () async {
      final cache = InMemoryCacheRepository<String, String>();

      // Cache with short TTL
      cache.cache('short', 'value1', ttl: const Duration(milliseconds: 10));
      // Cache without TTL (never expires)
      cache.cache('long', 'value2');

      expect(cache.size, equals(2));

      // Wait for short TTL to expire
      await Future.delayed(const Duration(milliseconds: 20));

      final evicted = cache.invalidateExpired();

      expect(evicted, equals(1));
      expect(cache.size, equals(1));
      expect(cache.contains('short'), isFalse);
      expect(cache.contains('long'), isTrue);
    });

    Glados<int>(any.int, _explore).test(
      'getCached returns failure for missing entries',
      (value) {
        final cache = InMemoryCacheRepository<int, String>();

        final result = cache.getCached('nonexistent');

        expect(result.isFailure, isTrue);
      },
    );

    Glados<int>(any.int, _explore).test(
      'getCached returns success for cached entries',
      (value) {
        final cache = InMemoryCacheRepository<int, String>();
        cache.cache('key', value);

        final result = cache.getCached('key');

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(value));
      },
    );
  });

  group('CacheEntry Properties', () {
    test('CacheEntry without expiration never expires', () {
      final entry = CacheEntry(
        value: 'test',
        cachedAt: DateTime.now(),
      );

      expect(entry.isExpired, isFalse);
      expect(entry.remainingTtlMs, isNull);
    });

    test('CacheEntry with future expiration is not expired', () {
      final entry = CacheEntry(
        value: 'test',
        cachedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(entry.isExpired, isFalse);
      expect(entry.remainingTtlMs, greaterThan(0));
    });

    test('CacheEntry with past expiration is expired', () {
      final entry = CacheEntry(
        value: 'test',
        cachedAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(entry.isExpired, isTrue);
      expect(entry.remainingTtlMs, equals(0));
    });
  });

  group('CacheStats Properties', () {
    test('CacheStats tracks hits and misses correctly', () {
      final stats = CacheStats();

      stats.recordHit();
      stats.recordHit();
      stats.recordMiss();

      expect(stats.hits, equals(2));
      expect(stats.misses, equals(1));
      expect(stats.hitRate, closeTo(0.666, 0.01));
    });

    test('CacheStats reset clears counters', () {
      final stats = CacheStats();

      stats.recordHit();
      stats.recordMiss();
      stats.recordEviction();

      stats.reset();

      expect(stats.hits, equals(0));
      expect(stats.misses, equals(0));
      expect(stats.evictions, equals(0));
    });
  });
}
