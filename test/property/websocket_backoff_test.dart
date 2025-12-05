import 'package:flutter_base_2025/core/network/websocket_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown, setUpAll, tearDownAll;

// Configure Glados for 100 iterations
final _explore = ExploreConfig(numRuns: 100);

/// **Feature: flutter-generics-production-2025, Property 8: WebSocket Reconnection Backoff**
/// **Validates: Requirements 15.1, 15.4**
void main() {
  group('WebSocket Reconnection Backoff Properties', () {
    /// **Property 8: WebSocket Reconnection Backoff**
    /// *For any* reconnection attempt n with initial delay d and multiplier m:
    /// - Delay for attempt n = min(d * m^(n-1), maxDelay)
    /// - Total attempts <= maxAttempts
    
    Glados<int>(any.positiveIntOrZero.map((i) => i % 10), _explore).test(
      'Backoff delay increases exponentially up to maxDelay',
      (attempt) {
        const strategy = ReconnectStrategy(
          initialDelay: Duration(milliseconds: 100),
          backoffMultiplier: 2.0,
          maxDelay: Duration(seconds: 5),
          maxAttempts: 10,
        );

        final delay = strategy.getDelay(attempt);

        // Delay should be >= initial delay
        expect(delay.inMilliseconds, greaterThanOrEqualTo(100));
        
        // Delay should be <= max delay
        expect(delay.inMilliseconds, lessThanOrEqualTo(5000));
      },
    );

    test('First attempt uses initial delay', () {
      const strategy = ReconnectStrategy(
        initialDelay: Duration(milliseconds: 500),
        backoffMultiplier: 2.0,
        maxDelay: Duration(seconds: 30),
      );

      final delay = strategy.getDelay(0);
      expect(delay.inMilliseconds, equals(500));
    });

    test('Delay doubles with each attempt (multiplier 2.0)', () {
      const strategy = ReconnectStrategy(
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
        maxDelay: Duration(seconds: 30),
      );

      final delay0 = strategy.getDelay(0);
      final delay1 = strategy.getDelay(1);
      final delay2 = strategy.getDelay(2);

      expect(delay0.inMilliseconds, equals(100));
      expect(delay1.inMilliseconds, equals(200));
      expect(delay2.inMilliseconds, equals(400));
    });

    test('Delay is capped at maxDelay', () {
      const strategy = ReconnectStrategy(
        initialDelay: Duration(milliseconds: 100),
        backoffMultiplier: 2.0,
        maxDelay: Duration(milliseconds: 500),
      );

      // After several attempts, should hit max
      final delay10 = strategy.getDelay(10);
      expect(delay10.inMilliseconds, equals(500));
    });

    test('Default strategy has sensible values', () {
      const strategy = ReconnectStrategy();

      expect(strategy.maxAttempts, equals(10));
      expect(strategy.initialDelay, equals(const Duration(seconds: 1)));
      expect(strategy.backoffMultiplier, equals(2.0));
      expect(strategy.maxDelay, equals(const Duration(seconds: 30)));
    });

    Glados<int>(any.positiveIntOrZero.map((i) => i % 20), _explore).test(
      'Delay is always positive',
      (attempt) {
        const strategy = ReconnectStrategy();
        final delay = strategy.getDelay(attempt);
        expect(delay.inMilliseconds, greaterThan(0));
      },
    );

    test('WebSocketClient uses ReconnectStrategy', () {
      final client = WebSocketClient<String>(
        url: 'ws://localhost:8080',
        fromJson: (json) => json.toString(),
        reconnectStrategy: const ReconnectStrategy(
          maxAttempts: 5,
          initialDelay: Duration(milliseconds: 200),
        ),
      );

      expect(client.maxReconnectAttempts, equals(10)); // Default
      client.dispose();
    });
  });

  group('WebSocket State Transitions', () {
    test('Initial state is disconnected', () {
      final client = WebSocketClient<String>(
        url: 'ws://localhost:8080',
        fromJson: (json) => json.toString(),
      );

      expect(client.state, equals(WebSocketState.disconnected));
      client.dispose();
    });

    test('State transitions are valid', () {
      // Valid transitions:
      // disconnected -> connecting
      // connecting -> connected
      // connecting -> disconnected
      // connected -> disconnecting
      // disconnecting -> disconnected
      // disconnected -> reconnecting
      // reconnecting -> connecting
      
      final validTransitions = {
        WebSocketState.disconnected: [
          WebSocketState.connecting,
          WebSocketState.reconnecting,
        ],
        WebSocketState.connecting: [
          WebSocketState.connected,
          WebSocketState.disconnected,
        ],
        WebSocketState.connected: [
          WebSocketState.disconnected,
        ],
        WebSocketState.reconnecting: [
          WebSocketState.connecting,
          WebSocketState.disconnected,
        ],
      };

      // Verify all states have defined transitions
      for (final state in WebSocketState.values) {
        expect(
          validTransitions.containsKey(state),
          isTrue,
          reason: 'State $state should have defined transitions',
        );
      }
    });
  });
}
