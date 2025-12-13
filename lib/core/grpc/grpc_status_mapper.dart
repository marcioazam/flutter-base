import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:grpc/grpc.dart';

/// Maps gRPC status codes to AppFailure types.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 1.5, 4.3**
///
/// gRPC Status Code Reference:
/// - OK (0): Success
/// - CANCELLED (1): Operation cancelled
/// - UNKNOWN (2): Unknown error
/// - INVALID_ARGUMENT (3): Invalid request
/// - DEADLINE_EXCEEDED (4): Timeout
/// - NOT_FOUND (5): Resource not found
/// - ALREADY_EXISTS (6): Resource already exists
/// - PERMISSION_DENIED (7): No permission
/// - RESOURCE_EXHAUSTED (8): Rate limited
/// - FAILED_PRECONDITION (9): Precondition failed
/// - ABORTED (10): Operation aborted
/// - OUT_OF_RANGE (11): Out of range
/// - UNIMPLEMENTED (12): Not implemented
/// - INTERNAL (13): Internal error
/// - UNAVAILABLE (14): Service unavailable
/// - DATA_LOSS (15): Data loss
/// - UNAUTHENTICATED (16): Not authenticated
class GrpcStatusMapper {
  GrpcStatusMapper._();

  /// Convert GrpcError to appropriate AppFailure
  static AppFailure mapGrpcError(GrpcError error) => fromStatusCode(
        error.code,
        error.message ?? 'Unknown gRPC error',
        details: error.details,
      );

  /// Convert status code to failure type
  ///
  /// Property 1: Same status code always maps to same failure type
  static AppFailure fromStatusCode(
    int code,
    String message, {
    List<dynamic>? details,
    StackTrace? stackTrace,
  }) {
    final context = details != null ? {'details': details} : null;

    return switch (code) {
      // Success - should not be called, but handle gracefully
      StatusCode.ok => UnexpectedFailure(
          'Unexpected OK status treated as error: $message',
          code: 'GRPC_OK',
          stackTrace: stackTrace,
          context: context,
        ),

      // Cancelled
      StatusCode.cancelled => NetworkFailure(
          'Request cancelled: $message',
          code: 'GRPC_CANCELLED',
          stackTrace: stackTrace,
          context: context,
        ),

      // Unknown
      StatusCode.unknown => UnexpectedFailure(
          'Unknown error: $message',
          code: 'GRPC_UNKNOWN',
          stackTrace: stackTrace,
          context: context,
        ),

      // Invalid argument
      StatusCode.invalidArgument => ValidationFailure(
          'Invalid argument: $message',
          code: 'GRPC_INVALID_ARGUMENT',
          stackTrace: stackTrace,
          context: context,
        ),

      // Deadline exceeded (timeout)
      StatusCode.deadlineExceeded => TimeoutFailure(
          'Request timeout: $message',
          code: 'GRPC_DEADLINE_EXCEEDED',
          stackTrace: stackTrace,
          context: context,
        ),

      // Not found
      StatusCode.notFound => NotFoundFailure(
          'Resource not found: $message',
          code: 'GRPC_NOT_FOUND',
          stackTrace: stackTrace,
          context: context,
        ),

      // Already exists
      StatusCode.alreadyExists => ConflictFailure(
          'Resource already exists: $message',
          code: 'GRPC_ALREADY_EXISTS',
          stackTrace: stackTrace,
          context: context,
        ),

      // Permission denied
      StatusCode.permissionDenied => ForbiddenFailure(
          'Permission denied: $message',
          code: 'GRPC_PERMISSION_DENIED',
          stackTrace: stackTrace,
          context: context,
        ),

      // Resource exhausted (rate limit)
      StatusCode.resourceExhausted => RateLimitFailure(
          'Rate limit exceeded: $message',
          code: 'GRPC_RESOURCE_EXHAUSTED',
          stackTrace: stackTrace,
          context: context,
        ),

      // Failed precondition
      StatusCode.failedPrecondition => ValidationFailure(
          'Precondition failed: $message',
          code: 'GRPC_FAILED_PRECONDITION',
          stackTrace: stackTrace,
          context: context,
        ),

      // Aborted
      StatusCode.aborted => ConflictFailure(
          'Operation aborted: $message',
          code: 'GRPC_ABORTED',
          stackTrace: stackTrace,
          context: context,
        ),

      // Out of range
      StatusCode.outOfRange => ValidationFailure(
          'Out of range: $message',
          code: 'GRPC_OUT_OF_RANGE',
          stackTrace: stackTrace,
          context: context,
        ),

      // Unimplemented
      StatusCode.unimplemented => ServerFailure(
          'Not implemented: $message',
          code: 'GRPC_UNIMPLEMENTED',
          stackTrace: stackTrace,
          context: context,
        ),

      // Internal error
      StatusCode.internal => ServerFailure(
          'Internal server error: $message',
          code: 'GRPC_INTERNAL',
          stackTrace: stackTrace,
          context: context,
        ),

      // Unavailable
      StatusCode.unavailable => NetworkFailure(
          'Service unavailable: $message',
          code: 'GRPC_UNAVAILABLE',
          stackTrace: stackTrace,
          context: context,
        ),

      // Data loss
      StatusCode.dataLoss => ServerFailure(
          'Data loss: $message',
          code: 'GRPC_DATA_LOSS',
          stackTrace: stackTrace,
          context: context,
        ),

      // Unauthenticated
      StatusCode.unauthenticated => UnauthorizedFailure(
          'Not authenticated: $message',
          code: 'GRPC_UNAUTHENTICATED',
          stackTrace: stackTrace,
          context: context,
        ),

      // Default for unknown codes
      _ => UnexpectedFailure(
          'Unknown gRPC status code $code: $message',
          code: 'GRPC_UNKNOWN_CODE',
          stackTrace: stackTrace,
          context: context,
        ),
    };
  }

  /// Get failure type for a status code (for testing consistency)
  static Type getFailureType(int code) =>
      fromStatusCode(code, 'test').runtimeType;
}
