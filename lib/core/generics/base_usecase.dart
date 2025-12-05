import '../errors/failures.dart';
import '../utils/result.dart';

/// Generic use case interface.
/// Params = Input parameters type, R = Result type
abstract interface class UseCase<Params, R> {
  /// Executes the use case.
  Future<Result<R>> call(Params params);
}

/// Use case without parameters.
abstract interface class NoParamsUseCase<R> {
  /// Executes the use case.
  Future<Result<R>> call();
}

/// Use case that returns a stream.
abstract interface class StreamUseCase<Params, R> {
  /// Executes the use case returning a stream.
  Stream<Result<R>> call(Params params);
}

/// Singleton for use cases without parameters.
final class NoParams {
  const NoParams._();
  static const instance = NoParams._();
}

/// Composite use case for chaining multiple operations.
/// 
/// **Feature: flutter-2025-state-of-art-review**
/// **Validates: Requirements 2.4**
class CompositeUseCase<Params, R> implements UseCase<Params, R> {
  final List<UseCase<dynamic, dynamic>> _useCases;
  final R Function(dynamic) _finalMapper;

  CompositeUseCase(this._useCases, this._finalMapper);

  @override
  Future<Result<R>> call(Params params) async {
    dynamic current = params;

    for (final useCase in _useCases) {
      final result = await useCase.call(current);
      
      if (result.isFailure) {
        return Failure(result.failureOrNull!);
      }
      
      current = result.valueOrNull;
    }

    return Success(_finalMapper(current));
  }
}

/// Stream use case without parameters.
abstract interface class NoParamsStreamUseCase<R> {
  /// Executes the use case returning a stream.
  Stream<Result<R>> call();
}

/// Use case that can be cancelled.
abstract class CancellableUseCase<Params, R> implements UseCase<Params, R> {
  bool _isCancelled = false;

  /// Cancels the use case execution.
  void cancel() => _isCancelled = true;

  /// Returns true if the use case was cancelled.
  bool get isCancelled => _isCancelled;

  /// Resets the cancellation state.
  void reset() => _isCancelled = false;
}
