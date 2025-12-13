import 'package:flutter_base_2025/core/grpc/grpc_config.dart';
import 'package:flutter_base_2025/core/grpc/interceptors/grpc_auth_interceptor.dart';
import 'package:flutter_base_2025/core/storage/token_storage.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';

/// Centralized gRPC client managing channel lifecycle and interceptors.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 1.4, 5.1, 5.3, 5.4**
///
/// This client provides:
/// - Channel creation with TLS support
/// - Interceptor chain (auth, logging)
/// - Stub factory for creating service clients
/// - Proper resource cleanup
class GrpcClient {
  GrpcClient({
    required GrpcConfig config,
    required TokenStorage tokenStorage,
    Logger? logger,
  })  : _config = config,
        _tokenStorage = tokenStorage,
        _logger = logger ?? Logger();

  final GrpcConfig _config;
  final TokenStorage _tokenStorage;
  final Logger _logger;

  ClientChannel? _channel;
  bool _isDisposed = false;

  /// Get or create a channel for the configured host.
  ClientChannel get channel {
    if (_isDisposed) {
      throw StateError('GrpcClient has been disposed');
    }

    _channel ??= _createChannel();
    return _channel!;
  }

  /// Create a stub with interceptors applied.
  ///
  /// Example:
  /// ```dart
  /// final stub = grpcClient.createStub(
  ///   (channel) => MyServiceClient(channel),
  /// );
  /// ```
  T createStub<T>(T Function(ClientChannel channel) stubFactory) =>
      stubFactory(channel);

  /// Create a stub with custom call options.
  T createStubWithOptions<T>(
    T Function(ClientChannel channel, CallOptions options) stubFactory, {
    Duration? timeout,
    Map<String, String>? metadata,
  }) {
    final options = CallOptions(
      timeout: timeout ?? _config.timeout,
      metadata: metadata,
    );
    return stubFactory(channel, options);
  }

  /// Close the channel and release resources.
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;
    await _channel?.shutdown();
    _channel = null;
    _logger.d('GrpcClient disposed');
  }

  /// Check if client is disposed.
  bool get isDisposed => _isDisposed;

  ClientChannel _createChannel() {
    _logger.d(
      'Creating gRPC channel: ${_config.host}:${_config.port} '
      '(TLS: ${_config.useTls})',
    );

    final channelOptions = ChannelOptions(
      credentials: _config.useTls
          ? const ChannelCredentials.secure()
          : const ChannelCredentials.insecure(),
      connectionTimeout: _config.timeout,
      idleTimeout: _config.keepAliveTime,
    );

    return ClientChannel(
      _config.host,
      port: _config.port,
      options: channelOptions,
    );
  }

  /// Get interceptors for this client.
  List<ClientInterceptor> get interceptors => [
        GrpcAuthInterceptor(_tokenStorage),
        _LoggingInterceptor(_logger),
      ];

  /// Create call options with default timeout.
  CallOptions get defaultCallOptions => CallOptions(
        timeout: _config.timeout,
      );

  /// Execute a gRPC call with automatic retry on transient failures.
  ///
  /// Retries on: UNAVAILABLE, RESOURCE_EXHAUSTED, ABORTED
  /// Uses exponential backoff based on config.retryDelay.
  ///
  /// Example:
  /// ```dart
  /// final response = await grpcClient.callWithRetry(
  ///   () => stub.myMethod(request),
  /// );
  /// ```
  Future<T> callWithRetry<T>(
    Future<T> Function() call, {
    int? maxRetries,
  }) async {
    final retries = maxRetries ?? _config.maxRetries;
    Object? lastError;

    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        return await call();
      } on GrpcError catch (e) {
        lastError = e;
        if (!_isRetryableError(e.code) || attempt == retries) {
          rethrow;
        }
        final delay = _config.retryDelay * (attempt + 1);
        _logger.w(
          'gRPC call failed (attempt ${attempt + 1}/$retries), '
          'retrying in ${delay.inMilliseconds}ms: ${e.message}',
        );
        await Future<void>.delayed(delay);
      }
    }

    // This should never be reached, but satisfies the analyzer
    throw StateError('Retry loop completed without result: $lastError');
  }

  /// Check if a gRPC error code is retryable.
  bool _isRetryableError(int code) => const [
        StatusCode.unavailable,
        StatusCode.resourceExhausted,
        StatusCode.aborted,
      ].contains(code);

  /// Get the current configuration.
  GrpcConfig get config => _config;
}

/// Logging interceptor for gRPC calls.
class _LoggingInterceptor extends ClientInterceptor {
  _LoggingInterceptor(this._logger);

  final Logger _logger;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final stopwatch = Stopwatch()..start();
    _logger.d('gRPC call: ${method.path}');

    final response = invoker(method, request, options);

    response.then((_) {
      stopwatch.stop();
      _logger.d('gRPC call completed: ${method.path} (${stopwatch.elapsedMilliseconds}ms)');
    }).catchError((Object error) {
      stopwatch.stop();
      _logger.e('gRPC call failed: ${method.path} (${stopwatch.elapsedMilliseconds}ms)', error: error);
    });

    return response;
  }
}
