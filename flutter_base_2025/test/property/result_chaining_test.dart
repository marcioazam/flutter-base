import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart';

import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';

/// **Feature: flutter-state-of-art-2025, Property 2: Result Chaining Preserves Type**
/// **Validates: Requirements 4.2**
void main() {
  group('Result Chaining Properties', () {
    Glados<int>(iterations: 100).test(
      'andThen chains Success correctly',
      (value) {
        final result = Success(value);
        final chained = result.andThen((v) => Success(v.toString()));

        expect(chained.isSuccess, isTrue);
        expect(chained.valueOrNull, equals(value.toString()));
      },
    );

    Glados<int>(iterations: 100).test(
      'andThen preserves Failure',
      (value) {
        final failure = NetworkFailure('error');
        final Result<int> result = Failure(failure);
        final chained = result.andThen((v) => Success(v.toString()));

        expect(chained.isFailure, isTrue);
        expect(chained.failureOrNull, equals(failure));
      },
    );

    Glados<int>(iterations: 100).test(
      'tap executes side effect on Success',
      (value) {
        var sideEffectValue = 0;
        final result = Success(value);
        final tapped = result.tap((v) => sideEffectValue = v);

        expect(tapped.valueOrNull, equals(value));
        expect(sideEffectValue, equals(value));
      },
    );

    Glados<int>(iterations: 100).test(
      'tap does not execute on Failure',
      (value) {
        var sideEffectCalled = false;
        final Result<int> result = Failure(NetworkFailure('error'));
        result.tap((_) => sideEffectCalled = true);

        expect(sideEffectCalled, isFalse);
      },
    );

    Glados<int>(iterations: 100).test(
      'tapFailure executes side effect on Failure',
      (value) {
        var sideEffectCalled = false;
        final Result<int> result = Failure(NetworkFailure('error'));
        result.tapFailure((_) => sideEffectCalled = true);

        expect(sideEffectCalled, isTrue);
      },
    );

    Glados<int>(iterations: 100).test(
      'tapFailure does not execute on Success',
      (value) {
        var sideEffectCalled = false;
        final result = Success(value);
        result.tapFailure((_) => sideEffectCalled = true);

        expect(sideEffectCalled, isFalse);
      },
    );

    Glados2<int, String>(iterations: 100).test(
      'zip combines two Success results',
      (a, b) {
        final resultA = Success(a);
        final resultB = Success(b);
        final zipped = Result.zip(resultA, resultB);

        expect(zipped.isSuccess, isTrue);
        expect(zipped.valueOrNull, equals((a, b)));
      },
    );

    Glados<int>(iterations: 100).test(
      'zip returns Failure if first is Failure',
      (value) {
        final failure = NetworkFailure('error');
        final Result<int> resultA = Failure(failure);
        final resultB = Success(value.toString());
        final zipped = Result.zip(resultA, resultB);

        expect(zipped.isFailure, isTrue);
        expect(zipped.failureOrNull, equals(failure));
      },
    );

    Glados<int>(iterations: 100).test(
      'zip returns Failure if second is Failure',
      (value) {
        final failure = NetworkFailure('error');
        final resultA = Success(value);
        final Result<String> resultB = Failure(failure);
        final zipped = Result.zip(resultA, resultB);

        expect(zipped.isFailure, isTrue);
        expect(zipped.failureOrNull, equals(failure));
      },
    );

    Glados2<int, String>(iterations: 100).test(
      'zipWith combines with custom function',
      (a, b) {
        final resultA = Success(a);
        final resultB = Success(b);
        final zipped = Result.zipWith(resultA, resultB, (x, y) => '$x-$y');

        expect(zipped.isSuccess, isTrue);
        expect(zipped.valueOrNull, equals('$a-$b'));
      },
    );

    test('sequence combines list of Success', () {
      final results = [Success(1), Success(2), Success(3)];
      final sequenced = Result.sequence(results);

      expect(sequenced.isSuccess, isTrue);
      expect(sequenced.valueOrNull, equals([1, 2, 3]));
    });

    test('sequence returns first Failure', () {
      final failure = NetworkFailure('error');
      final results = [
        Success(1),
        Failure<int>(failure),
        Success(3),
      ];
      final sequenced = Result.sequence(results);

      expect(sequenced.isFailure, isTrue);
      expect(sequenced.failureOrNull, equals(failure));
    });

    Glados<List<int>>(iterations: 100).test(
      'traverse maps and sequences correctly',
      (values) {
        final result = Result.traverse(values, (v) => Success(v * 2));

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(values.map((v) => v * 2).toList()));
      },
    );

    Glados3<int, int, int>(iterations: 100).test(
      'zip3 combines three Success results',
      (a, b, c) {
        final resultA = Success(a);
        final resultB = Success(b);
        final resultC = Success(c);
        final zipped = Result.zip3(resultA, resultB, resultC);

        expect(zipped.isSuccess, isTrue);
        expect(zipped.valueOrNull, equals((a, b, c)));
      },
    );

    Glados<int>(iterations: 100).test(
      'chaining multiple andThen preserves type',
      (value) {
        final result = Success(value)
            .andThen((v) => Success(v * 2))
            .andThen((v) => Success(v.toString()))
            .andThen((v) => Success(v.length));

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, isA<int>());
      },
    );
  });
}
