import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/generics/base_repository.dart';
import 'package:flutter_base_2025/core/generics/base_usecase.dart';
import 'package:flutter_base_2025/core/generics/paginated_list.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';

/// **Feature: flutter-state-of-art-2025-final, Integration Tests**
/// **Validates: Requirements 16.3**

// Test entities
@immutable
class User {

  const User({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && id == other.id && name == other.name && email == other.email;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}

// Mock repository
class MockUserRepository extends Mock implements BaseRepository<User, String> {}

// Use case implementation
class GetUserUseCase implements UseCase<String, User> {

  GetUserUseCase(this.repository);
  final BaseRepository<User, String> repository;

  @override
  Future<Result<User>> call(String id) => repository.getById(id);
}

class GetUsersUseCase implements NoParamsUseCase<PaginatedList<User>> {

  GetUsersUseCase(this.repository);
  final BaseRepository<User, String> repository;

  @override
  Future<Result<PaginatedList<User>>> call() => repository.getAll();
}

class CreateUserUseCase implements UseCase<User, User> {

  CreateUserUseCase(this.repository);
  final BaseRepository<User, String> repository;

  @override
  Future<Result<User>> call(User user) => repository.create(user);
}

void main() {
  group('Repository -> UseCase Flow Integration', () {
    late MockUserRepository repository;
    late GetUserUseCase getUserUseCase;
    late GetUsersUseCase getUsersUseCase;
    late CreateUserUseCase createUserUseCase;

    setUp(() {
      repository = MockUserRepository();
      getUserUseCase = GetUserUseCase(repository);
      getUsersUseCase = GetUsersUseCase(repository);
      createUserUseCase = CreateUserUseCase(repository);
    });

    test('GetUserUseCase returns user from repository', () async {
      const user = User(id: '1', name: 'John', email: 'john@test.com');
      when(() => repository.getById('1')).thenAnswer((_) async => Success(user));

      final result = await getUserUseCase('1');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, equals(user));
      verify(() => repository.getById('1')).called(1);
    });

    test('GetUserUseCase propagates NotFoundFailure', () async {
      when(() => repository.getById('999'))
          .thenAnswer((_) async => Failure(NotFoundFailure('User not found')));

      final result = await getUserUseCase('999');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    test('GetUsersUseCase returns paginated list', () async {
      final users = [
        const User(id: '1', name: 'John', email: 'john@test.com'),
        const User(id: '2', name: 'Jane', email: 'jane@test.com'),
      ];
      final paginatedList = PaginatedList.fromItems(
        users,
        page: 1,
        pageSize: 20,
        totalItems: 2,
      );

      when(() => repository.getAll()).thenAnswer((_) async => Success(paginatedList));

      final result = await getUsersUseCase();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.items.length, equals(2));
    });

    test('CreateUserUseCase creates and returns user', () async {
      const newUser = User(id: '3', name: 'Bob', email: 'bob@test.com');
      when(() => repository.create(newUser)).thenAnswer((_) async => Success(newUser));

      final result = await createUserUseCase(newUser);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, equals(newUser));
      verify(() => repository.create(newUser)).called(1);
    });

    test('CreateUserUseCase propagates ValidationFailure', () async {
      const invalidUser = User(id: '', name: '', email: 'invalid');
      when(() => repository.create(invalidUser)).thenAnswer(
        (_) async => Failure(ValidationFailure(
          'Validation failed',
          fieldErrors: {'email': ['Invalid email format']},
        )),
      );

      final result = await createUserUseCase(invalidUser);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      final failure = result.failureOrNull! as ValidationFailure;
      expect(failure.fieldErrors['email'], contains('Invalid email format'));
    });
  });

  group('Error Propagation Through Layers', () {
    late MockUserRepository repository;

    setUp(() {
      repository = MockUserRepository();
    });

    test('NetworkFailure propagates from repository to usecase', () async {
      when(() => repository.getById(any()))
          .thenAnswer((_) async => Failure(NetworkFailure('No connection')));

      final useCase = GetUserUseCase(repository);
      final result = await useCase('1');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(result.failureOrNull?.message, equals('No connection'));
    });

    test('ServerFailure propagates with status code', () async {
      when(() => repository.getById(any())).thenAnswer(
        (_) async => Failure(ServerFailure('Internal error', statusCode: 500)),
      );

      final useCase = GetUserUseCase(repository);
      final result = await useCase('1');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect((result.failureOrNull! as ServerFailure).statusCode, equals(500));
    });

    test('AuthFailure propagates for unauthorized access', () async {
      when(() => repository.getById(any()))
          .thenAnswer((_) async => Failure(AuthFailure('Session expired')));

      final useCase = GetUserUseCase(repository);
      final result = await useCase('1');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<AuthFailure>());
    });

    test('CacheFailure propagates from local storage', () async {
      when(() => repository.getById(any()))
          .thenAnswer((_) async => Failure(CacheFailure('Database error')));

      final useCase = GetUserUseCase(repository);
      final result = await useCase('1');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<CacheFailure>());
    });
  });

  group('Result Chaining Through Layers', () {
    late MockUserRepository repository;

    setUp(() {
      repository = MockUserRepository();
    });

    test('flatMap chains successful operations', () async {
      const user = User(id: '1', name: 'John', email: 'john@test.com');
      when(() => repository.getById('1')).thenAnswer((_) async => Success(user));

      final useCase = GetUserUseCase(repository);
      final result = await useCase('1');

      final nameResult = result.flatMap((u) => Success(u.name));
      final upperResult = nameResult.map((n) => n.toUpperCase());

      expect(upperResult.isSuccess, isTrue);
      expect(upperResult.valueOrNull, equals('JOHN'));
    });

    test('flatMap short-circuits on failure', () async {
      when(() => repository.getById('1'))
          .thenAnswer((_) async => Failure(NotFoundFailure('Not found')));

      final useCase = GetUserUseCase(repository);
      final result = await useCase('1');

      var transformCalled = false;
      final chainedResult = result.flatMap((u) {
        transformCalled = true;
        return Success(u.name);
      });

      expect(chainedResult.isFailure, isTrue);
      expect(transformCalled, isFalse);
    });

    test('Result.sequence combines multiple results', () async {
      const user1 = User(id: '1', name: 'John', email: 'john@test.com');
      const user2 = User(id: '2', name: 'Jane', email: 'jane@test.com');

      when(() => repository.getById('1')).thenAnswer((_) async => Success(user1));
      when(() => repository.getById('2')).thenAnswer((_) async => Success(user2));

      final useCase = GetUserUseCase(repository);
      final results = await Future.wait([useCase('1'), useCase('2')]);
      final combined = Result.sequence(results);

      expect(combined.isSuccess, isTrue);
      expect(combined.valueOrNull?.length, equals(2));
    });

    test('Result.sequence fails on first failure', () async {
      const user1 = User(id: '1', name: 'John', email: 'john@test.com');

      when(() => repository.getById('1')).thenAnswer((_) async => Success(user1));
      when(() => repository.getById('2'))
          .thenAnswer((_) async => Failure(NotFoundFailure('Not found')));

      final useCase = GetUserUseCase(repository);
      final results = await Future.wait([useCase('1'), useCase('2')]);
      final combined = Result.sequence(results);

      expect(combined.isFailure, isTrue);
      expect(combined.failureOrNull, isA<NotFoundFailure>());
    });
  });
}
