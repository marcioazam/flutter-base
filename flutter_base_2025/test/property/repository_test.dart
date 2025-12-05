import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_base_2025/core/generics/base_repository.dart';
import 'package:flutter_base_2025/core/generics/paginated_list.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';

/// **Feature: flutter-modernization-2025, Property 1: Repository CRUD Type Safety**
/// **Validates: Requirements 2.1, 2.2**

/// Test entity.
class TestEntity {
  final String id;
  final String name;

  const TestEntity({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestEntity && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

/// Mock repository for testing.
class MockTestRepository extends Mock implements BaseRepository<TestEntity, String> {}

void main() {
  group('Repository CRUD Type Safety Properties', () {
    late MockTestRepository repository;

    setUp(() {
      repository = MockTestRepository();
    });

    test('getById returns Result<T> with correct type', () async {
      const entity = TestEntity(id: '1', name: 'Test');
      when(() => repository.getById('1'))
          .thenAnswer((_) async => Success(entity));

      final result = await repository.getById('1');

      expect(result, isA<Result<TestEntity>>());
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, equals(entity));
    });

    test('getById returns Failure on error', () async {
      when(() => repository.getById('1'))
          .thenAnswer((_) async => Failure(NotFoundFailure('Not found')));

      final result = await repository.getById('1');

      expect(result, isA<Result<TestEntity>>());
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    test('getAll returns Result<PaginatedList<T>>', () async {
      final entities = [
        const TestEntity(id: '1', name: 'Test 1'),
        const TestEntity(id: '2', name: 'Test 2'),
      ];
      final paginatedList = PaginatedList<TestEntity>(
        items: entities,
        page: 1,
        pageSize: 20,
        totalItems: 2,
        totalPages: 1,
        hasMore: false,
      );

      when(() => repository.getAll())
          .thenAnswer((_) async => Success(paginatedList));

      final result = await repository.getAll();

      expect(result, isA<Result<PaginatedList<TestEntity>>>());
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.items.length, equals(2));
    });

    test('create returns Result<T> with created entity', () async {
      const entity = TestEntity(id: '1', name: 'New');
      when(() => repository.create(entity))
          .thenAnswer((_) async => Success(entity));

      final result = await repository.create(entity);

      expect(result, isA<Result<TestEntity>>());
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, equals(entity));
    });

    test('update returns Result<T> with updated entity', () async {
      const entity = TestEntity(id: '1', name: 'Updated');
      when(() => repository.update(entity))
          .thenAnswer((_) async => Success(entity));

      final result = await repository.update(entity);

      expect(result, isA<Result<TestEntity>>());
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.name, equals('Updated'));
    });

    test('delete returns Result<void>', () async {
      when(() => repository.delete('1'))
          .thenAnswer((_) async => const Success(null));

      final result = await repository.delete('1');

      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isTrue);
    });

    test('createMany returns Result<List<T>>', () async {
      final entities = [
        const TestEntity(id: '1', name: 'Test 1'),
        const TestEntity(id: '2', name: 'Test 2'),
      ];
      when(() => repository.createMany(entities))
          .thenAnswer((_) async => Success(entities));

      final result = await repository.createMany(entities);

      expect(result, isA<Result<List<TestEntity>>>());
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.length, equals(2));
    });

    test('deleteMany returns Result<void>', () async {
      when(() => repository.deleteMany(['1', '2']))
          .thenAnswer((_) async => const Success(null));

      final result = await repository.deleteMany(['1', '2']);

      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isTrue);
    });

    test('watchAll returns Stream<List<T>>', () async {
      final entities = [const TestEntity(id: '1', name: 'Test')];
      when(() => repository.watchAll())
          .thenAnswer((_) => Stream.value(entities));

      final stream = repository.watchAll();

      expect(stream, isA<Stream<List<TestEntity>>>());
      expect(await stream.first, equals(entities));
    });

    test('Filter and Sort are type-safe', () {
      const filter = Filter<TestEntity>({'name': 'Test'});
      const sort = Sort<TestEntity>('name', ascending: true);

      expect(filter.conditions['name'], equals('Test'));
      expect(sort.field, equals('name'));
      expect(sort.ascending, isTrue);
    });
  });
}
