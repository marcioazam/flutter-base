import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:meta/meta.dart';

/// Result type para operações que podem falhar.
/// Implementa Either pattern simplificado com sealed classes do Dart 3.
sealed class Result<T> {
  const Result();

  /// Transforma o Result aplicando funções para cada caso.
  R fold<R>(
    R Function(AppFailure failure) onFailure,
    R Function(T value) onSuccess,
  );

  /// Retorna true se o Result é Success.
  bool get isSuccess;

  /// Retorna true se o Result é Failure.
  bool get isFailure;

  /// Retorna o valor se Success, ou null se Failure.
  T? get valueOrNull;

  /// Retorna a falha se Failure, ou null se Success.
  AppFailure? get failureOrNull;

  /// Mapeia o valor de Success para outro tipo.
  Result<R> map<R>(R Function(T value) mapper);

  /// Mapeia o valor de Success para outro Result.
  Result<R> flatMap<R>(Result<R> Function(T value) mapper);

  /// Async map operation.
  Future<Result<R>> mapAsync<R>(Future<R> Function(T value) mapper);

  /// Async flatMap operation.
  Future<Result<R>> flatMapAsync<R>(Future<Result<R>> Function(T value) mapper);

  /// Retorna o valor ou um valor padrão.
  T getOrElse(T Function() defaultValue);

  /// Retorna o valor ou lança a exceção.
  T getOrThrow();

  /// Returns alternative result if this is failure.
  Result<T> orElse(Result<T> Function() alternative);

  /// Recovers from failure with a value.
  Result<T> recover(T Function(AppFailure) recovery);

  /// Chain operations (andThen) - alias for flatMap.
  Result<R> andThen<R>(Result<R> Function(T) next);

  /// Tap for side effects without changing value.
  Result<T> tap(void Function(T) action);

  /// Tap failure for side effects without changing value.
  Result<T> tapFailure(void Function(AppFailure) action);

  /// Zip two Results into a tuple.
  static Result<(A, B)> zip<A, B>(Result<A> a, Result<B> b) =>
      a.flatMap((va) => b.map((vb) => (va, vb)));

  /// Zip three Results into a tuple.
  static Result<(A, B, C)> zip3<A, B, C>(
    Result<A> a,
    Result<B> b,
    Result<C> c,
  ) => a.flatMap((va) => b.flatMap((vb) => c.map((vc) => (va, vb, vc))));

  /// Zip with a combiner function.
  static Result<R> zipWith<A, B, R>(
    Result<A> a,
    Result<B> b,
    R Function(A, B) combiner,
  ) => a.flatMap((va) => b.map((vb) => combiner(va, vb)));

  /// Sequence a list of Results into a Result of list.
  static Result<List<T>> sequence<T>(List<Result<T>> results) {
    final values = <T>[];
    for (final result in results) {
      if (result.isFailure) {
        return Failure(result.failureOrNull!);
      }
      values.add(result.valueOrNull as T);
    }
    return Success(values);
  }

  /// Traverse a list with a function that returns Result.
  static Result<List<R>> traverse<T, R>(
    List<T> items,
    Result<R> Function(T) fn,
  ) => sequence(items.map(fn).toList());

  /// Creates a Result from a nullable value.
  /// Returns Success if value is not null, Failure otherwise.
  static Result<T> fromNullable<T>(T? value, {AppFailure Function()? onNull}) {
    if (value != null) {
      return Success(value);
    }
    return Failure(onNull?.call() ?? const NotFoundFailure('Value is null'));
  }

  /// Wraps a synchronous computation that might throw.
  /// Returns Success with the result or Failure with the exception.
  static Result<T> tryCatch<T>(
    T Function() computation, {
    AppFailure Function(Object error, StackTrace stackTrace)? onError,
  }) {
    try {
      return Success(computation());
    } on Exception catch (e, st) {
      return Failure(
        onError?.call(e, st) ?? UnexpectedFailure(e.toString(), stackTrace: st),
      );
    }
  }

  /// Wraps an async computation that might throw.
  /// Returns Success with the result or Failure with the exception.
  static Future<Result<T>> fromFuture<T>(
    Future<T> Function() computation, {
    AppFailure Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      return Success(await computation());
    } on Exception catch (e, st) {
      return Failure(
        onError?.call(e, st) ?? UnexpectedFailure(e.toString(), stackTrace: st),
      );
    }
  }

  /// Creates a Result from a boolean condition.
  /// Returns Success with value if condition is true, Failure otherwise.
  static Result<T> fromCondition<T>({
    required bool condition,
    required T Function() value,
    AppFailure Function()? onFalse,
  }) {
    if (condition) {
      return Success(value());
    }
    return Failure(
      onFalse?.call() ?? const ValidationFailure('Condition not met'),
    );
  }

  /// Combines multiple Results, returning first failure or all successes.
  static Result<List<T>> combine<T>(List<Result<T>> results) =>
      sequence(results);
}

/// Representa uma operação bem-sucedida com um valor.
@immutable
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;

  @override
  R fold<R>(
    R Function(AppFailure failure) onFailure,
    R Function(T value) onSuccess,
  ) => onSuccess(value);

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  T? get valueOrNull => value;

  @override
  AppFailure? get failureOrNull => null;

  @override
  Result<R> map<R>(R Function(T value) mapper) => Success(mapper(value));

  @override
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) => mapper(value);

  @override
  Future<Result<R>> mapAsync<R>(Future<R> Function(T value) mapper) async =>
      Success(await mapper(value));

  @override
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T value) mapper,
  ) => mapper(value);

  @override
  T getOrElse(T Function() defaultValue) => value;

  @override
  T getOrThrow() => value;

  @override
  Result<T> orElse(Result<T> Function() alternative) => this;

  @override
  Result<T> recover(T Function(AppFailure) recovery) => this;

  @override
  Result<R> andThen<R>(Result<R> Function(T) next) => next(value);

  @override
  Result<T> tap(void Function(T) action) {
    action(value);
    return this;
  }

  @override
  Result<T> tapFailure(void Function(AppFailure) action) => this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Representa uma operação que falhou com uma AppFailure.
@immutable
final class Failure<T> extends Result<T> {
  const Failure(this.failure);
  final AppFailure failure;

  @override
  R fold<R>(
    R Function(AppFailure failure) onFailure,
    R Function(T value) onSuccess,
  ) => onFailure(failure);

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  T? get valueOrNull => null;

  @override
  AppFailure? get failureOrNull => failure;

  @override
  Result<R> map<R>(R Function(T value) mapper) => Failure(failure);

  @override
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) => Failure(failure);

  @override
  Future<Result<R>> mapAsync<R>(Future<R> Function(T value) mapper) async =>
      Failure(failure);

  @override
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T value) mapper,
  ) async => Failure(failure);

  @override
  T getOrElse(T Function() defaultValue) => defaultValue();

  @override
  T getOrThrow() => throw failure;

  @override
  Result<T> orElse(Result<T> Function() alternative) => alternative();

  @override
  Result<T> recover(T Function(AppFailure) recovery) =>
      Success(recovery(failure));

  @override
  Result<R> andThen<R>(Result<R> Function(T) next) => Failure(failure);

  @override
  Result<T> tap(void Function(T) action) => this;

  @override
  Result<T> tapFailure(void Function(AppFailure) action) {
    action(failure);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Failure($failure)';
}

/// Extension para criar Results de forma mais conveniente.
extension ResultExtensions<T> on T {
  Result<T> toSuccess() => Success(this);
}

extension FailureExtensions on AppFailure {
  Result<T> toFailure<T>() => Failure<T>(this);
}
