import 'package:flutter_base_2025/core/cache/hive_cache_config.dart';
import 'package:flutter_base_2025/core/cache/hive_cache_datasource.dart';
import 'package:flutter_base_2025/core/cache/hive_cache_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

// Simple test entity
@immutable
class TestEntity {

  factory TestEntity.fromJson(Map<String, dynamic> json) => TestEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        value: json['value'] as int,
      );
  const TestEntity({required this.id, required this.name, required this.value});

  final String id;
  final String name;
  final int value;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'value': value};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          value == other.value;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ value.hashCode;
}

/// Property tests for Hive cache.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 2.6, 2.7, 2.8**
void main() {
  late Box<Map<dynamic, dynamic>> box;
  late HiveCacheDataSource<TestEntity> dataSource;

  setUpAll(() async {
    // Initialize Hive for testing
    Hive.init('./test_hive');
  });

  setUp(() async {
    box = await Hive.openBox<Map<dynamic, dynamic>>('test_cache_${DateTime.now().millisecondsSinceEpoch}');
    dataSource = HiveCacheDataSource<TestEntity>(
      box: box,
      fromJson: TestEntity.fromJson,
      toJson: (e) => e.toJson(),
    );
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('HiveCacheEntry Property Tests', () {
    // **Feature: architecture-alignment-2025, Property 7: Hive Entity Storage Round-Trip**
    Glados3<String, String, int>(any.nonEmptyLetters, any.nonEmptyLetters, any.int, _explore).test(
      'HiveCacheEntry JSON round-trip preserves data',
      (id, name, value) {
        final entity = TestEntity(id: id, name: name, value: value);
        final entry = HiveCacheEntry.withTtl(
          data: entity,
          ttl: const Duration(hours: 1),
          key: id,
        );

        final json = entry.toJson((e) => e.toJson());
        final restored = HiveCacheEntry.fromJson(json, TestEntity.fromJson);

        expect(restored.data, entity);
        expect(restored.key, entry.key);
      },
    );

    // **Feature: architecture-alignment-2025, Property 6: Cache TTL Expiration**
    test('isExpired returns true after TTL', () async {
      final entry = HiveCacheEntry.withTtl(
        data: TestEntity(id: '1', name: 'test', value: 42),
        ttl: const Duration(milliseconds: 1),
      );

      // Wait for expiration
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(entry.isExpired, isTrue);
    });

    test('isExpired returns false before TTL', () {
      final entry = HiveCacheEntry.withTtl(
        data: TestEntity(id: '1', name: 'test', value: 42),
        ttl: const Duration(hours: 1),
      );

      expect(entry.isExpired, isFalse);
    });
  });

  group('HiveCacheDataSource Property Tests', () {
    // **Feature: architecture-alignment-2025, Property 7: Hive Entity Storage Round-Trip**
    Glados3<String, String, int>(any.nonEmptyLetters, any.nonEmptyLetters, any.int, _explore).test(
      'put then get returns equivalent entity',
      (id, name, value) async {
        final entity = TestEntity(id: id, name: name, value: value);
        final key = 'test_$id';

        await dataSource.put(key, entity);
        final retrieved = await dataSource.getData(key);

        expect(retrieved, entity);
      },
    );

    // **Feature: architecture-alignment-2025, Property 6: Cache TTL Expiration**
    test('expired entries are not returned by default', () async {
      final entity = TestEntity(id: '1', name: 'test', value: 42);

      // Create datasource with very short TTL
      final shortTtlDataSource = HiveCacheDataSource<TestEntity>(
        box: box,
        fromJson: TestEntity.fromJson,
        toJson: (e) => e.toJson(),
        config: const HiveCacheConfig(defaultTtl: Duration(milliseconds: 1)),
      );

      await shortTtlDataSource.put('key', entity);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final retrieved = await shortTtlDataSource.getData('key');
      expect(retrieved, isNull);
    });

    test('expired entries can be retrieved with allowStale', () async {
      final entity = TestEntity(id: '1', name: 'test', value: 42);

      final shortTtlDataSource = HiveCacheDataSource<TestEntity>(
        box: box,
        fromJson: TestEntity.fromJson,
        toJson: (e) => e.toJson(),
        config: const HiveCacheConfig(defaultTtl: Duration(milliseconds: 1)),
      );

      await shortTtlDataSource.put('key', entity);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final retrieved = await shortTtlDataSource.getData('key', allowStale: true);
      expect(retrieved, entity);
    });
  });

  group('HiveCacheDataSource Unit Tests', () {
    test('delete removes entry', () async {
      final entity = TestEntity(id: '1', name: 'test', value: 42);

      await dataSource.put('key', entity);
      expect(await dataSource.contains('key'), isTrue);

      await dataSource.delete('key');
      expect(await dataSource.contains('key'), isFalse);
    });

    test('clear removes all entries', () async {
      await dataSource.put('key1', TestEntity(id: '1', name: 'a', value: 1));
      await dataSource.put('key2', TestEntity(id: '2', name: 'b', value: 2));

      expect(dataSource.length, 2);

      await dataSource.clear();
      expect(dataSource.length, 0);
    });

    test('keys returns all stored keys', () async {
      await dataSource.put('key1', TestEntity(id: '1', name: 'a', value: 1));
      await dataSource.put('key2', TestEntity(id: '2', name: 'b', value: 2));

      expect(dataSource.keys, containsAll(['key1', 'key2']));
    });

    test('removeExpired cleans up expired entries', () async {
      final shortTtlDataSource = HiveCacheDataSource<TestEntity>(
        box: box,
        fromJson: TestEntity.fromJson,
        toJson: (e) => e.toJson(),
        config: const HiveCacheConfig(defaultTtl: Duration(milliseconds: 1)),
      );

      await shortTtlDataSource.put('key1', TestEntity(id: '1', name: 'a', value: 1));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final removed = await shortTtlDataSource.removeExpired();
      expect(removed, 1);
      expect(shortTtlDataSource.length, 0);
    });

    test('putAll stores multiple entries', () async {
      final entries = {
        'key1': TestEntity(id: '1', name: 'a', value: 1),
        'key2': TestEntity(id: '2', name: 'b', value: 2),
        'key3': TestEntity(id: '3', name: 'c', value: 3),
      };

      await dataSource.putAll(entries);

      expect(dataSource.length, 3);
      expect(await dataSource.getData('key1'), entries['key1']);
      expect(await dataSource.getData('key2'), entries['key2']);
      expect(await dataSource.getData('key3'), entries['key3']);
    });

    test('getMany retrieves multiple entries', () async {
      await dataSource.put('key1', TestEntity(id: '1', name: 'a', value: 1));
      await dataSource.put('key2', TestEntity(id: '2', name: 'b', value: 2));

      final results = await dataSource.getMany(['key1', 'key2', 'key3']);

      expect(results['key1'], isNotNull);
      expect(results['key2'], isNotNull);
      expect(results['key3'], isNull); // Not found
    });

    test('dispose stops periodic cleanup', () async {
      dataSource.startPeriodicCleanup(interval: const Duration(seconds: 1));
      dataSource.dispose();
      // Should not throw
    });
  });
}
