import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:flutter_base_2025/core/cache/hive_cache_config.dart';
import 'package:flutter_base_2025/core/cache/hive_cache_entry.dart';

/// Unit tests for Hive cache components.
/// Note: HiveInitializer tests require Flutter integration tests
/// due to path_provider dependency.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 2.2, 2.6**
void main() {
  setUpAll(() async {
    // Initialize Hive for testing (without Flutter)
    Hive.init('./test_hive_unit');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('HiveCacheConfig', () {
    test('default config has expected values', () {
      const config = HiveCacheConfig();

      expect(config.defaultTtl, const Duration(hours: 1));
      expect(config.maxEntries, 1000);
      expect(config.encryptSensitiveBoxes, isTrue);
      expect(config.subDirectory, 'hive_cache');
    });

    test('development config has shorter TTL', () {
      final config = HiveCacheConfig.development();

      expect(config.defaultTtl, const Duration(minutes: 5));
      expect(config.encryptSensitiveBoxes, isFalse);
    });

    test('production config has longer TTL and encryption', () {
      final config = HiveCacheConfig.production();

      expect(config.defaultTtl, const Duration(hours: 24));
      expect(config.encryptSensitiveBoxes, isTrue);
    });

    test('toString returns readable representation', () {
      const config = HiveCacheConfig();
      final str = config.toString();

      expect(str, contains('HiveCacheConfig'));
      expect(str, contains('defaultTtl'));
      expect(str, contains('maxEntries'));
    });
  });

  group('HiveCacheEntry', () {
    test('withTtl creates entry with correct expiration', () {
      final entry = HiveCacheEntry.withTtl(
        data: 'test',
        ttl: const Duration(hours: 1),
        key: 'test_key',
      );

      expect(entry.data, 'test');
      expect(entry.key, 'test_key');
      expect(entry.isExpired, isFalse);
      expect(entry.timeToLive.inMinutes, greaterThan(55));
    });

    test('isExpired returns true after TTL', () async {
      final entry = HiveCacheEntry.withTtl(
        data: 'test',
        ttl: const Duration(milliseconds: 1),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(entry.isExpired, isTrue);
      expect(entry.timeToLive, Duration.zero);
    });

    test('toJson and fromJson round-trip preserves data', () {
      final original = HiveCacheEntry.withTtl(
        data: {'name': 'test', 'value': 42},
        ttl: const Duration(hours: 1),
        key: 'test_key',
      );

      final json = original.toJson((data) => data);
      final restored = HiveCacheEntry<Map<String, dynamic>>.fromJson(
        json,
        (json) => json,
      );

      expect(restored.data, original.data);
      expect(restored.key, original.key);
      expect(restored.cachedAt.toIso8601String(), original.cachedAt.toIso8601String());
      expect(restored.expiresAt.toIso8601String(), original.expiresAt.toIso8601String());
    });

    test('toString returns readable representation', () {
      final entry = HiveCacheEntry.withTtl(
        data: 'test',
        ttl: const Duration(hours: 1),
        key: 'my_key',
      );

      final str = entry.toString();
      expect(str, contains('HiveCacheEntry'));
      expect(str, contains('my_key'));
      expect(str, contains('isExpired: false'));
    });
  });
}
