import 'package:dio/dio.dart';

import '../errors/failures.dart';
import '../utils/result.dart';

/// Handles network errors and converts them to typed failures.
class NetworkErrorHandler {
  /// Converts DioException to AppFailure.
  static AppFailure handleDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        NetworkFailure(
          'Connection timeout',
          code: 'TIMEOUT',
          stackTrace: e.stackTrace,
          context: {'url': e.requestOptions.uri.toString()},
        ),
      DioExceptionType.connectionError => NetworkFailure(
          'No internet connection',
          code: 'NO_CONNECTION',
          stackTrace: e.stackTrace,
        ),
      DioExceptionType.badResponse => _handleStatusCode(e),
      DioExceptionType.cancel => NetworkFailure(
          'Request cancelled',
          code: 'CANCELLED',
          stackTrace: e.stackTrace,
        ),
      _ => NetworkFailure(
          e.message ?? 'Unknown network error',
          code: 'UNKNOWN',
          stackTrace: e.stackTrace,
        ),
    };
  }

  static AppFailure _handleStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    return switch (statusCode) {
      400 => _parseValidationError(data, e.stackTrace),
      401 => AuthFailure(
          'Unauthorized',
          code: 'UNAUTHORIZED',
          stackTrace: e.stackTrace,
        ),
      403 => ForbiddenFailure(
          'Access denied',
          code: 'FORBIDDEN',
          stackTrace: e.stackTrace,
        ),
      404 => NotFoundFailure(
          'Resource not found',
          code: 'NOT_FOUND',
          stackTrace: e.stackTrace,
        ),
      409 => ConflictFailure(
          'Conflict',
          code: 'CONFLICT',
          stackTrace: e.stackTrace,
        ),
      429 => RateLimitFailure(
          'Too many requests',
          code: 'RATE_LIMIT',
          stackTrace: e.stackTrace,
          retryAfter: _parseRetryAfter(e.response?.headers),
        ),
      >= 500 => ServerFailure(
          'Server error',
          statusCode: statusCode,
          code: 'SERVER_ERROR',
          stackTrace: e.stackTrace,
        ),
      _ => NetworkFailure(
          'HTTP error $statusCode',
          code: 'HTTP_$statusCode',
          stackTrace: e.stackTrace,
        ),
    };
  }

  static AppFailure _parseValidationError(dynamic data, StackTrace? stack) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final fieldErrors = <String, List<String>>{};
        errors.forEach((key, value) {
          if (value is List) {
            fieldErrors[key] = value.map((e) => e.toString()).toList();
          } else if (value is String) {
            fieldErrors[key] = [value];
          }
        });
        return ValidationFailure(
          data['message'] ?? 'Validation failed',
          fieldErrors: fieldErrors,
          code: 'VALIDATION_ERROR',
          stackTrace: stack,
        );
      }
    }
    return ValidationFailure(
      'Invalid request',
      code: 'BAD_REQUEST',
      stackTrace: stack,
    );
  }

  static Duration? _parseRetryAfter(Headers? headers) {
    final retryAfter = headers?.value('retry-after');
    if (retryAfter != null) {
      final seconds = int.tryParse(retryAfter);
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }
    return null;
  }

  /// Wraps an async operation and handles errors.
  static Future<Result<T>> safeCall<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Success(result);
    } on DioException catch (e) {
      return Failure(handleDioException(e));
    } catch (e, stack) {
      return Failure(UnexpectedFailure(
        e.toString(),
        code: 'UNEXPECTED',
        stackTrace: stack,
      ));
    }
  }
}
