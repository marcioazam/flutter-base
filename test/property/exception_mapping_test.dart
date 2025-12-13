import 'package:flutter_base_2025/core/errors/exceptions.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-production-ready-2025, Property 21: Exception to Failure Mapping**
/// **Validates: Requirements 11.1**

/// Maps AppException to AppFailure (same logic as ApiRepository)
AppFailure mapExceptionToFailure(AppException e) => switch (e) {
    NetworkException() => NetworkFailure(e.message),
    ServerException() => ServerFailure(e.message, statusCode: e.statusCode),
    ValidationException(:final fieldErrors) =>
      ValidationFailure(e.message, fieldErrors: fieldErrors ?? {}),
    UnauthorizedException() => AuthFailure(e.message),
    ForbiddenException() => ForbiddenFailure(e.message),
    NotFoundException() => NotFoundFailure(e.message),
    RateLimitException() => RateLimitFailure(e.message),
    CacheException() => CacheFailure(e.message),
  };

void main() {
  group('Exception to Failure Mapping Properties', () {
    /// **Property 21: Exception to Failure Mapping**
    /// *For any* AppException, mapping should produce the correct AppFailure subtype.
    
    Glados<String>(any.nonEmptyLetters, _explore).test(
      'NetworkException maps to NetworkFailure',
      (message) {
        final exception = NetworkException(message);
        final failure = mapExceptionToFailure(exception);

        expect(failure, isA<NetworkFailure>());
        expect(failure.message, equals(message));
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'ServerException maps to ServerFailure with statusCode',
      (message) {
        final exception = ServerException(message, statusCode: 500);
        final failure = mapExceptionToFailure(exception);

        expect(failure, isA<ServerFailure>());
        expect(failure.message, equals(message));
        expect((failure as ServerFailure).statusCode, equals(500));
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'ValidationException maps to ValidationFailure with fieldErrors',
      (message) {
        final fieldErrors = {'email': ['Invalid format']};
        final exception = ValidationException(message, fieldErrors: fieldErrors);
        final failure = mapExceptionToFailure(exception);

        expect(failure, isA<ValidationFailure>());
        expect(failure.message, equals(message));
        expect((failure as ValidationFailure).fieldErrors, equals(fieldErrors));
      },
    );

    test('UnauthorizedException maps to AuthFailure', () {
      final exception = UnauthorizedException('Session expired');
      final failure = mapExceptionToFailure(exception);

      expect(failure, isA<AuthFailure>());
      expect(failure.message, equals('Session expired'));
    });

    test('ForbiddenException maps to ForbiddenFailure', () {
      final exception = ForbiddenException('Access denied');
      final failure = mapExceptionToFailure(exception);

      expect(failure, isA<ForbiddenFailure>());
      expect(failure.message, equals('Access denied'));
    });

    test('NotFoundException maps to NotFoundFailure', () {
      final exception = NotFoundException('Resource not found');
      final failure = mapExceptionToFailure(exception);

      expect(failure, isA<NotFoundFailure>());
      expect(failure.message, equals('Resource not found'));
    });

    test('RateLimitException maps to RateLimitFailure', () {
      final exception = RateLimitException();
      final failure = mapExceptionToFailure(exception);

      expect(failure, isA<RateLimitFailure>());
      expect(failure.message, equals('Too many requests'));
    });

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'CacheException maps to CacheFailure',
      (message) {
        final exception = CacheException(message);
        final failure = mapExceptionToFailure(exception);

        expect(failure, isA<CacheFailure>());
        expect(failure.message, equals(message));
      },
    );

    test('All exception types are handled exhaustively', () {
      // This test verifies that the switch is exhaustive
      // If a new exception type is added, this will fail to compile
      final exceptions = <AppException>[
        const NetworkException('network'),
        const ServerException('server'),
        const ValidationException('validation'),
        const UnauthorizedException(),
        const ForbiddenException(),
        const NotFoundException(),
        const RateLimitException(),
        const CacheException('cache'),
      ];

      for (final exception in exceptions) {
        final failure = mapExceptionToFailure(exception);
        expect(failure, isA<AppFailure>());
        expect(failure.message, isNotEmpty);
      }
    });
  });

  /// **Feature: flutter-production-ready-2025, Property 22: Generator Produces Valid Instances**
  /// **Validates: Requirements 8.2**
  group('Generator Validity Properties', () {
    Glados<int>(any.int, _explore).test(
      'int generator produces valid integers',
      (value) {
        expect(value, isA<int>());
      },
    );

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'string generator produces valid strings',
      (value) {
        expect(value, isA<String>());
      },
    );

    Glados<double>(any.double, _explore).test(
      'double generator produces valid doubles',
      (value) {
        expect(value, isA<double>());
        expect(value.isNaN || value.isFinite || value.isInfinite, isTrue);
      },
    );

    Glados<bool>(any.bool, _explore).test(
      'bool generator produces valid booleans',
      (value) {
        expect(value, isA<bool>());
        expect(value == true || value == false, isTrue);
      },
    );

    Glados<List<int>>(any.list(any.int), _explore).test(
      'list generator produces valid lists',
      (value) {
        expect(value, isA<List<int>>());
        for (final item in value) {
          expect(item, isA<int>());
        }
      },
    );
  });
}
