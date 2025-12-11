import 'package:dio/dio.dart';
import 'package:flutter_base_2025/core/errors/exception_mapper.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: flutter-base-2025, Property 9: Network Error Typing**
/// **Validates: Requirements 4.3**
void main() {
  group('ExceptionMapper', () {
    group('mapException with DioException', () {
      test('connection timeout returns TimeoutFailure', () {
        final exception = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<TimeoutFailure>());
      });

      test('send timeout returns TimeoutFailure', () {
        final exception = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<TimeoutFailure>());
      });

      test('receive timeout returns TimeoutFailure', () {
        final exception = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<TimeoutFailure>());
      });

      test('connection error returns NetworkFailure', () {
        final exception = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<NetworkFailure>());
      });

      test('cancel returns NetworkFailure', () {
        final exception = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<NetworkFailure>());
      });

      test('401 returns UnauthorizedFailure', () {
        final exception = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<UnauthorizedFailure>());
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
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<ForbiddenFailure>());
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
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<NotFoundFailure>());
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
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<ConflictFailure>());
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
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<RateLimitFailure>());
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
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<ServerFailure>());
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
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<ValidationFailure>());
        final validationFailure = failure as ValidationFailure;
        expect(validationFailure.fieldErrors['email'], contains('Invalid email'));
        expect(validationFailure.fieldErrors['password'], contains('Too short'));
      });
    });

    group('Property Tests', () {
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
          final failure = ExceptionMapper.mapException(exception);
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
          final failure = ExceptionMapper.mapException(exception);
          expect(failure, isA<AppFailure>());
          expect(failure.message, isNotEmpty);
        }
      });
    });
  });
}
