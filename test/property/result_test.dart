import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-modernization-2025, Property 14: Result Type Fold Exhaustiveness**
/// **Validates: Requirements 2.2, 14.3**
void main() {
  group('Result Type Properties', () {
    Glados<int>(any.int, _explore).test(
      'Result.fold executes exactly one handler for Success',
      (value) {
        var successCalled = false;
        var failureCalled = false;

        final result = Success(value);
        result.fold((_) => failureCalled = true, (_) => successCalled = true);

        expect(successCalled, isTrue);
        expect(failureCalled, isFalse);
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'Result.fold executes exactly one handler for Failure',
      (message) {
        var successCalled = false;
        var failureCalled = false;

        final Result<int> result = Failure(NetworkFailure(message));
        result.fold((_) => failureCalled = true, (_) => successCalled = true);

        expect(successCalled, isFalse);
        expect(failureCalled, isTrue);
      },
    );

    Glados<int>(any.int, _explore).test(
      'Success.map transforms value correctly',
      (value) {
        final result = Success(value);
        final mapped = result.map((v) => v * 2);

        expect(mapped.isSuccess, isTrue);
        expect(mapped.valueOrNull, equals(value * 2));
      },
    );

    Glados<int>(any.int, _explore).test('Failure.map preserves failure', (
      value,
    ) {
      final failure = NetworkFailure('error');
      final Result<int> result = Failure(failure);
      final mapped = result.map((v) => v * 2);

      expect(mapped.isFailure, isTrue);
      expect(mapped.failureOrNull, equals(failure));
    });

    Glados<int>(any.int, _explore).test('Success.flatMap chains correctly', (
      value,
    ) {
      final result = Success(value);
      final chained = result.flatMap((v) => Success(v.toString()));

      expect(chained.isSuccess, isTrue);
      expect(chained.valueOrNull, equals(value.toString()));
    });

    Glados<int>(any.int, _explore).test('Success.getOrElse returns value', (
      value,
    ) {
      final result = Success(value);
      expect(result.getOrElse(() => -1), equals(value));
    });

    Glados<int>(any.int, _explore).test('Failure.getOrElse returns default', (
      defaultValue,
    ) {
      final Result<int> result = Failure(NetworkFailure('error'));
      expect(result.getOrElse(() => defaultValue), equals(defaultValue));
    });

    Glados<int>(any.int, _explore).test('Success.orElse returns original', (
      value,
    ) {
      final result = Success(value);
      final alternative = result.orElse(() => Success(-1));

      expect(alternative.valueOrNull, equals(value));
    });

    Glados<int>(any.int, _explore).test('Failure.orElse returns alternative', (
      alternativeValue,
    ) {
      final Result<int> result = Failure(NetworkFailure('error'));
      final alternative = result.orElse(() => Success(alternativeValue));

      expect(alternative.valueOrNull, equals(alternativeValue));
    });

    Glados<int>(any.int, _explore).test('Success.recover returns original', (
      value,
    ) {
      final result = Success(value);
      final recovered = result.recover((_) => -1);

      expect(recovered.valueOrNull, equals(value));
    });

    Glados<int>(any.int, _explore).test(
      'Failure.recover returns recovered value',
      (recoveryValue) {
        final Result<int> result = Failure(NetworkFailure('error'));
        final recovered = result.recover((_) => recoveryValue);

        expect(recovered.isSuccess, isTrue);
        expect(recovered.valueOrNull, equals(recoveryValue));
      },
    );

    test('Success equality works correctly', () {
      expect(Success(42), equals(Success(42)));
      expect(Success(42), isNot(equals(Success(43))));
    });

    test('Failure equality works correctly', () {
      final failure1 = NetworkFailure('error');
      final failure2 = NetworkFailure('error');
      final failure3 = NetworkFailure('different');

      expect(Failure<int>(failure1), equals(Failure<int>(failure2)));
      expect(Failure<int>(failure1), isNot(equals(Failure<int>(failure3))));
    });
  });

  /// **Feature: flutter-state-of-art-2025, Property 3: Result Monad Left Identity**
  /// **Validates: Requirements 4.1, 10.4**
  group('Result Monad Laws', () {
    // Helper function for testing
    Result<String> intToStringResult(int x) => Success(x.toString());
    Result<int> stringToIntResult(String s) => Success(s.length);

    Glados<int>(any.int, _explore).test(
      'Left Identity: Success(a).flatMap(f) == f(a)',
      (value) {
        // Left identity: return a >>= f  ≡  f a
        // Success(a).flatMap(f) should equal f(a)
        final leftSide = Success(value).flatMap(intToStringResult);
        final rightSide = intToStringResult(value);

        expect(leftSide.isSuccess, equals(rightSide.isSuccess));
        expect(leftSide.valueOrNull, equals(rightSide.valueOrNull));
      },
    );

    /// **Feature: flutter-state-of-art-2025, Property 4: Result Monad Right Identity**
    /// **Validates: Requirements 4.1, 10.4**
    Glados<int>(any.int, _explore).test(
      'Right Identity: m.flatMap(Success) == m',
      (value) {
        // Right identity: m >>= return  ≡  m
        // m.flatMap(Success) should equal m
        final m = Success(value);
        final leftSide = m.flatMap(Success.new);

        expect(leftSide.isSuccess, equals(m.isSuccess));
        expect(leftSide.valueOrNull, equals(m.valueOrNull));
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'Right Identity for Failure: m.flatMap(Success) == m',
      (message) {
        final failure = NetworkFailure(message);
        final Result<int> m = Failure(failure);
        final leftSide = m.flatMap(Success.new);

        expect(leftSide.isFailure, equals(m.isFailure));
        expect(leftSide.failureOrNull, equals(m.failureOrNull));
      },
    );

    /// **Feature: flutter-state-of-art-2025, Property 5: Result Monad Associativity**
    /// **Validates: Requirements 4.1, 10.4**
    Glados<int>(any.int, _explore).test(
      'Associativity: (m.flatMap(f)).flatMap(g) == m.flatMap((x) => f(x).flatMap(g))',
      (value) {
        // Associativity: (m >>= f) >>= g  ≡  m >>= (λx → f x >>= g)
        final m = Success(value);

        // Left side: (m.flatMap(f)).flatMap(g)
        final leftSide = m
            .flatMap(intToStringResult)
            .flatMap(stringToIntResult);

        // Right side: m.flatMap((x) => f(x).flatMap(g))
        final rightSide = m.flatMap(
          (x) => intToStringResult(x).flatMap(stringToIntResult),
        );

        expect(leftSide.isSuccess, equals(rightSide.isSuccess));
        expect(leftSide.valueOrNull, equals(rightSide.valueOrNull));
      },
    );

    Glados<String>(
      any.nonEmptyLetters,
      _explore,
    ).test('Associativity for Failure propagates correctly', (message) {
      final failure = NetworkFailure(message);
      final Result<int> m = Failure(failure);

      final leftSide = m.flatMap(intToStringResult).flatMap(stringToIntResult);
      final rightSide = m.flatMap(
        (x) => intToStringResult(x).flatMap(stringToIntResult),
      );

      expect(leftSide.isFailure, isTrue);
      expect(rightSide.isFailure, isTrue);
      expect(leftSide.failureOrNull, equals(rightSide.failureOrNull));
    });
  });

  /// **Feature: flutter-state-of-art-2025-final, Property 4: Failure Propagation**
  /// **Validates: Requirements 3.4**
  group('Failure Propagation Properties', () {
    Glados<String>(any.nonEmptyLetters, _explore).test(
      'Failure.map preserves original failure through any mapper',
      (message) {
        final failure = NetworkFailure(message);
        final Result<int> result = Failure(failure);

        final mapped = result.map((v) => v * 2);
        final mappedAgain = mapped.map((v) => v.toString());

        expect(mapped.isFailure, isTrue);
        expect(mappedAgain.isFailure, isTrue);
        expect(mapped.failureOrNull, equals(failure));
        expect(mappedAgain.failureOrNull, equals(failure));
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'Failure.flatMap preserves original failure through any chain',
      (message) {
        final failure = ServerFailure(message, statusCode: 500);
        final Result<int> result = Failure(failure);

        final chained = result
            .flatMap((v) => Success(v * 2))
            .flatMap((v) => Success(v.toString()))
            .flatMap((v) => Success(v.length));

        expect(chained.isFailure, isTrue);
        expect(chained.failureOrNull, equals(failure));
      },
    );
  });

  /// **Feature: flutter-state-of-art-2025-final, New Combinators Tests**
  /// **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
  group('Result New Combinators', () {
    Glados<int>(any.int, _explore).test(
      'Result.fromNullable returns Success for non-null values',
      (value) {
        final result = Result.fromNullable<int>(value);
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(value));
      },
    );

    test('Result.fromNullable returns Failure for null values', () {
      final result = Result.fromNullable<int>(null);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    Glados<int>(any.int, _explore).test(
      'Result.tryCatch returns Success for non-throwing computation',
      (value) {
        final result = Result.tryCatch(() => value * 2);
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(value * 2));
      },
    );

    test('Result.tryCatch returns Failure for throwing computation', () {
      final result = Result.tryCatch<int>(() => throw Exception('test error'));
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnexpectedFailure>());
    });

    Glados<int>(any.int, _explore).test(
      'Result.fromCondition returns Success when condition is true',
      (value) {
        final result = Result.fromCondition(
          condition: true,
          value: () => value,
        );
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(value));
      },
    );

    Glados<int>(any.int, _explore).test(
      'Result.fromCondition returns Failure when condition is false',
      (value) {
        final result = Result.fromCondition(
          condition: false,
          value: () => value,
        );
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
      },
    );

    test('Result.combine returns Success when all results are Success', () {
      final results = [Success(1), Success(2), Success(3)];
      final combined = Result.combine(results);

      expect(combined.isSuccess, isTrue);
      expect(combined.valueOrNull, equals([1, 2, 3]));
    });

    test('Result.combine returns first Failure when any result is Failure', () {
      final failure = NetworkFailure('error');
      final results = [Success(1), Failure<int>(failure), Success(3)];
      final combined = Result.combine(results);

      expect(combined.isFailure, isTrue);
      expect(combined.failureOrNull, equals(failure));
    });
  });
}
