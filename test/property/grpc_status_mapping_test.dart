import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown, setUpAll, tearDownAll;
import 'package:grpc/grpc.dart';

import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/grpc/grpc_status_mapper.dart';

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// Property tests for gRPC status code mapping.
///
/// **Feature: architecture-alignment-2025, Property 1: gRPC Status Code Mapping Consistency**
/// **Validates: Requirements 1.5**
void main() {
  group('GrpcStatusMapper Property Tests', () {
    // **Feature: architecture-alignment-2025, Property 1: gRPC Status Code Mapping Consistency**
    Glados<int>(any.int, _explore).test(
      'same status code always maps to same failure type',
      (code) {
        // Clamp to valid gRPC status code range (0-16)
        final validCode = code.abs() % 17;

        final failure1 = GrpcStatusMapper.fromStatusCode(validCode, 'test1');
        final failure2 = GrpcStatusMapper.fromStatusCode(validCode, 'test2');

        // Same code should always produce same failure type
        expect(failure1.runtimeType, failure2.runtimeType);
      },
    );

    // **Feature: architecture-alignment-2025, Property 1: gRPC Status Code Mapping Consistency**
    Glados<int>(any.int, _explore).test(
      'all status codes produce valid AppFailure subtype',
      (code) {
        final failure = GrpcStatusMapper.fromStatusCode(code, 'test message');

        // Must be a valid AppFailure subtype
        expect(failure, isA<AppFailure>());
        expect(failure.message, isNotEmpty);
        expect(failure.code, isNotNull);
      },
    );

    // **Feature: architecture-alignment-2025, Property 1: gRPC Status Code Mapping Consistency**
    Glados2<int, String>(any.int, any.nonEmptyLetters, _explore).test(
      'message is preserved in failure',
      (code, message) {
        final failure = GrpcStatusMapper.fromStatusCode(code, message);

        // Message should contain the original message
        expect(failure.message, contains(message));
      },
    );
  });

  group('GrpcStatusMapper Unit Tests', () {
    test('NOT_FOUND maps to NotFoundFailure', () {
      final failure = GrpcStatusMapper.fromStatusCode(
        StatusCode.notFound,
        'Resource not found',
      );
      expect(failure, isA<NotFoundFailure>());
      expect(failure.code, 'GRPC_NOT_FOUND');
    });

    test('UNAUTHENTICATED maps to UnauthorizedFailure', () {
      final failure = GrpcStatusMapper.fromStatusCode(
        StatusCode.unauthenticated,
        'Not authenticated',
      );
      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.code, 'GRPC_UNAUTHENTICATED');
    });

    test('PERMISSION_DENIED maps to ForbiddenFailure', () {
      final failure = GrpcStatusMapper.fromStatusCode(
        StatusCode.permissionDenied,
        'Permission denied',
      );
      expect(failure, isA<ForbiddenFailure>());
      expect(failure.code, 'GRPC_PERMISSION_DENIED');
    });

    test('UNAVAILABLE maps to NetworkFailure', () {
      final failure = GrpcStatusMapper.fromStatusCode(
        StatusCode.unavailable,
        'Service unavailable',
      );
      expect(failure, isA<NetworkFailure>());
      expect(failure.code, 'GRPC_UNAVAILABLE');
    });

    test('DEADLINE_EXCEEDED maps to TimeoutFailure', () {
      final failure = GrpcStatusMapper.fromStatusCode(
        StatusCode.deadlineExceeded,
        'Timeout',
      );
      expect(failure, isA<TimeoutFailure>());
      expect(failure.code, 'GRPC_DEADLINE_EXCEEDED');
    });

    test('INTERNAL maps to ServerFailure', () {
      final failure = GrpcStatusMapper.fromStatusCode(
        StatusCode.internal,
        'Internal error',
      );
      expect(failure, isA<ServerFailure>());
      expect(failure.code, 'GRPC_INTERNAL');
    });

    test('INVALID_ARGUMENT maps to ValidationFailure', () {
      final failure = GrpcStatusMapper.fromStatusCode(
        StatusCode.invalidArgument,
        'Invalid argument',
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure.code, 'GRPC_INVALID_ARGUMENT');
    });

    test('RESOURCE_EXHAUSTED maps to RateLimitFailure', () {
      final failure = GrpcStatusMapper.fromStatusCode(
        StatusCode.resourceExhausted,
        'Rate limited',
      );
      expect(failure, isA<RateLimitFailure>());
      expect(failure.code, 'GRPC_RESOURCE_EXHAUSTED');
    });

    test('ALREADY_EXISTS maps to ConflictFailure', () {
      final failure = GrpcStatusMapper.fromStatusCode(
        StatusCode.alreadyExists,
        'Already exists',
      );
      expect(failure, isA<ConflictFailure>());
      expect(failure.code, 'GRPC_ALREADY_EXISTS');
    });

    test('mapGrpcError converts GrpcError correctly', () {
      final grpcError = GrpcError.notFound('Test resource');
      final failure = GrpcStatusMapper.mapGrpcError(grpcError);

      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, contains('Test resource'));
    });
  });
}
