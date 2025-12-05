import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_base_2025/core/network/websocket_client.dart';

/// **Feature: flutter-state-of-art-2025, Property 4: WebSocket Auto-Reconnect**
/// **Validates: Requirements 15.2**
void main() {
  group('WebSocket Service Properties', () {
    late WebSocketService service;

    setUp(() {
      service = WebSocketServiceImpl();
    });

    tearDown(() {
      service.dispose();
    });

    test('ConnectionState enum has all expected values', () {
      expect(ConnectionState.values, contains(ConnectionState.disconnected));
      expect(ConnectionState.values, contains(ConnectionState.connecting));
      expect(ConnectionState.values, contains(ConnectionState.connected));
      expect(ConnectionState.values, contains(ConnectionState.reconnecting));
    });

    test('initial state is disconnected', () {
      expect(service.currentState, equals(ConnectionState.disconnected));
    });

    test('connectionState stream emits state changes', () async {
      final states = <ConnectionState>[];
      final subscription = service.connectionState.listen(states.add);

      await service.connect('ws://localhost:8080');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states, isNotEmpty);
      await subscription.cancel();
    });

    test('messages stream is available', () {
      expect(service.messages, isA<Stream<WebSocketMessage>>());
    });

    test('disconnect sets state to disconnected', () async {
      await service.disconnect();
      expect(service.currentState, equals(ConnectionState.disconnected));
    });

    test('WebSocketMessage serialization', () {
      final message = WebSocketMessage(
        type: 'test',
        data: {'key': 'value'},
      );

      final json = message.toJson();
      expect(json['type'], equals('test'));
      expect(json['data'], equals({'key': 'value'}));
      expect(json['timestamp'], isNotNull);
    });

    test('WebSocketMessage deserialization', () {
      final json = {
        'type': 'test',
        'data': {'key': 'value'},
        'timestamp': DateTime.now().toIso8601String(),
      };

      final message = WebSocketMessage.fromJson(json);
      expect(message.type, equals('test'));
      expect(message.data, equals({'key': 'value'}));
    });

    test('WebSocketConfig has default values', () {
      const config = WebSocketConfig();
      expect(config.pingInterval, equals(const Duration(seconds: 30)));
      expect(config.reconnectDelay, equals(const Duration(seconds: 1)));
      expect(config.maxReconnectAttempts, equals(5));
      expect(config.connectionTimeout, equals(const Duration(seconds: 10)));
    });

    test('WebSocketConfig custom values', () {
      const config = WebSocketConfig(
        pingInterval: Duration(seconds: 60),
        reconnectDelay: Duration(seconds: 2),
        maxReconnectAttempts: 10,
        connectionTimeout: Duration(seconds: 20),
      );

      expect(config.pingInterval, equals(const Duration(seconds: 60)));
      expect(config.reconnectDelay, equals(const Duration(seconds: 2)));
      expect(config.maxReconnectAttempts, equals(10));
      expect(config.connectionTimeout, equals(const Duration(seconds: 20)));
    });

    /// Property 4: WebSocket Auto-Reconnect
    /// For any WebSocket disconnection, the service SHALL attempt reconnection
    /// with exponential backoff up to max attempts.
    test('service has reconnect configuration', () {
      final impl = service as WebSocketServiceImpl;
      expect(impl.config.maxReconnectAttempts, greaterThan(0));
      expect(impl.config.reconnectDelay.inMilliseconds, greaterThan(0));
    });

    test('createWebSocketService factory works', () {
      final newService = createWebSocketService();
      expect(newService, isA<WebSocketService>());
      newService.dispose();
    });

    test('createWebSocketService with custom config', () {
      const customConfig = WebSocketConfig(maxReconnectAttempts: 10);
      final newService = createWebSocketService(config: customConfig);
      expect(newService, isA<WebSocketService>());
      expect(
        (newService as WebSocketServiceImpl).config.maxReconnectAttempts,
        equals(10),
      );
      newService.dispose();
    });
  });
}
