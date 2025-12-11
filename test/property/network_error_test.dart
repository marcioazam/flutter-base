import 'package:dio/dio.dart';
import 'package:flutter_base_2025/core/errors/exception_mapper.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExceptionMapper', () {
    test('connection timeout returns TimeoutFailure', () {
      final exception = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final failure = ExceptionMapper.mapException(exception);
      expect(failure, isA<TimeoutFailure>());
    });

    test('401 returns UnauthorizedFailure', () {
      final exception = DioException(
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 401, requestOptions: RequestOptions(path: '/test')),
        requestOptions: RequestOptions(path: '/test'),
      );
      final failure = ExceptionMapper.mapException(exception);
      expect(failure, isA<UnauthorizedFailure>());
    });

    test('500 returns ServerFailure', () {
      final exception = DioException(
        type: DioExceptionType.badResponse,
        response: Response(statusCode: 500, requestOptions: RequestOptions(path: '/test')),
        requestOptions: RequestOptions(path: '/test'),
      );
      final failure = ExceptionMapper.mapException(exception);
      expect(failure, isA<ServerFailure>());
    });

    test('all HTTP status codes produce typed failures', () {
      final statusCodes = [400, 401, 403, 404, 409, 429, 500, 502, 503];
      for (final statusCode in statusCodes) {
        final exception = DioException(
          type: DioExceptionType.badResponse,
          response: Response(statusCode: statusCode, requestOptions: RequestOptions(path: '/test')),
          requestOptions: RequestOptions(path: '/test'),
        );
        final failure = ExceptionMapper.mapException(exception);
        expect(failure, isA<AppFailure>());
      }
    });
  });
}
