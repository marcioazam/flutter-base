import 'dart:async';

import 'package:dio/dio.dart';

import 'package:flutter_base_2025/core/constants/app_constants.dart';

/// Interceptor for retrying failed requests.
class RetryInterceptor extends Interceptor {

  RetryInterceptor({
    required this.dio,
    this.maxRetries = AppConstants.maxRetryAttempts,
    this.retryDelay = AppConstants.retryDelay,
  });
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final dynamic rawRetryCount = err.requestOptions.extra['retryCount'];
      final retryCount = rawRetryCount is int ? rawRetryCount : 0;

      if (retryCount < maxRetries) {
        await Future<void>.delayed(retryDelay * (retryCount + 1));

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

  bool _shouldRetry(DioException err) {
    // Retry on connection errors and timeouts
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        true,
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
