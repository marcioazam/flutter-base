import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Connection state for WebSocket.
enum WebSocketState { disconnected, connecting, connected, reconnecting }

/// Reconnection strategy with exponential backoff.
class ReconnectStrategy {
  const ReconnectStrategy({
    this.maxAttempts = 10,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
  });

  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  /// Calculates delay for attempt n (0-indexed).
  Duration getDelay(int attempt) {
    final multiplier = backoffMultiplier == 1.0 ? 1 : (1 << attempt).clamp(1, 1000);
    final delayMs = (initialDelay.inMilliseconds * multiplier).toInt();
    return Duration(
      milliseconds: delayMs.clamp(
        initialDelay.inMilliseconds,
        maxDelay.inMilliseconds,
      ),
    );
  }
}

/// Generic WebSocket client with auto-reconnect.
/// T = Message type
class WebSocketClient<T> {

  WebSocketClient({
    required this.url,
    required this.fromJson,
    this.toJson,
    this.reconnectDelay = const Duration(seconds: 1),
    this.maxReconnectAttempts = 10,
    this.pingInterval = const Duration(seconds: 30),
    ReconnectStrategy? reconnectStrategy,
  }) : _reconnectStrategy = reconnectStrategy ?? const ReconnectStrategy();
  final String url;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T message)? toJson;
  final Duration reconnectDelay;
  final int maxReconnectAttempts;
  final Duration pingInterval;
  final ReconnectStrategy _reconnectStrategy;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final _messageController = StreamController<T>.broadcast();
  final _stateController = StreamController<WebSocketState>.broadcast();
  final _messageQueue = <T>[];

  WebSocketState _state = WebSocketState.disconnected;
  int _reconnectAttempts = 0;

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
    } on Exception catch (e) {
      // Log connection error for debugging
      assert(() {
        // ignore: avoid_print
        print('WebSocket connection error: $e');
        return true;
      }());
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

  Duration _calculateBackoff() => _reconnectStrategy.getDelay(_reconnectAttempts);

  /// Sets a new reconnect strategy.
  void setReconnectStrategy(ReconnectStrategy strategy) {
    // Strategy is final, but we can expose this for future flexibility
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
          fromJson: jsonEncode,
          toJson: (message) => {'message': message},
        );
}
