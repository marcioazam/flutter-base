import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart';

import 'package:flutter_base_2025/core/errors/failures.dart';

/// **Feature: flutter-base-2025, Property 22: Validation Failure Detail**
/// **Validates: Requirements 13.5**
void main() {
  group('AppFailure Hierarchy', () {
    group('NetworkFailure', () {
      test('has correct userMessage', () {
        const failure = NetworkFailure('Connection timeout');
        expect(failure.userMessage, contains('conexão'));
      });

      test('preserves message and code', () {
        const failure = NetworkFailure(
          'Timeout',
          code: 'TIMEOUT',
          context: {'url': '/api/test'},
        );
        expect(failure.message, equals('Timeout'));
        expect(failure.code, equals('TIMEOUT'));
        expect(failure.context, isNotNull);
      });
    });

    group('ValidationFailure', () {
      test('has correct userMessage', () {
        const failure = ValidationFailure('Invalid input');
        expect(failure.userMessage, contains('formulário'));
      });

      test('stores field errors', () {
        const failure = ValidationFailure(
          'Validation failed',
          fieldErrors: {
            'email': ['Invalid email format', 'Email already exists'],
            'password': ['Too short'],
          },
        );

        expect(failure.fieldErrors.length, equals(2));
        expect(failure.errorsFor('email').length, equals(2));
        expect(failure.errorsFor('password').length, equals(1));
      });

      test('hasErrorFor returns correct value', () {
        const failure = ValidationFailure(
          'Validation failed',
          fieldErrors: {'email': ['Invalid']},
        );

        expect(failure.hasErrorFor('email'), isTrue);
        expect(failure.hasErrorFor('password'), isFalse);
      });

      test('firstErrorFor returns first error or null', () {
        const failure = ValidationFailure(
          'Validation failed',
          fieldErrors: {
            'email': ['First error', 'Second error'],
          },
        );

        expect(failure.firstErrorFor('email'), equals('First error'));
        expect(failure.firstErrorFor('password'), isNull);
      });

      test('errorsFor returns empty list for unknown field', () {
        const failure = ValidationFailure('Validation failed');
        expect(failure.errorsFor('unknown'), isEmpty);
      });
    });

    group('AuthFailure', () {
      test('has correct userMessage', () {
        const failure = AuthFailure('Token expired');
        expect(failure.userMessage, contains('login'));
      });
    });

    group('ServerFailure', () {
      test('has correct userMessage', () {
        const failure = ServerFailure('Internal error', statusCode: 500);
        expect(failure.userMessage, contains('servidor'));
        expect(failure.statusCode, equals(500));
      });
    });

    group('NotFoundFailure', () {
      test('stores resource info', () {
        const failure = NotFoundFailure(
          'User not found',
          resourceType: 'User',
          resourceId: '123',
        );
        expect(failure.resourceType, equals('User'));
        expect(failure.resourceId, equals('123'));
      });
    });

    group('RateLimitFailure', () {
      test('stores retry duration', () {
        const failure = RateLimitFailure(
          'Too many requests',
          retryAfter: Duration(seconds: 60),
        );
        expect(failure.retryAfter, equals(const Duration(seconds: 60)));
      });
    });

    group('Property Tests', () {
      /// **Property 22: Validation Failure Detail**
      /// For any validation failure, the ValidationFailure SHALL contain field-specific error messages.
      Glados2<String, String>(iterations: 100).test(
        'ValidationFailure preserves all field errors',
        (fieldName, errorMessage) {
          final failure = ValidationFailure(
            'Validation failed',
            fieldErrors: {fieldName: [errorMessage]},
          );

          expect(failure.hasErrorFor(fieldName), isTrue);
          expect(failure.errorsFor(fieldName), contains(errorMessage));
          expect(failure.firstErrorFor(fieldName), equals(errorMessage));
        },
      );

      Glados<List<String>>(iterations: 100).test(
        'ValidationFailure preserves multiple errors per field',
        (errors) {
          if (errors.isEmpty) return;

          final failure = ValidationFailure(
            'Validation failed',
            fieldErrors: {'testField': errors},
          );

          expect(failure.errorsFor('testField').length, equals(errors.length));
          expect(failure.errorsFor('testField'), equals(errors));
        },
      );

      Glados<String>(iterations: 100).test(
        'All failures preserve message',
        (message) {
          final failures = [
            NetworkFailure(message),
            CacheFailure(message),
            ValidationFailure(message),
            AuthFailure(message),
            ServerFailure(message),
            NotFoundFailure(message),
            ForbiddenFailure(message),
            ConflictFailure(message),
            RateLimitFailure(message),
            UnexpectedFailure(message),
          ];

          for (final failure in failures) {
            expect(failure.message, equals(message));
          }
        },
      );

      Glados<String>(iterations: 100).test(
        'All failures have non-empty userMessage',
        (message) {
          final failures = [
            NetworkFailure(message),
            CacheFailure(message),
            ValidationFailure(message),
            AuthFailure(message),
            ServerFailure(message),
            NotFoundFailure(message),
            ForbiddenFailure(message),
            ConflictFailure(message),
            RateLimitFailure(message),
            UnexpectedFailure(message),
          ];

          for (final failure in failures) {
            expect(failure.userMessage, isNotEmpty);
          }
        },
      );

      Glados2<String, String>(iterations: 100).test(
        'Failures with same message and code are equal',
        (message, code) {
          final failure1 = NetworkFailure(message, code: code);
          final failure2 = NetworkFailure(message, code: code);

          expect(failure1, equals(failure2));
          expect(failure1.hashCode, equals(failure2.hashCode));
        },
      );
    });
  });
}
