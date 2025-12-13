import 'package:flutter_base_2025/core/utils/result.dart';

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
  CompositeUseCase(this._useCases, this._finalMapper);
  final List<UseCase<dynamic, dynamic>> _useCases;
  final R Function(dynamic) _finalMapper;

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

/// Cancellation token for use cases.
class CancellationToken {
  bool _isCancelled = false;

  /// Returns true if cancellation was requested.
  bool get isCancelled => _isCancelled;

  /// Requests cancellation.
  void cancel() => _isCancelled = true;

  /// Resets the token.
  void reset() => _isCancelled = false;

  /// Throws if cancelled.
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CancelledException();
    }
  }
}

/// Exception thrown when operation is cancelled.
class CancelledException implements Exception {
  const CancelledException([this.message = 'Operation cancelled']);
  final String message;

  @override
  String toString() => 'CancelledException: $message';
}

/// Use case that can be cancelled.
abstract class CancellableUseCase<Params, R> implements UseCase<Params, R> {
  CancellationToken? _token;

  /// Cancels the use case execution.
  void cancel() => _token?.cancel();

  /// Returns true if the use case was cancelled.
  bool get isCancelled => _token?.isCancelled ?? false;

  /// Resets the cancellation state.
  void reset() => _token?.reset();

  /// Executes with cancellation support.
  Future<Result<R>> callWithToken(Params params, CancellationToken token) {
    _token = token;
    return call(params);
  }

  /// Checks if cancelled and throws if so.
  void checkCancellation() {
    _token?.throwIfCancelled();
  }
}
