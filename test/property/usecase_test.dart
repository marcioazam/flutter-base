import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/generics/base_usecase.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown, setUpAll, tearDownAll;

// Configure Glados for 100 iterations
final _explore = ExploreConfig(numRuns: 100);

/// **Feature: flutter-modernization-2025, Property 5: UseCase Return Type Consistency**
/// **Validates: Requirements 14.1, 14.3**

/// Test use case that doubles a number.
class DoubleNumberUseCase implements UseCase<int, int> {
  @override
  Future<Result<int>> call(int params) async => Success(params * 2);
}

/// Test use case that fails.
class FailingUseCase implements UseCase<int, int> {
  @override
  Future<Result<int>> call(int params) async =>
      Failure(ServerFailure('Test failure'));
}

/// Test use case without params.
class GetConstantUseCase implements NoParamsUseCase<int> {
  @override
  Future<Result<int>> call() async => Success(42);
}

/// Test stream use case.
class CounterStreamUseCase implements StreamUseCase<int, int> {
  @override
  Stream<Result<int>> call(int params) async* {
    for (var i = 0; i < params; i++) {
      yield Success(i);
    }
  }
}

void main() {
  group('UseCase Return Type Properties', () {
    Glados<int>(any.int, _explore).test(
      'UseCase returns Result with correct type',
      (input) async {
        final useCase = DoubleNumberUseCase();
        final result = await useCase.call(input);

        expect(result, isA<Result<int>>());
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(input * 2));
      },
    );

    Glados<int>(any.int, _explore).test(
      'Failing UseCase returns Failure with correct type',
      (input) async {
        final useCase = FailingUseCase();
        final result = await useCase.call(input);

        expect(result, isA<Result<int>>());
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ServerFailure>());
      },
    );

    test('NoParamsUseCase returns Result without parameters', () async {
      final useCase = GetConstantUseCase();
      final result = await useCase.call();

      expect(result, isA<Result<int>>());
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, equals(42));
    });

    test('NoParams singleton is consistent', () {
      expect(NoParams.instance, same(NoParams.instance));
    });

    Glados<int>(any.int, _explore).test(
      'StreamUseCase emits correct number of Results',
      (count) async {
        final validCount = count.abs() % 10 + 1;
        final useCase = CounterStreamUseCase();
        final results = await useCase.call(validCount).toList();

        expect(results.length, equals(validCount));
        for (var i = 0; i < validCount; i++) {
          expect(results[i].isSuccess, isTrue);
          expect(results[i].valueOrNull, equals(i));
        }
      },
    );
  });

  group('UseCase Interface Compliance', () {
    test('UseCase interface requires call method', () {
      final useCase = DoubleNumberUseCase();
      expect(useCase, isA<UseCase<int, int>>());
    });

    test('NoParamsUseCase interface requires call method', () {
      final useCase = GetConstantUseCase();
      expect(useCase, isA<NoParamsUseCase<int>>());
    });

    test('StreamUseCase interface requires call method', () {
      final useCase = CounterStreamUseCase();
      expect(useCase, isA<StreamUseCase<int, int>>());
    });
  });
}
