import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_base_2025/core/errors/exceptions.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';

/// Maps exceptions to failures for consistent error handling.
/// 
/// **Feature: flutter-state-of-art-code-review-2025**
/// **Validates: Requirements 8.5, 44.3**
class ExceptionMapper {
  const ExceptionMapper._();

  /// Maps any exception to an AppFailure.
  static AppFailure mapException(Object error, [StackTrace? stackTrace]) => switch (error) {
      final DioException e => _mapDioException(e, stackTrace),
      final FormatException e => ValidationFailure(
          e.message,
          stackTrace: stackTrace,
        ),
      TimeoutException _ => TimeoutFailure(
          'Operation timed out',
          stackTrace: stackTrace,
        ),
      final AppException e => _mapAppException(e, stackTrace),
      final AppFailure f => f,
      _ => UnexpectedFailure(
          error.toString(),
          stackTrace: stackTrace,
        ),
    };

  /// Maps DioException to AppFailure.
  static AppFailure _mapDioException(
    DioException e, [
    StackTrace? stackTrace,
  ]) => switch (e.type) {
      DioExceptionType.connectionTimeout => TimeoutFailure(
          'Connection timeout',
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      DioExceptionType.sendTimeout => TimeoutFailure(
          'Send timeout',
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      DioExceptionType.receiveTimeout => TimeoutFailure(
          'Receive timeout',
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      DioExceptionType.badResponse => _mapStatusCode(
          e.response?.statusCode,
          e.response?.data,
          stackTrace ?? e.stackTrace,
        ),
      DioExceptionType.connectionError => NetworkFailure(
          'No internet connection',
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      DioExceptionType.cancel => NetworkFailure(
          'Request cancelled',
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      _ => NetworkFailure(
          e.message ?? 'Network error',
          stackTrace: stackTrace ?? e.stackTrace,
        ),
    };

  /// Maps HTTP status code to AppFailure.
  static AppFailure _mapStatusCode(
    int? statusCode, [
    dynamic data,
    StackTrace? stackTrace,
  ]) {
    final message = _extractMessage(data);
    final fieldErrors = _extractFieldErrors(data);

    return switch (statusCode) {
      400 => ValidationFailure(
          message ?? 'Bad request',
          fieldErrors: fieldErrors,
          stackTrace: stackTrace,
        ),
      401 => UnauthorizedFailure(
          message ?? 'Unauthorized',
          stackTrace: stackTrace,
        ),
      403 => ForbiddenFailure(
          message ?? 'Forbidden',
          stackTrace: stackTrace,
        ),
      404 => NotFoundFailure(
          message ?? 'Not found',
          stackTrace: stackTrace,
        ),
      409 => ConflictFailure(
          message ?? 'Conflict',
          stackTrace: stackTrace,
        ),
      422 => ValidationFailure(
          message ?? 'Validation error',
          fieldErrors: fieldErrors,
          stackTrace: stackTrace,
        ),
      429 => RateLimitFailure(
          message ?? 'Too many requests',
          retryAfter: _extractRetryAfter(data),
          stackTrace: stackTrace,
        ),
      final code when code != null && code >= 500 => ServerFailure(
          message ?? 'Server error',
          statusCode: code,
          stackTrace: stackTrace,
        ),
      _ => NetworkFailure(
          message ?? 'Request failed',
          stackTrace: stackTrace,
        ),
    };
  }

  /// Maps AppException to AppFailure.
  static AppFailure _mapAppException(
    AppException e, [
    StackTrace? stackTrace,
  ]) => switch (e) {
      NetworkException() => NetworkFailure(
          e.message,
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      ServerException() => ServerFailure(
          e.message,
          statusCode: e.statusCode,
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      ValidationException(:final fieldErrors) => ValidationFailure(
          e.message,
          fieldErrors: fieldErrors ?? {},
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      UnauthorizedException() => UnauthorizedFailure(
          e.message,
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      ForbiddenException() => ForbiddenFailure(
          e.message,
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      NotFoundException() => NotFoundFailure(
          e.message,
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      RateLimitException() => RateLimitFailure(
          e.message,
          stackTrace: stackTrace ?? e.stackTrace,
        ),
      CacheException() => CacheFailure(
          e.message,
          stackTrace: stackTrace ?? e.stackTrace,
        ),
    };

  /// Extracts message from response data.
  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['detail'] as String? ??
          data['error'] as String?;
    }
    return null;
  }

  /// Extracts field errors from response data.
  static Map<String, List<String>> _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return (data['errors'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => e.toString()).toList(),
        ),
      );
    }
    return {};
  }

  /// Extracts retry-after duration from response data.
  static Duration? _extractRetryAfter(dynamic data) {
    if (data is Map<String, dynamic>) {
      final retryAfter = data['retry_after'];
      if (retryAfter is int) {
        return Duration(seconds: retryAfter);
      }
      if (retryAfter is String) {
        final seconds = int.tryParse(retryAfter);
        if (seconds != null) {
          return Duration(seconds: seconds);
        }
      }
    }
    return null;
  }

  /// Parses retry-after header from HTTP response.
  /// 
  /// **Feature: flutter-state-of-art-code-review-2025, Property 10**
  /// **Validates: Requirements 38.1**
  static Duration? parseRetryAfterHeader(Map<String, dynamic>? headers) {
    if (headers == null) return null;

    final retryAfter = headers['retry-after'] ?? headers['Retry-After'];
    if (retryAfter == null) return null;

    final value = retryAfter is List ? retryAfter.first : retryAfter;
    if (value is int) {
      return Duration(seconds: value);
    }
    if (value is String) {
      final seconds = int.tryParse(value);
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }
    return null;
  }
}
