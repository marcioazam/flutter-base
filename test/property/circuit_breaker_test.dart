import 'package:flutter_base_2025/core/network/circuit_breaker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glados_helpers.dart';

/// Generators for circuit breaker testing.
extension CircuitBreakerGenerators on Any {
  Generator<CircuitBreakerConfig> get circuitConfig => combine3(
        intInRange(1, 10),
        intInRange(1, 5),
        intInRange(1000, 60000),
        (failures, successes, timeout) => CircuitBreakerConfig(
          failureThreshold: failures,
          successThreshold: successes,
          timeout: Duration(milliseconds: timeout),
        ),
      );
}

void main() {
  group('Circuit Breaker Property Tests', () {
    /// **Feature: flutter-2025-final-enhancements, Property 6: Circuit Breaker State Machine**
    /// **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**
    Glados(any.circuitConfig).test(
      'Circuit breaker starts in closed state',
      (config) {
        final cb = CircuitBreaker<String>(
          config: config,
          execute: () async => 'success',
        );
        expect(cb.state, equals(CircuitState.closed));
      },
    );

    Glados(any.circuitConfig).test(
      'Circuit opens after failureThreshold consecutive failures',
      (config) async {
        final cb = CircuitBreaker<String>(
          config: config,
          execute: () async {
            throw Exception('Simulated failure');
          },
        );

        // Execute until threshold
        for (var i = 0; i < config.failureThreshold; i++) {
          await cb.call();
        }

        expect(cb.state, equals(CircuitState.open));
        expect(cb.failureCount, equals(config.failureThreshold));
      },
    );


    Glados(any.circuitConfig).test(
      'Success resets failure count in closed state',
      (config) async {
        var shouldFail = true;
        final cb = CircuitBreaker<String>(
          config: config,
          execute: () async {
            if (shouldFail) throw Exception('fail');
            return 'success';
          },
        );

        // Fail a few times (but not enough to open)
        final failuresBeforeOpen = config.failureThreshold - 1;
        for (var i = 0; i < failuresBeforeOpen; i++) {
          await cb.call();
        }

        // Now succeed
        shouldFail = false;
        await cb.call();

        expect(cb.failureCount, equals(0));
        expect(cb.state, equals(CircuitState.closed));
      },
    );

    Glados(any.circuitConfig).test(
      'Half-open state closes after successThreshold successes',
      (config) async {
        var shouldFail = true;
        final cb = CircuitBreaker<String>(
          config: CircuitBreakerConfig(
            failureThreshold: config.failureThreshold,
            successThreshold: config.successThreshold,
            timeout: Duration.zero, // Immediate transition to half-open
          ),
          execute: () async {
            if (shouldFail) throw Exception('fail');
            return 'success';
          },
        );

        // Open the circuit
        for (var i = 0; i < config.failureThreshold; i++) {
          await cb.call();
        }
        expect(cb.state, equals(CircuitState.open));

        // Allow success
        shouldFail = false;

        // First call transitions to half-open and succeeds
        for (var i = 0; i < config.successThreshold; i++) {
          await cb.call();
        }

        expect(cb.state, equals(CircuitState.closed));
      },
    );

    /// **Feature: flutter-2025-final-enhancements, Property 7: Circuit Breaker Fail Fast**
    /// **Validates: Requirements 5.3**
    Glados(any.circuitConfig).test(
      'Open circuit fails fast without executing',
      (config) async {
        var executeCount = 0;
        final cb = CircuitBreaker<String>(
          config: CircuitBreakerConfig(
            failureThreshold: config.failureThreshold,
            successThreshold: config.successThreshold,
            timeout: const Duration(hours: 1), // Long timeout
          ),
          execute: () async {
            executeCount++;
            throw Exception('fail');
          },
        );

        // Open the circuit
        for (var i = 0; i < config.failureThreshold; i++) {
          await cb.call();
        }
        final countAfterOpen = executeCount;

        // Try to call again - should fail fast
        final result = await cb.call();

        expect(result.isFailure, isTrue);
        expect(executeCount, equals(countAfterOpen)); // No new executions
        expect(result.failureOrNull, isA<CircuitOpenFailure>());
      },
    );
  });
}
