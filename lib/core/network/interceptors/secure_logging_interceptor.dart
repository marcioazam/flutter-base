import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Secure logging interceptor that sanitizes sensitive data.
///
/// **Feature: flutter-state-of-art-code-review-2025**
/// **Validates: Requirements VUL-004 (Secure logging), OWASP A09**
///
/// Prevents exposure of sensitive information in logs:
/// - Redacts Authorization, Cookie, API-Key headers
/// - Masks request/response bodies containing passwords, tokens
/// - Adds correlation IDs for tracing
/// - Respects environment-based logging levels
class SecureLoggingInterceptor extends Interceptor {
  SecureLoggingInterceptor({
    required this.enableLogging,
    this.maxBodyLength = 500,
  }) : _logger = Logger(
         printer: PrettyPrinter(
           methodCount: 0,
           errorMethodCount: 5,
           lineLength: 80,
         ),
       );

  final bool enableLogging;
  final int maxBodyLength;
  final Logger _logger;

  /// Sensitive headers that should be redacted.
  static const _sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'api-key',
    'access-token',
    'refresh-token',
  };

  /// Sensitive fields in request/response bodies.
  static const _sensitiveFields = {
    'password',
    'token',
    'access_token',
    'refresh_token',
    'api_key',
    'secret',
    'credential',
    'authorization',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enableLogging) {
      handler.next(options);
      return;
    }

    final correlationId = _generateCorrelationId();
    options.headers['X-Correlation-ID'] = correlationId;

    _logger.d(
      '→ [${options.method}] ${options.uri}\n'
      'Correlation-ID: $correlationId\n'
      'Headers: ${_sanitizeHeaders(options.headers)}\n'
      'Data: ${_sanitizeBody(options.data)}',
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!enableLogging) {
      handler.next(response);
      return;
    }

    final correlationId =
        response.requestOptions.headers['X-Correlation-ID'] ?? 'N/A';

    _logger.d(
      '← [${response.statusCode}] ${response.requestOptions.uri}\n'
      'Correlation-ID: $correlationId\n'
      'Data: ${_sanitizeBody(response.data)}',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enableLogging) {
      handler.next(err);
      return;
    }

    final correlationId =
        err.requestOptions.headers['X-Correlation-ID'] ?? 'N/A';

    _logger.e(
      '✖ [${err.response?.statusCode ?? 'N/A'}] ${err.requestOptions.uri}\n'
      'Correlation-ID: $correlationId\n'
      'Error: ${err.type.name}\n'
      'Message: ${err.message}\n'
      'Response: ${_sanitizeBody(err.response?.data)}',
    );

    handler.next(err);
  }

  /// Sanitizes headers by redacting sensitive ones.
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) =>
      headers.map((key, value) {
        final lowerKey = key.toLowerCase();
        if (_sensitiveHeaders.contains(lowerKey)) {
          return MapEntry(key, '***REDACTED***');
        }
        return MapEntry(key, value);
      });

  /// Sanitizes request/response body by masking sensitive fields.
  String _sanitizeBody(dynamic data) {
    if (data == null) return 'null';

    try {
      final sanitized = _recursiveSanitize(data);
      final json = sanitized.toString();

      // Truncate long bodies
      if (json.length > maxBodyLength) {
        return '${json.substring(0, maxBodyLength)}... (${json.length} chars total)';
      }

      return json;
    } on Exception {
      return '<non-serializable: ${data.runtimeType}>';
    }
  }

  String _generateCorrelationId() {
    final microsHex = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    if (microsHex.length <= 8) {
      return microsHex.padLeft(8, '0');
    }
    return microsHex.substring(microsHex.length - 8);
  }

  /// Recursively sanitizes data structures.
  dynamic _recursiveSanitize(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) {
        final lowerKey = key.toLowerCase();
        if (_sensitiveFields.contains(lowerKey)) {
          return MapEntry(key, '***REDACTED***');
        }
        return MapEntry(key, _recursiveSanitize(value));
      });
    }

    if (data is List) {
      return data.map(_recursiveSanitize).toList();
    }

    return data;
  }
}
