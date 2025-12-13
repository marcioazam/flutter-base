import 'package:flutter_base_2025/core/storage/token_storage.dart';
import 'package:grpc/grpc.dart';

/// Interceptor that attaches auth tokens to gRPC metadata.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 1.6**
///
/// This interceptor reads the access token from [TokenStorage] and
/// attaches it to the Authorization header of every gRPC call.
/// If no token is available, the call proceeds without authentication.
///
/// Note: Due to gRPC interceptor limitations with async token retrieval,
/// this interceptor caches the token synchronously. For production use,
/// ensure tokens are pre-fetched or use a synchronous token cache.
class GrpcAuthInterceptor extends ClientInterceptor {
  GrpcAuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;
  String? _cachedToken;
  DateTime? _tokenCachedAt;

  static const _authorizationKey = 'authorization';
  static const _bearerPrefix = 'Bearer ';
  static const _tokenCacheDuration = Duration(minutes: 5);

  /// Pre-fetch and cache the token for synchronous access in interceptor.
  Future<void> refreshToken() async {
    _cachedToken = await _tokenStorage.getAccessToken();
    _tokenCachedAt = DateTime.now();
  }

  /// Check if cached token is still valid (not expired).
  bool get _isTokenCacheValid {
    if (_cachedToken == null || _tokenCachedAt == null) return false;
    return DateTime.now().difference(_tokenCachedAt!) < _tokenCacheDuration;
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final newOptions = _attachTokenToOptions(options);
    return invoker(method, request, newOptions);
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    final newOptions = _attachTokenToOptions(options);
    return invoker(method, requests, newOptions);
  }

  CallOptions _attachTokenToOptions(CallOptions options) {
    final token = _cachedToken;
    if (token == null || token.isEmpty) {
      return options;
    }

    return options.mergedWith(
      CallOptions(metadata: {_authorizationKey: '$_bearerPrefix$token'}),
    );
  }

  /// Attach token to metadata (for testing and direct use).
  Future<Map<String, String>> attachToken(Map<String, String>? metadata) async {
    final token = await _tokenStorage.getAccessToken();
    final result = Map<String, String>.from(metadata ?? {});

    if (token != null && token.isNotEmpty) {
      result[_authorizationKey] = '$_bearerPrefix$token';
    }

    return result;
  }

  /// Clear cached token (call on logout).
  void clearCache() {
    _cachedToken = null;
    _tokenCachedAt = null;
  }

  /// Check if token needs refresh.
  bool get needsRefresh => !_isTokenCacheValid;
}
