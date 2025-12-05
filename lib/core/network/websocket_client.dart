import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Connection state for WebSocket.
enum WebSocketState { disconnected, connecting, connected, reconnecting }

/// Generic WebSocket client with auto-reconnect.
/// T = Message type
class WebSocketClient<T> {
  final String url;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T message)? toJson;
  final Duration reconnectDelay;
  final int maxReconnectAttempts;
  final Duration pingInterval;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final _messageController = StreamController<T>.broadcast();
  final _stateController = StreamController<WebSocketState>.broadcast();
  final _messageQueue = <T>[];

  WebSocketState _state = WebSocketState.disconnected;
  int _reconnectAttempts = 0;

  WebSocketClient({
    required this.url,
    required this.fromJson,
    this.toJson,
    this.reconnectDelay = const Duration(seconds: 1),
    this.maxReconnectAttempts = 10,
    this.pingInterval = const Duration(seconds: 30),
  });

  /// Stream of incoming messages.
  Stream<T> get messages => _messageController.stream;

  /// Stream of connection state changes.
  Stream<WebSocketState> get stateChanges => _stateController.stream;

  /// Current connection state.
  WebSocketState get state => _state;

  /// Returns true if connected.
  bool get isConnected => _state == WebSocketState.connected;

  /// Connects to the WebSocket server.
  Future<void> connect() async {
    if (_state == WebSocketState.connected ||
        _state == WebSocketState.connecting) {
      return;
    }

    _setState(WebSocketState.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;

      _setState(WebSocketState.connected);
      _reconnectAttempts = 0;

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      _startPingTimer();
      _flushMessageQueue();
    } catch (e) {
      _setState(WebSocketState.disconnected);
      _scheduleReconnect();
    }
  }

  /// Disconnects from the WebSocket server.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _subscription?.cancel();

    await _channel?.sink.close();
    _channel = null;

    _setState(WebSocketState.disconnected);
    _reconnectAttempts = 0;
  }

  /// Sends a message to the server.
  void send(T message) {
    if (_state != WebSocketState.connected) {
      _messageQueue.add(message);
      return;
    }

    _sendMessage(message);
  }

  /// Sends a raw JSON message.
  void sendRaw(Map<String, dynamic> json) {
    if (_state != WebSocketState.connected) {
      return;
    }

    _channel?.sink.add(jsonEncode(json));
  }

  /// Disposes resources.
  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
    await _stateController.close();
  }

  void _onMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final message = fromJson(json);
      _messageController.add(message);
    } catch (e) {
      // Log error but don't crash
    }
  }

  void _onError(Object error) {
    _scheduleReconnect();
  }

  void _onDone() {
    _setState(WebSocketState.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      return;
    }

    _reconnectTimer?.cancel();
    _setState(WebSocketState.reconnecting);

    final delay = _calculateBackoff();
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  Duration _calculateBackoff() {
    // Exponential backoff with jitter
    final baseDelay = reconnectDelay.inMilliseconds;
    final exponentialDelay = baseDelay * (1 << _reconnectAttempts);
    final maxDelay = 30000; // 30 seconds max
    final actualDelay = exponentialDelay.clamp(baseDelay, maxDelay);
    return Duration(milliseconds: actualDelay);
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(pingInterval, (_) {
      if (_state == WebSocketState.connected) {
        _channel?.sink.add('ping');
      }
    });
  }

  void _flushMessageQueue() {
    while (_messageQueue.isNotEmpty && _state == WebSocketState.connected) {
      final message = _messageQueue.removeAt(0);
      _sendMessage(message);
    }
  }

  void _sendMessage(T message) {
    if (toJson != null) {
      _channel?.sink.add(jsonEncode(toJson!(message)));
    } else {
      _channel?.sink.add(message.toString());
    }
  }

  void _setState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }
}

/// Simple string-based WebSocket client.
class StringWebSocketClient extends WebSocketClient<String> {
  StringWebSocketClient({
    required super.url,
    super.reconnectDelay,
    super.maxReconnectAttempts,
  }) : super(
          fromJson: (json) => jsonEncode(json),
          toJson: (message) => {'message': message},
        );
}
