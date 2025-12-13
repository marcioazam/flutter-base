import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// Interceptor for retrying failed requests with exponential backoff and jitter.
///
/// **Feature: flutter-state-of-art-code-review-2025**
/// **Validates: Requirements 8.3, 21.2, 39.1**
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 5,
    this.baseDelay = const Duration(milliseconds: 200),
    this.maxDelay = const Duration(seconds: 30),
    this.jitterFactor = 0.5,
    Random? random,
  }) : _random = random ?? Random();

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;
  final double jitterFactor;
  final Random _random;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      final dynamic rawRetryCount = err.requestOptions.extra['retryCount'];
      final retryCount = rawRetryCount is int ? rawRetryCount : 0;

      if (retryCount < maxRetries) {
        final delay = calculateBackoffDelay(retryCount);
        await Future<void>.delayed(delay);

        try {
          final response = await _retry(err.requestOptions, retryCount + 1);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }
    handler.next(err);
  }

  /// Calculates exponential backoff delay with jitter.
  ///
  /// Formula: delay = min(baseDelay * 2^attempt * (1 ± jitter), maxDelay)
  ///
  /// **Feature: flutter-state-of-art-code-review-2025, Property 5**
  /// **Validates: Requirements 8.3, 21.2, 39.1**
  Duration calculateBackoffDelay(int attempt) {
    // Calculate base exponential delay
    final exponentialMs = baseDelay.inMilliseconds * pow(2, attempt);

    // Apply jitter: random value between (1 - jitterFactor) and (1 + jitterFactor)
    final jitterMultiplier =
        1.0 + ((_random.nextDouble() * 2 - 1) * jitterFactor);
    final delayMs = (exponentialMs * jitterMultiplier).round();

    // Cap at maxDelay
    final cappedMs = min(delayMs, maxDelay.inMilliseconds);

    return Duration(milliseconds: cappedMs);
  }

  bool _shouldRetry(DioException err) {
    // Default: retry on connection errors and timeouts
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => _isRetryableStatusCode(
        err.response?.statusCode,
      ),
      _ => false,
    };
  }

  bool _isRetryableStatusCode(int? statusCode) {
    // Retry on 5xx server errors and 429 rate limit
    if (statusCode == null) return false;
    return statusCode >= 500 || statusCode == 429;
  }

  Future<Response<dynamic>> _retry(
    RequestOptions requestOptions,
    int retryCount,
  ) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      extra: {...requestOptions.extra, 'retryCount': retryCount},
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
