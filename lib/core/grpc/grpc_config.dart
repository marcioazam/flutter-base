import 'package:equatable/equatable.dart';

/// Configuration for gRPC connections.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 5.4**
class GrpcConfig extends Equatable {
  const GrpcConfig({
    required this.host,
    required this.port,
    this.useTls = true,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(milliseconds: 500),
    this.keepAliveTime = const Duration(seconds: 30),
    this.keepAliveTimeout = const Duration(seconds: 10),
  }) : assert(port > 0 && port <= 65535, 'Port must be between 1 and 65535'),
       assert(maxRetries >= 0, 'maxRetries must be non-negative');

  /// Create config from environment variables
  factory GrpcConfig.fromEnv({
    required String host,
    required int port,
    bool? useTls,
    int? timeoutSeconds,
    int? maxRetries,
    int? retryDelayMs,
  }) => GrpcConfig(
    host: host,
    port: port,
    useTls: useTls ?? true,
    timeout: Duration(seconds: timeoutSeconds ?? 30),
    maxRetries: maxRetries ?? 3,
    retryDelay: Duration(milliseconds: retryDelayMs ?? 500),
  );

  /// gRPC server host
  final String host;

  /// gRPC server port
  final int port;

  /// Whether to use TLS/SSL for secure communication
  final bool useTls;

  /// Timeout for gRPC calls
  final Duration timeout;

  /// Maximum number of retry attempts
  final int maxRetries;

  /// Delay between retry attempts
  final Duration retryDelay;

  /// Keep-alive ping interval
  final Duration keepAliveTime;

  /// Keep-alive ping timeout
  final Duration keepAliveTimeout;

  @override
  List<Object?> get props => [host, port, useTls, timeout, maxRetries];

  @override
  String toString() => 'GrpcConfig(host: $host, port: $port, useTls: $useTls)';

  /// Create a copy with modified values.
  GrpcConfig copyWith({
    String? host,
    int? port,
    bool? useTls,
    Duration? timeout,
    int? maxRetries,
    Duration? retryDelay,
    Duration? keepAliveTime,
    Duration? keepAliveTimeout,
  }) => GrpcConfig(
    host: host ?? this.host,
    port: port ?? this.port,
    useTls: useTls ?? this.useTls,
    timeout: timeout ?? this.timeout,
    maxRetries: maxRetries ?? this.maxRetries,
    retryDelay: retryDelay ?? this.retryDelay,
    keepAliveTime: keepAliveTime ?? this.keepAliveTime,
    keepAliveTimeout: keepAliveTimeout ?? this.keepAliveTimeout,
  );
}
