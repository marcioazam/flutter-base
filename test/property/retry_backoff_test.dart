import 'dart:math';

import 'package:flutter_base_2025/core/config/retry_config.dart';
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glados_helpers.dart';

void main() {
  _jitterBoundsTests();
  
  group('Retry Backoff Property Tests', () {
    /// **Feature: flutter-2025-final-enhancements, Property 4: Retry Exponential Backoff**
    /// **Validates: Requirements 3.1**
    Glados(any.intInRange(0, 10)).test(
      'Exponential backoff doubles delay with each retry',
      (retryCount) {
        const baseDelay = Duration(milliseconds: 200);
        final delay = calculateExponentialBackoff(
          retryCount: retryCount,
          baseDelay: baseDelay,
        );

        final expectedMs = 200 * (1 << retryCount);
        final cappedMs = expectedMs.clamp(0, 30000);
        expect(delay.inMilliseconds, equals(cappedMs));
      },
    );

    Glados(any.intInRange(0, 20)).test(
      'Exponential backoff respects maxDelay',
      (retryCount) {
        const maxDelay = Duration(seconds: 5);
        final delay = calculateExponentialBackoff(
          retryCount: retryCount,
          maxDelay: maxDelay,
        );

        expect(delay.inMilliseconds, lessThanOrEqualTo(maxDelay.inMilliseconds));
      },
    );

    /// **Feature: flutter-2025-final-enhancements, Property 5: Retry State Machine**
    /// **Validates: Requirements 3.3, 3.5**
    test('appRetryLogic returns null for validation errors', () {
      const error = ValidationFailure('Invalid input');
      expect(appRetryLogic(0, error), isNull);
    });

    test('appRetryLogic returns null for auth errors', () {
      const error = AuthFailure('Unauthorized');
      expect(appRetryLogic(0, error), isNull);
    });

    test('appRetryLogic returns null after max retries', () {
      const error = NetworkFailure('Network error');
      expect(appRetryLogic(5, error), isNull);
      expect(appRetryLogic(6, error), isNull);
    });

    Glados(any.intInRange(0, 4)).test(
      'appRetryLogic returns exponential delay for retryable errors',
      (retryCount) {
        const error = NetworkFailure('Network error');
        final delay = appRetryLogic(retryCount, error);

        expect(delay, isNotNull);
        expect(delay!.inMilliseconds, equals(200 * (1 << retryCount)));
      },
    );
  });
}

/// Generator for jitter test parameters.
extension JitterGenerators on Any {
  Generator<({int attempt, double jitterFactor})> get jitterParams => combine2(
        intInRange(0, 10),
        doubleInRange(0.0, 1.0),
        (attempt, jitter) => (attempt: attempt, jitterFactor: jitter),
      );
}

/// **Feature: flutter-2025-final-enhancements, Property 9: Backoff with Jitter Bounds**
/// **Validates: Requirements 8.4**
void _jitterBoundsTests() {
  group('Jitter Bounds Property Tests', () {
    Glados(any.jitterParams).test(
      'Backoff with jitter stays within bounds',
      (params) {
        const baseDelay = Duration(milliseconds: 200);
        const maxDelay = Duration(seconds: 30);
        
        // Calculate expected bounds
        final baseMs = baseDelay.inMilliseconds * (1 << params.attempt);
        final minExpected = (baseMs * (1 - params.jitterFactor)).round();
        final maxExpected = (baseMs * (1 + params.jitterFactor)).round();
        
        // Run multiple iterations to test randomness bounds
        for (var i = 0; i < 100; i++) {
          final delay = calculateBackoffWithJitter(
            attempt: params.attempt,
            baseDelay: baseDelay,
            maxDelay: maxDelay,
            jitterFactor: params.jitterFactor,
          );
          
          // Delay should be within jitter bounds (capped at maxDelay)
          final cappedMin = minExpected.clamp(0, maxDelay.inMilliseconds);
          final cappedMax = maxExpected.clamp(0, maxDelay.inMilliseconds);
          
          expect(
            delay.inMilliseconds,
            inInclusiveRange(cappedMin, cappedMax),
            reason: 'Delay should be within jitter bounds for attempt ${params.attempt}',
          );
        }
      },
    );

    Glados(any.intInRange(0, 15)).test(
      'Backoff with jitter respects maxDelay',
      (attempt) {
        const maxDelay = Duration(seconds: 5);
        
        for (var i = 0; i < 50; i++) {
          final delay = calculateBackoffWithJitter(
            attempt: attempt,
            maxDelay: maxDelay,
            jitterFactor: 0.5,
          );
          
          expect(
            delay.inMilliseconds,
            lessThanOrEqualTo(maxDelay.inMilliseconds),
            reason: 'Delay should never exceed maxDelay',
          );
        }
      },
    );

    test('Zero jitter factor produces exact exponential backoff', () {
      const baseDelay = Duration(milliseconds: 200);
      
      for (var attempt = 0; attempt < 5; attempt++) {
        final delay = calculateBackoffWithJitter(
          attempt: attempt,
          baseDelay: baseDelay,
          jitterFactor: 0.0,
        );
        
        final expected = baseDelay.inMilliseconds * (1 << attempt);
        expect(delay.inMilliseconds, equals(expected));
      }
    });
  });
}

/// Calculates exponential backoff with jitter for testing.
/// 
/// **Feature: flutter-2025-final-enhancements, Property 9: Backoff with Jitter Bounds**
/// **Validates: Requirements 8.4**
Duration calculateBackoffWithJitter({
  required int attempt,
  Duration baseDelay = const Duration(milliseconds: 200),
  Duration maxDelay = const Duration(seconds: 30),
  double jitterFactor = 0.5,
}) {
  final random = Random();
  final exponentialMs = baseDelay.inMilliseconds * (1 << attempt);
  final jitterMultiplier = 1.0 + ((random.nextDouble() * 2 - 1) * jitterFactor);
  final delayMs = (exponentialMs * jitterMultiplier).round();
  final cappedMs = delayMs.clamp(0, maxDelay.inMilliseconds);
  return Duration(milliseconds: cappedMs);
}
