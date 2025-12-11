import 'package:flutter_base_2025/core/errors/failures.dart';

/// App-wide retry logic for Riverpod 3.0 automatic retry.
/// 
/// **Feature: flutter-2025-final-enhancements, Property 4: Retry Exponential Backoff**
/// **Validates: Requirements 3.1, 3.2**
Duration? appRetryLogic(int retryCount, Object error) {
  // Don't retry on validation errors
  if (error is ValidationFailure) return null;
  
  // Don't retry on auth errors
  if (error is AuthFailure) return null;
  
  // Don't retry on forbidden errors
  if (error is ForbiddenFailure) return null;
  
  // Don't retry on not found errors
  if (error is NotFoundFailure) return null;
  
  // Max 5 retries
  if (retryCount >= 5) return null;
  
  // Exponential backoff: 200ms, 400ms, 800ms, 1600ms, 3200ms
  return Duration(milliseconds: 200 * (1 << retryCount));
}

/// Calculates exponential backoff delay.
/// 
/// **Feature: flutter-2025-final-enhancements, Property 4: Retry Exponential Backoff**
/// **Validates: Requirements 3.1**
Duration calculateExponentialBackoff({
  required int retryCount,
  Duration baseDelay = const Duration(milliseconds: 200),
  Duration maxDelay = const Duration(seconds: 30),
}) {
  final delayMs = baseDelay.inMilliseconds * (1 << retryCount);
  final cappedMs = delayMs.clamp(0, maxDelay.inMilliseconds);
  return Duration(milliseconds: cappedMs);
}

/// Configuration for retry behavior.
class RetryConfig {
  const RetryConfig({
    this.maxRetries = 5,
    this.baseDelay = const Duration(milliseconds: 200),
    this.maxDelay = const Duration(seconds: 30),
  });

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  /// Checks if an error should be retried using pattern matching.
  /// More reliable than runtimeType comparison in production.
  bool shouldRetry(Object error) => switch (error) {
    NetworkFailure() => true,
    ServerFailure() => true,
    TimeoutFailure() => true,
    _ => false,
  };
}
