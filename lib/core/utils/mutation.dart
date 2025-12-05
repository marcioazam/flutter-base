import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mutation state for tracking side-effect operations.
sealed class MutationState<T> {
  const MutationState();
}

/// Initial state before mutation starts.
final class MutationIdle<T> extends MutationState<T> {
  const MutationIdle();
}

/// Mutation is in progress.
final class MutationLoading<T> extends MutationState<T> {
  final double? progress;
  const MutationLoading({this.progress});
}

/// Mutation completed successfully.
final class MutationSuccess<T> extends MutationState<T> {
  final T data;
  const MutationSuccess(this.data);
}

/// Mutation failed with error.
final class MutationError<T> extends MutationState<T> {
  final Object error;
  final StackTrace stackTrace;
  const MutationError(this.error, this.stackTrace);
}

/// Mutation controller for managing side-effect operations with UI feedback.
class Mutation<T> extends StateNotifier<MutationState<T>> {
  Mutation() : super(const MutationIdle());

  /// Whether mutation is currently loading.
  bool get isLoading => state is MutationLoading<T>;

  /// Whether mutation completed successfully.
  bool get isSuccess => state is MutationSuccess<T>;

  /// Whether mutation failed.
  bool get isError => state is MutationError<T>;

  /// Whether mutation is idle.
  bool get isIdle => state is MutationIdle<T>;

  /// Gets the success data if available.
  T? get data => state is MutationSuccess<T> 
      ? (state as MutationSuccess<T>).data 
      : null;

  /// Gets the error if available.
  Object? get error => state is MutationError<T> 
      ? (state as MutationError<T>).error 
      : null;

  /// Executes a mutation operation.
  Future<T?> mutate(Future<T> Function() operation) async {
    state = const MutationLoading();
    try {
      final result = await operation();
      state = MutationSuccess(result);
      return result;
    } catch (e, st) {
      state = MutationError(e, st);
      return null;
    }
  }

  /// Executes a mutation with progress tracking.
  Future<T?> mutateWithProgress(
    Future<T> Function(void Function(double) onProgress) operation,
  ) async {
    state = const MutationLoading(progress: 0);
    try {
      final result = await operation((progress) {
        state = MutationLoading(progress: progress);
      });
      state = MutationSuccess(result);
      return result;
    } catch (e, st) {
      state = MutationError(e, st);
      return null;
    }
  }

  /// Resets mutation to idle state.
  void reset() {
    state = const MutationIdle();
  }
}

/// Provider family for creating mutation instances.
final mutationProvider = StateNotifierProvider.family<Mutation<dynamic>, 
    MutationState<dynamic>, String>(
  (ref, key) => Mutation<dynamic>(),
);

/// Extension for using mutations with Ref.
extension MutationRefExtension on Ref {
  /// Creates or gets a mutation by key.
  Mutation<T> mutation<T>(String key) {
    return read(mutationProvider(key)) as Mutation<T>;
  }
}
