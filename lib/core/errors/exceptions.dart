/// Base exception for all app exceptions.
sealed class AppException implements Exception {
  final String message;
  final int? statusCode;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.statusCode, this.stackTrace});

  @override
  String toString() => '$runtimeType: $message';
}

/// Network-related exceptions.
final class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode, super.stackTrace});
}

/// Server error exceptions (5xx).
final class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.stackTrace});
}

/// Validation error exceptions (400, 422).
final class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.statusCode = 422,
    super.stackTrace,
  });
}

/// Unauthorized exceptions (401).
final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized'])
      : super(statusCode: 401);
}

/// Forbidden exceptions (403).
final class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Forbidden'])
      : super(statusCode: 403);
}

/// Not found exceptions (404).
final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found'])
      : super(statusCode: 404);
}

/// Rate limit exceptions (429).
final class RateLimitException extends AppException {
  const RateLimitException([super.message = 'Too many requests'])
      : super(statusCode: 429);
}

/// Cache-related exceptions.
final class CacheException extends AppException {
  const CacheException(super.message, {super.stackTrace});
}
