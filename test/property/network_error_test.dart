import 'package:dio/dio.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/network/network_error_handler.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: flutter-base-2025, Property 9: Network Error Typing**
/// **Validates: Requirements 4.3**
void main() {
  group('NetworkErrorHandler', () {
    group('handleDioException', () {
      test('connection timeout returns NetworkFailure', () {
        final exception = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<NetworkFailure>());
        expect(failure.code, equals('TIMEOUT'));
      });

      test('send timeout returns NetworkFailure', () {
        final exception = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<NetworkFailure>());
        expect(failure.code, equals('TIMEOUT'));
      });

      test('receive timeout returns NetworkFailure', () {
        final exception = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<NetworkFailure>());
        expect(failure.code, equals('TIMEOUT'));
      });

      test('connection error returns NetworkFailure', () {
        final exception = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<NetworkFailure>());
        expect(failure.code, equals('NO_CONNECTION'));
      });

      test('cancel returns NetworkFailure', () {
        final exception = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<NetworkFailure>());
        expect(failure.code, equals('CANCELLED'));
      });

      test('401 returns AuthFailure', () {
        final exception = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<AuthFailure>());
        expect(failure.code, equals('UNAUTHORIZED'));
      });

      test('403 returns ForbiddenFailure', () {
        final exception = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 403,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<ForbiddenFailure>());
        expect(failure.code, equals('FORBIDDEN'));
      });

      test('404 returns NotFoundFailure', () {
        final exception = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<NotFoundFailure>());
        expect(failure.code, equals('NOT_FOUND'));
      });

      test('409 returns ConflictFailure', () {
        final exception = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 409,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<ConflictFailure>());
        expect(failure.code, equals('CONFLICT'));
      });

      test('429 returns RateLimitFailure', () {
        final exception = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 429,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<RateLimitFailure>());
        expect(failure.code, equals('RATE_LIMIT'));
      });

      test('500 returns ServerFailure', () {
        final exception = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<ServerFailure>());
        expect(failure.code, equals('SERVER_ERROR'));
      });

      test('400 with validation errors returns ValidationFailure', () {
        final exception = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'message': 'Validation failed',
              'errors': {
                'email': ['Invalid email'],
                'password': ['Too short'],
              },
            },
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final failure = NetworkErrorHandler.handleDioException(exception);

        expect(failure, isA<ValidationFailure>());
        final validationFailure = failure as ValidationFailure;
        expect(validationFailure.fieldErrors['email'], contains('Invalid email'));
        expect(validationFailure.fieldErrors['password'], contains('Too short'));
      });
    });

    group('Property Tests', () {
      /// **Property 9: Network Error Typing**
      /// For any network error, the repository SHALL return a typed Failure with appropriate error details.
      test('all DioExceptionTypes produce typed failures', () {
        final types = [
          DioExceptionType.connectionTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.connectionError,
          DioExceptionType.cancel,
          DioExceptionType.unknown,
        ];

        for (final type in types) {
          final exception = DioException(
            type: type,
            requestOptions: RequestOptions(path: '/test'),
          );

          final failure = NetworkErrorHandler.handleDioException(exception);

          expect(failure, isA<AppFailure>());
          expect(failure.message, isNotEmpty);
        }
      });

      test('all HTTP status codes produce typed failures', () {
        final statusCodes = [400, 401, 403, 404, 409, 429, 500, 502, 503];

        for (final statusCode in statusCodes) {
          final exception = DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: statusCode,
              requestOptions: RequestOptions(path: '/test'),
            ),
            requestOptions: RequestOptions(path: '/test'),
          );

          final failure = NetworkErrorHandler.handleDioException(exception);

          expect(failure, isA<AppFailure>());
          expect(failure.message, isNotEmpty);
          expect(failure.code, isNotNull);
        }
      });
    });
  });
}
