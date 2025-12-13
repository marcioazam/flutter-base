import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mutation state for tracking side-effect operations.
///
/// **Feature: flutter-2025-final-enhancements, Property 1: Mutation State Transitions**
/// **Validates: Requirements 1.2**
sealed class MutationState<T> {
  const MutationState();

  /// Pattern matching helper for all states.
  R when<R>({
    required R Function() idle,
    required R Function(double? progress) loading,
    required R Function(T data) success,
    required R Function(Object error, StackTrace stackTrace) error,
  }) => switch (this) {
    MutationIdle() => idle(),
    MutationLoading(:final progress) => loading(progress),
    MutationSuccess(:final data) => success(data),
    final MutationError<T> e => error(e.error, e.stackTrace),
  };

  /// Pattern matching with default fallback.
  R maybeWhen<R>({
    required R Function() orElse,
    R Function()? idle,
    R Function(double? progress)? loading,
    R Function(T data)? success,
    R Function(Object error, StackTrace stackTrace)? error,
  }) => switch (this) {
    MutationIdle() => idle?.call() ?? orElse(),
    MutationLoading(:final progress) => loading?.call(progress) ?? orElse(),
    MutationSuccess(:final data) => success?.call(data) ?? orElse(),
    final MutationError<T> e => error?.call(e.error, e.stackTrace) ?? orElse(),
  };
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
  T? get data =>
      _state is MutationSuccess<T> ? (_state as MutationSuccess<T>).data : null;

  /// Gets the error if available.
  Object? get error =>
      _state is MutationError<T> ? (_state as MutationError<T>).error : null;

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
    } on Exception catch (e, st) {
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
    } on Exception catch (e, st) {
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
final mutationControllerProvider =
    Provider.family<MutationController<dynamic>, String>((ref, key) {
      final controller = MutationController<dynamic>();
      ref.onDispose(controller.dispose);
      return controller;
    });

/// Extension for using mutations with Ref.
extension MutationRefExtension on Ref {
  /// Creates or gets a mutation controller by key.
  MutationController<T> mutation<T>(String key) =>
      read(mutationControllerProvider(key)) as MutationController<T>;
}

/// Widget builder for MutationState.
///
/// **Feature: flutter-2025-final-enhancements**
/// **Validates: Requirements 1.5**
class MutationBuilder<T> extends StatelessWidget {
  const MutationBuilder({
    required this.state,
    required this.idle,
    required this.loading,
    required this.success,
    required this.error,
    super.key,
  });

  final MutationState<T> state;
  final Widget Function() idle;
  final Widget Function(double? progress) loading;
  final Widget Function(T data) success;
  final Widget Function(Object error, StackTrace stackTrace) error;

  @override
  Widget build(BuildContext context) =>
      state.when(idle: idle, loading: loading, success: success, error: error);
}

/// Simplified MutationBuilder with common defaults.
class SimpleMutationBuilder<T> extends StatelessWidget {
  const SimpleMutationBuilder({
    required this.state,
    required this.onIdle,
    required this.onSuccess,
    this.loadingWidget,
    this.errorBuilder,
    super.key,
  });

  final MutationState<T> state;
  final Widget Function() onIdle;
  final Widget Function(T data) onSuccess;
  final Widget? loadingWidget;
  final Widget Function(Object error)? errorBuilder;

  @override
  Widget build(BuildContext context) => state.when(
    idle: onIdle,
    loading: (_) =>
        loadingWidget ?? const Center(child: _DefaultLoadingIndicator()),
    success: onSuccess,
    error: (e, _) => errorBuilder?.call(e) ?? Text('Error: $e'),
  );
}

/// Default loading indicator for mutation builders.
class _DefaultLoadingIndicator extends StatelessWidget {
  const _DefaultLoadingIndicator();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 24,
    height: 24,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(width: 2, color: Color(0xFF6750A4)),
        ),
      ),
    ),
  );
}
