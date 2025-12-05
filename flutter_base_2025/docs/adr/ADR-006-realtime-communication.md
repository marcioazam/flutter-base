# ADR-006: Real-time Communication

## Status

Accepted

## Context

The application requires real-time communication capabilities for features like chat, live updates, and notifications. A reliable, scalable solution is needed that handles connection management gracefully.

### Requirements

- Bidirectional real-time communication
- Automatic reconnection on connection loss
- Connection state management
- Support for both WebSocket and GraphQL subscriptions
- Message queuing during disconnection

### Options Considered

1. **WebSocket (web_socket_channel)** - Low-level, full control
2. **Socket.IO (socket_io_client)** - Higher-level with rooms/namespaces
3. **GraphQL Subscriptions (Ferry)** - Type-safe, integrated with queries
4. **Firebase Realtime Database** - Managed solution

## Decision

Implement dual support for WebSocket and GraphQL subscriptions.

### Rationale

- **Flexibility**: Different use cases benefit from different protocols
- **WebSocket**: Best for custom protocols and high-frequency updates
- **GraphQL**: Best for type-safe data synchronization
- **No vendor lock-in**: Standard protocols

## Implementation

### WebSocket Service

```dart
abstract interface class WebSocketService {
  Stream<ConnectionState> get connectionState;
  Stream<WebSocketMessage> get messages;
  Future<void> connect(String url);
  void send(WebSocketMessage message);
  Future<void> disconnect();
}
```

### Auto-Reconnect Strategy

```dart
// Exponential backoff: 1s, 2s, 4s, 8s, 16s (max 5 attempts)
final delay = Duration(
  milliseconds: baseDelay.inMilliseconds * pow(2, attempt - 1),
);
```

### GraphQL Subscriptions

```dart
Stream<Result<T>> executeSubscription(GraphQLRequest request) {
  return client.subscribe(request).map((response) => ...);
}
```

### Packages

- `web_socket_channel: ^2.4.0`
- `ferry: ^0.15.0` (for GraphQL)

## Consequences

### Positive

- Full control over connection lifecycle
- Graceful degradation on poor networks
- Type-safe GraphQL subscriptions
- Unified connection state management

### Negative

- More complex than managed solutions
- Must handle reconnection logic
- Need to implement message queuing

### Neutral

- Requires backend WebSocket/GraphQL support
- Connection state must be exposed to UI

## Connection States

```dart
enum ConnectionState {
  disconnected,  // Not connected
  connecting,    // Attempting connection
  connected,     // Active connection
  reconnecting,  // Lost connection, attempting reconnect
}
```

## Best Practices

1. Always show connection state to user
2. Queue messages during reconnection
3. Implement heartbeat/ping mechanism
4. Handle token refresh for authenticated connections
5. Clean up subscriptions on dispose

## References

- [WebSocket Channel](https://pub.dev/packages/web_socket_channel)
- [Ferry GraphQL](https://ferrygraphql.com/)
- [Socket.IO Client](https://pub.dev/packages/socket_io_client)
