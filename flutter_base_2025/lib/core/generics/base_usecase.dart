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
