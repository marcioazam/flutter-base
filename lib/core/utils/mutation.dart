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
  const MutationLoading({this.progress});
  final double? progress;
}

/// Mutation completed successfully.
final class MutationSuccess<T> extends MutationState<T> {
  const MutationSuccess(this.data);
  final T data;
}

/// Mutation failed with error.
final class MutationError<T> extends MutationState<T> {
  const MutationError(this.error, this.stackTrace);
  final Object error;
  final StackTrace stackTrace;
}

/// Mutation controller for managing side-effect operations with UI feedback.
/// Uses a simple class-based approach compatible with Riverpod 3.0.
class MutationController<T> {
  MutationController() : _state = const MutationIdle();

  MutationState<T> _state;
  final List<void Function(MutationState<T>)> _listeners = [];

  /// Current mutation state.
  MutationState<T> get state => _state;

  /// Whether mutation is currently loading.
  bool get isLoading => _state is MutationLoading<T>;

  /// Whether mutation completed successfully.
  bool get isSuccess => _state is MutationSuccess<T>;

  /// Whether mutation failed.
  bool get isError => _state is MutationError<T>;

  /// Whether mutation is idle.
  bool get isIdle => _state is MutationIdle<T>;

  /// Gets the success data if available.
  T? get data => _state is MutationSuccess<T> 
      ? (_state as MutationSuccess<T>).data 
      : null;

  /// Gets the error if available.
  Object? get error => _state is MutationError<T> 
      ? (_state as MutationError<T>).error 
      : null;

  void _setState(MutationState<T> newState) {
    _state = newState;
    for (final listener in _listeners) {
      listener(newState);
    }
  }

  /// Adds a listener for state changes.
  void addListener(void Function(MutationState<T>) listener) {
    _listeners.add(listener);
  }

  /// Removes a listener.
  void removeListener(void Function(MutationState<T>) listener) {
    _listeners.remove(listener);
  }

  /// Executes a mutation operation.
  Future<T?> mutate(Future<T> Function() operation) async {
    _setState(MutationLoading<T>());
    try {
      final result = await operation();
      _setState(MutationSuccess<T>(result));
      return result;
    } catch (e, st) {
      _setState(MutationError<T>(e, st));
      return null;
    }
  }

  /// Executes a mutation with progress tracking.
  Future<T?> mutateWithProgress(
    Future<T> Function(void Function(double) onProgress) operation,
  ) async {
    _setState(MutationLoading<T>(progress: 0));
    try {
      final result = await operation((progress) {
        _setState(MutationLoading<T>(progress: progress));
      });
      _setState(MutationSuccess<T>(result));
      return result;
    } catch (e, st) {
      _setState(MutationError<T>(e, st));
      return null;
    }
  }

  /// Resets mutation to idle state.
  void reset() {
    _setState(MutationIdle<T>());
  }

  /// Disposes the controller.
  void dispose() {
    _listeners.clear();
  }
}

/// Provider for creating mutation controller instances.
final mutationControllerProvider = Provider.family<MutationController<dynamic>, String>(
  (ref, key) {
    final controller = MutationController<dynamic>();
    ref.onDispose(controller.dispose);
    return controller;
  },
);

/// Extension for using mutations with Ref.
extension MutationRefExtension on Ref {
  /// Creates or gets a mutation controller by key.
  MutationController<T> mutation<T>(String key) => 
      read(mutationControllerProvider(key)) as MutationController<T>;
}
