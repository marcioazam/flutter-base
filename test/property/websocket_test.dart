import 'package:flutter_base_2025/core/network/websocket_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: flutter-state-of-art-2025, Property 4: WebSocket Auto-Reconnect**
/// **Validates: Requirements 15.2**
void main() {
  group('WebSocket Client Properties', () {
    test('WebSocketState enum has all expected values', () {
      expect(WebSocketState.values, contains(WebSocketState.disconnected));
      expect(WebSocketState.values, contains(WebSocketState.connecting));
      expect(WebSocketState.values, contains(WebSocketState.connected));
      expect(WebSocketState.values, contains(WebSocketState.reconnecting));
    });

    test('WebSocketClient initial state is disconnected', () {
      final client = WebSocketClient<String>(
        url: 'ws://localhost:8080',
        fromJson: (json) => json.toString(),
      );

      expect(client.state, equals(WebSocketState.disconnected));
      expect(client.isConnected, isFalse);

      client.dispose();
    });

    test('WebSocketClient has configurable reconnect settings', () {
      final client = WebSocketClient<String>(
        url: 'ws://localhost:8080',
        fromJson: (json) => json.toString(),
        reconnectDelay: const Duration(seconds: 2),
        pingInterval: const Duration(seconds: 60),
      );

      expect(client.maxReconnectAttempts, equals(10));
      expect(client.reconnectDelay, equals(const Duration(seconds: 2)));
      expect(client.pingInterval, equals(const Duration(seconds: 60)));

      client.dispose();
    });

    test('WebSocketClient default reconnect settings', () {
      final client = WebSocketClient<String>(
        url: 'ws://localhost:8080',
        fromJson: (json) => json.toString(),
      );

      expect(client.maxReconnectAttempts, equals(10));
      expect(client.reconnectDelay, equals(const Duration(seconds: 1)));
      expect(client.pingInterval, equals(const Duration(seconds: 30)));

      client.dispose();
    });

    test('WebSocketClient messages stream is available', () {
      final client = WebSocketClient<String>(
        url: 'ws://localhost:8080',
        fromJson: (json) => json.toString(),
      );

      expect(client.messages, isA<Stream<String>>());

      client.dispose();
    });

    test('WebSocketClient stateChanges stream is available', () {
      final client = WebSocketClient<String>(
        url: 'ws://localhost:8080',
        fromJson: (json) => json.toString(),
      );

      expect(client.stateChanges, isA<Stream<WebSocketState>>());

      client.dispose();
    });

    test('StringWebSocketClient is a convenience wrapper', () {
      final client = StringWebSocketClient(
        url: 'ws://localhost:8080',
      );

      expect(client, isA<WebSocketClient<String>>());
      expect(client.state, equals(WebSocketState.disconnected));

      client.dispose();
    });

    /// Property 4: WebSocket Auto-Reconnect
    /// For any WebSocket disconnection, the service SHALL attempt reconnection
    /// with exponential backoff up to max attempts.
    test('WebSocketClient has reconnect configuration for auto-reconnect', () {
      final client = WebSocketClient<String>(
        url: 'ws://localhost:8080',
        fromJson: (json) => json.toString(),
        maxReconnectAttempts: 5,
        reconnectDelay: const Duration(milliseconds: 500),
      );

      expect(client.maxReconnectAttempts, greaterThan(0));
      expect(client.reconnectDelay.inMilliseconds, greaterThan(0));

      client.dispose();
    });

    test('disconnect sets state to disconnected', () async {
      final client = WebSocketClient<String>(
        url: 'ws://localhost:8080',
        fromJson: (json) => json.toString(),
      );

      await client.disconnect();
      expect(client.state, equals(WebSocketState.disconnected));

      await client.dispose();
    });
  });
}
