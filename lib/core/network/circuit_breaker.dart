import 'dart:async';

import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

export 'package:flutter_base_2025/core/errors/failures.dart' show CircuitOpenFailure;

/// Circuit breaker states for the state machine.
/// 
/// **Feature: flutter-2025-final-enhancements**
/// **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**
enum CircuitState {
  /// Circuit is closed - requests flow normally.
  closed,
  
  /// Circuit is open - requests fail fast without execution.
  open,
  
  /// Circuit is half-open - allowing test requests to check recovery.
  halfOpen,
}

/// Configuration for circuit breaker behavior.
class CircuitBreakerConfig {
  const CircuitBreakerConfig({
    this.failureThreshold = 5,
    this.successThreshold = 2,
    this.timeout = const Duration(seconds: 30),
  });

  /// Number of consecutive failures before opening circuit.
  final int failureThreshold;

  /// Number of consecutive successes in half-open state to close circuit.
  final int successThreshold;

  /// Duration to wait before transitioning from open to half-open.
  final Duration timeout;
}

/// Generic circuit breaker implementation for resilient operations.
/// 
/// Implements the circuit breaker pattern to prevent cascading failures
/// by failing fast when a service is unavailable.
/// 
/// **Feature: flutter-2025-final-enhancements, Property 6: Circuit Breaker State Machine**
/// **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**
class CircuitBreaker<T> {
  CircuitBreaker({
    required this.config,
    required this.execute,
    this.onStateChange,
  });

  final CircuitBreakerConfig config;
  final Future<T> Function() execute;
  final void Function(CircuitState oldState, CircuitState newState)? onStateChange;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  int _successCount = 0;
  DateTime? _lastFailureTime;

  /// Current state of the circuit breaker.
  CircuitState get state => _state;

  /// Number of consecutive failures.
  int get failureCount => _failureCount;

  /// Number of consecutive successes in half-open state.
  int get successCount => _successCount;

  /// Executes the operation with circuit breaker protection.
  Future<Result<T>> call() async {
    switch (_state) {
      case CircuitState.open:
        if (_shouldAttemptReset()) {
          _transitionTo(CircuitState.halfOpen);
          return _executeWithTracking();
        }
        return const Failure(CircuitOpenFailure('Circuit is open - failing fast'));

      case CircuitState.halfOpen:
      case CircuitState.closed:
        return _executeWithTracking();
    }
  }

  /// Checks if enough time has passed to attempt reset.
  bool _shouldAttemptReset() {
    if (_lastFailureTime == null) return true;
    return DateTime.now().difference(_lastFailureTime!) >= config.timeout;
  }

  /// Executes the operation and tracks success/failure.
  Future<Result<T>> _executeWithTracking() async {
    try {
      final result = await execute();
      _onSuccess();
      return Success(result);
    } catch (e, st) {
      _onFailure();
      return Failure(UnexpectedFailure(e.toString(), stackTrace: st));
    }
  }

  /// Handles successful execution.
  void _onSuccess() {
    _failureCount = 0;
    if (_state == CircuitState.halfOpen) {
      _successCount++;
      if (_successCount >= config.successThreshold) {
        _transitionTo(CircuitState.closed);
        _successCount = 0;
      }
    }
  }

  /// Handles failed execution.
  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    _successCount = 0;

    if (_state == CircuitState.halfOpen) {
      _transitionTo(CircuitState.open);
    } else if (_failureCount >= config.failureThreshold) {
      _transitionTo(CircuitState.open);
    }
  }

  /// Transitions to a new state.
  void _transitionTo(CircuitState newState) {
    if (_state != newState) {
      final oldState = _state;
      _state = newState;
      onStateChange?.call(oldState, newState);
    }
  }

  /// Resets the circuit breaker to closed state.
  void reset() {
    _transitionTo(CircuitState.closed);
    _failureCount = 0;
    _successCount = 0;
    _lastFailureTime = null;
  }

  /// Forces the circuit to open state (for testing).
  void forceOpen() {
    _transitionTo(CircuitState.open);
    _lastFailureTime = DateTime.now();
  }
}

// CircuitOpenFailure is defined in lib/core/errors/failures.dart
