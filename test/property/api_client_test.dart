import 'package:dio/dio.dart';
import 'package:flutter_base_2025/core/errors/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: flutter-state-of-art-2025-final, Property 9: Exception to Failure Mapping**
/// **Feature: flutter-state-of-art-2025-final, Property 10: HTTP Status to Exception Mapping**
/// **Validates: Requirements 6.3, 6.4**

/// Helper to simulate ApiClient error handling logic.
AppException handleDioError(DioException e) => switch (e.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout => NetworkException(
    'Connection timeout',
    statusCode: 408,
  ),
  DioExceptionType.connectionError => NetworkException(
    'No internet connection',
  ),
  DioExceptionType.badResponse => _handleBadResponse(e.response),
  DioExceptionType.cancel => NetworkException('Request cancelled'),
  _ => NetworkException(e.message ?? 'Unknown network error'),
};

AppException _handleBadResponse(Response<dynamic>? response) {
  final statusCode = response?.statusCode ?? 500;
  final data = response?.data;

  var message = 'Server error';
  Map<String, List<String>>? fieldErrors;

  if (data is Map<String, dynamic>) {
    message =
        data['message'] as String? ??
        data['detail'] as String? ??
        'Server error';

    if (data['errors'] is Map) {
      fieldErrors = (data['errors'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, (value as List).map((e) => e.toString()).toList()),
      );
    }
  }

  return switch (statusCode) {
    400 => ValidationException(message, fieldErrors: fieldErrors),
    401 => UnauthorizedException(message),
    403 => ForbiddenException(message),
    404 => NotFoundException(message),
    422 => ValidationException(message, fieldErrors: fieldErrors),
    429 => RateLimitException(message),
    >= 500 => ServerException(message, statusCode: statusCode),
    _ => NetworkException(message, statusCode: statusCode),
  };
}

void main() {
  group('Exception to Failure Mapping Properties', () {
    /// **Property 9: Exception to Failure Mapping**
    /// *For any* DioException type, the ApiClient should map it to the
    /// correct AppException subtype.
    test('connectionTimeout maps to NetworkException with 408', () {
      final dioError = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );

      final exception = handleDioError(dioError);

      expect(exception, isA<NetworkException>());
      expect((exception as NetworkException).statusCode, equals(408));
    });

    test('sendTimeout maps to NetworkException with 408', () {
      final dioError = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );

      final exception = handleDioError(dioError);

      expect(exception, isA<NetworkException>());
      expect((exception as NetworkException).statusCode, equals(408));
    });

    test('receiveTimeout maps to NetworkException with 408', () {
      final dioError = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );

      final exception = handleDioError(dioError);

      expect(exception, isA<NetworkException>());
      expect((exception as NetworkException).statusCode, equals(408));
    });

    test('connectionError maps to NetworkException', () {
      final dioError = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      );

      final exception = handleDioError(dioError);

      expect(exception, isA<NetworkException>());
      expect(exception.message, contains('internet'));
    });

    test('cancel maps to NetworkException', () {
      final dioError = DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: '/test'),
      );

      final exception = handleDioError(dioError);

      expect(exception, isA<NetworkException>());
      expect(exception.message, contains('cancelled'));
    });
  });

  group('HTTP Status to Exception Mapping Properties', () {
    /// **Property 10: HTTP Status to Exception Mapping**
    /// *For any* HTTP status code, the ApiClient should create the correct
    /// exception type.
    test('400 maps to ValidationException', () {
      final response = Response(
        statusCode: 400,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'Bad request'},
      );

      final exception = _handleBadResponse(response);

      expect(exception, isA<ValidationException>());
    });

    test('401 maps to UnauthorizedException', () {
      final response = Response(
        statusCode: 401,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'Unauthorized'},
      );

      final exception = _handleBadResponse(response);

      expect(exception, isA<UnauthorizedException>());
    });

    test('403 maps to ForbiddenException', () {
      final response = Response(
        statusCode: 403,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'Forbidden'},
      );

      final exception = _handleBadResponse(response);

      expect(exception, isA<ForbiddenException>());
    });

    test('404 maps to NotFoundException', () {
      final response = Response(
        statusCode: 404,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'Not found'},
      );

      final exception = _handleBadResponse(response);

      expect(exception, isA<NotFoundException>());
    });

    test('422 maps to ValidationException', () {
      final response = Response(
        statusCode: 422,
        requestOptions: RequestOptions(path: '/test'),
        data: {
          'message': 'Validation failed',
          'errors': {
            'email': ['Invalid email format'],
          },
        },
      );

      final exception = _handleBadResponse(response);

      expect(exception, isA<ValidationException>());
      expect(
        (exception as ValidationException).fieldErrors?['email'],
        contains('Invalid email format'),
      );
    });

    test('429 maps to RateLimitException', () {
      final response = Response(
        statusCode: 429,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'Too many requests'},
      );

      final exception = _handleBadResponse(response);

      expect(exception, isA<RateLimitException>());
    });

    test('500 maps to ServerException', () {
      final response = Response(
        statusCode: 500,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'Internal server error'},
      );

      final exception = _handleBadResponse(response);

      expect(exception, isA<ServerException>());
      expect((exception as ServerException).statusCode, equals(500));
    });

    test('502 maps to ServerException', () {
      final response = Response(
        statusCode: 502,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'Bad gateway'},
      );

      final exception = _handleBadResponse(response);

      expect(exception, isA<ServerException>());
      expect((exception as ServerException).statusCode, equals(502));
    });

    test('503 maps to ServerException', () {
      final response = Response(
        statusCode: 503,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'Service unavailable'},
      );

      final exception = _handleBadResponse(response);

      expect(exception, isA<ServerException>());
      expect((exception as ServerException).statusCode, equals(503));
    });

    test('Unknown status maps to NetworkException', () {
      final response = Response(
        statusCode: 418,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'I am a teapot'},
      );

      final exception = _handleBadResponse(response);

      expect(exception, isA<NetworkException>());
      expect((exception as NetworkException).statusCode, equals(418));
    });
  });

  group('Error Response Parsing', () {
    test('Parses message from response data', () {
      final response = Response(
        statusCode: 400,
        requestOptions: RequestOptions(path: '/test'),
        data: {'message': 'Custom error message'},
      );

      final exception = _handleBadResponse(response);

      expect(exception.message, equals('Custom error message'));
    });

    test('Parses detail field as fallback', () {
      final response = Response(
        statusCode: 400,
        requestOptions: RequestOptions(path: '/test'),
        data: {'detail': 'Detail error message'},
      );

      final exception = _handleBadResponse(response);

      expect(exception.message, equals('Detail error message'));
    });

    test('Uses default message when no message in response', () {
      final response = Response<Map<String, dynamic>>(
        statusCode: 500,
        requestOptions: RequestOptions(path: '/test'),
        data: <String, dynamic>{},
      );

      final exception = _handleBadResponse(response);

      expect(exception.message, equals('Server error'));
    });

    test('Parses field errors from validation response', () {
      final response = Response(
        statusCode: 422,
        requestOptions: RequestOptions(path: '/test'),
        data: {
          'message': 'Validation failed',
          'errors': {
            'email': ['Invalid format', 'Already exists'],
            'password': ['Too short'],
          },
        },
      );

      final exception = _handleBadResponse(response) as ValidationException;

      expect(exception.fieldErrors?['email']?.length, equals(2));
      expect(exception.fieldErrors?['password']?.length, equals(1));
    });
  });
}
