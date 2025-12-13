import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-base-2025, Property 21: Result Type Consistency**
/// **Validates: Requirements 13.1**
void main() {
  group('Result Type', () {
    group('Success', () {
      test('isSuccess returns true', () {
        const result = Success(42);
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('valueOrNull returns value', () {
        const result = Success('test');
        expect(result.valueOrNull, equals('test'));
      });

      test('failureOrNull returns null', () {
        const result = Success(42);
        expect(result.failureOrNull, isNull);
      });

      test('fold calls onSuccess', () {
        const result = Success(42);
        final folded = result.fold(
          (f) => 'failure',
          (v) => 'success: $v',
        );
        expect(folded, equals('success: 42'));
      });

      test('map transforms value', () {
        const result = Success(42);
        final mapped = result.map((v) => v * 2);
        expect(mapped.valueOrNull, equals(84));
      });

      test('flatMap chains results', () {
        const result = Success(42);
        final chained = result.flatMap((v) => Success(v.toString()));
        expect(chained.valueOrNull, equals('42'));
      });

      test('getOrElse returns value', () {
        const result = Success(42);
        expect(result.getOrElse(() => 0), equals(42));
      });

      test('getOrThrow returns value', () {
        const result = Success(42);
        expect(result.getOrThrow(), equals(42));
      });
    });

    group('Failure', () {
      test('isFailure returns true', () {
        const result = Failure<int>(NetworkFailure('error'));
        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('valueOrNull returns null', () {
        const result = Failure<int>(NetworkFailure('error'));
        expect(result.valueOrNull, isNull);
      });

      test('failureOrNull returns failure', () {
        const failure = NetworkFailure('error');
        const result = Failure<int>(failure);
        expect(result.failureOrNull, equals(failure));
      });

      test('fold calls onFailure', () {
        const result = Failure<int>(NetworkFailure('error'));
        final folded = result.fold(
          (f) => 'failure: ${f.message}',
          (v) => 'success',
        );
        expect(folded, equals('failure: error'));
      });

      test('map preserves failure', () {
        const result = Failure<int>(NetworkFailure('error'));
        final mapped = result.map((v) => v * 2);
        expect(mapped.isFailure, isTrue);
      });

      test('flatMap preserves failure', () {
        const result = Failure<int>(NetworkFailure('error'));
        final chained = result.flatMap((v) => Success(v.toString()));
        expect(chained.isFailure, isTrue);
      });

      test('getOrElse returns default', () {
        const result = Failure<int>(NetworkFailure('error'));
        expect(result.getOrElse(() => 99), equals(99));
      });

      test('getOrThrow throws failure', () {
        const result = Failure<int>(NetworkFailure('error'));
        expect(() => result.getOrThrow(), throwsA(isA<NetworkFailure>()));
      });
    });

    group('Property Tests', () {
      /// **Property 21: Result Type Consistency**
      /// For any operation failure, the return type SHALL be Result.Failure with typed AppFailure.
      Glados<int>(any.int, _explore).test(
        'Success.fold always calls onSuccess callback',
        (value) {
          final result = Success(value);
          var successCalled = false;
          var failureCalled = false;

          result.fold(
            (_) => failureCalled = true,
            (_) => successCalled = true,
          );

          expect(successCalled, isTrue);
          expect(failureCalled, isFalse);
        },
      );

      Glados<String>(any.nonEmptyLetters, _explore).test(
        'Failure.fold always calls onFailure callback',
        (message) {
          final result = Failure<int>(NetworkFailure(message));
          var successCalled = false;
          var failureCalled = false;

          result.fold(
            (_) => failureCalled = true,
            (_) => successCalled = true,
          );

          expect(failureCalled, isTrue);
          expect(successCalled, isFalse);
        },
      );

      Glados<int>(any.int, _explore).test(
        'Success.map preserves Success type',
        (value) {
          final result = Success(value);
          final mapped = result.map((v) => v.toString());

          expect(mapped.isSuccess, isTrue);
          expect(mapped.valueOrNull, equals(value.toString()));
        },
      );

      Glados<String>(any.nonEmptyLetters, _explore).test(
        'Failure.map preserves Failure type and failure value',
        (message) {
          final failure = NetworkFailure(message);
          final result = Failure<int>(failure);
          final mapped = result.map((v) => v.toString());

          expect(mapped.isFailure, isTrue);
          expect(mapped.failureOrNull, equals(failure));
        },
      );

      Glados<int>(any.int, _explore).test(
        'Success equality is based on value',
        (value) {
          final result1 = Success(value);
          final result2 = Success(value);

          expect(result1, equals(result2));
          expect(result1.hashCode, equals(result2.hashCode));
        },
      );
    });
  });
}
