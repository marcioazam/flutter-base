import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/integrations/ai/ai_service.dart';

/// **Feature: flutter-2025-final-polish, Property 5: AI Error Mapping**
/// **Validates: Requirements 10.4**
void main() {
  group('AI Error Mapping Properties', () {
    test('invalidApiKey maps to AuthFailure', () {
      final failure = mapAIError(AIErrorType.invalidApiKey);

      expect(failure, isA<AuthFailure>());
      expect(failure.code, equals('AI_INVALID_KEY'));
    });

    test('quotaExceeded maps to RateLimitFailure', () {
      final failure = mapAIError(AIErrorType.quotaExceeded);

      expect(failure, isA<RateLimitFailure>());
      expect(failure.code, equals('AI_QUOTA_EXCEEDED'));
    });

    test('contentBlocked maps to ValidationFailure', () {
      final failure = mapAIError(AIErrorType.contentBlocked);

      expect(failure, isA<ValidationFailure>());
      expect(failure.code, equals('AI_CONTENT_BLOCKED'));
    });

    test('networkError maps to NetworkFailure', () {
      final failure = mapAIError(AIErrorType.networkError);

      expect(failure, isA<NetworkFailure>());
      expect(failure.code, equals('AI_NETWORK_ERROR'));
    });

    test('parseError maps to ValidationFailure', () {
      final failure = mapAIError(AIErrorType.parseError);

      expect(failure, isA<ValidationFailure>());
      expect(failure.code, equals('AI_PARSE_ERROR'));
    });

    test('unknown maps to UnexpectedFailure', () {
      final failure = mapAIError(AIErrorType.unknown);

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.code, equals('AI_UNKNOWN_ERROR'));
    });

    test('custom message is preserved', () {
      const customMessage = 'Custom error message';
      final failure = mapAIError(AIErrorType.networkError, customMessage);

      expect(failure.message, equals(customMessage));
    });

    test('all AIErrorType values have mappings', () {
      for (final errorType in AIErrorType.values) {
        final failure = mapAIError(errorType);
        expect(failure, isA<AppFailure>());
        expect(failure.code, isNotNull);
      }
    });
  });

  group('MockAIService', () {
    late MockAIService service;

    setUp(() {
      service = MockAIService();
    });

    test('generateText returns Success with mock response', () async {
      final result = await service.generateText('test prompt');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, contains('test prompt'));
    });

    test('isAvailable returns true', () async {
      final available = await service.isAvailable();

      expect(available, isTrue);
    });

    test('generateTextStream emits multiple chunks', () async {
      final chunks = <String>[];

      await for (final result in service.generateTextStream('test')) {
        if (result.isSuccess) {
          chunks.add(result.valueOrNull!);
        }
      }

      expect(chunks, isNotEmpty);
    });
  });
}
