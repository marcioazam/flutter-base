import 'package:logger/logger.dart';

/// Log severity levels.
enum LogLevel { trace, debug, info, warning, error, fatal }

/// Structured log entry.
class LogEntry {

  LogEntry({
    required this.level,
    required this.message,
    DateTime? timestamp,
    this.correlationId,
    this.context,
    this.error,
    this.stackTrace,
  }) : timestamp = timestamp ?? DateTime.now();
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String? correlationId;
  final Map<String, dynamic>? context;
  final Object? error;
  final StackTrace? stackTrace;

  Map<String, dynamic> toJson() => {
        'level': level.name,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        if (correlationId != null) 'correlationId': correlationId,
        if (context != null) 'context': context,
        if (error != null) 'error': error.toString(),
      };
}

/// Sensitive fields to redact from logs.
const _sensitiveFields = {
  'password',
  'token',
  'accessToken',
  'refreshToken',
  'apiKey',
  'secret',
  'authorization',
  'bearer',
  'credential',
  'ssn',
  'creditCard',
};

/// Structured logger with context and redaction.
class AppLogger {

  AppLogger._({
    Logger? logger,
    String? correlationId,
    Map<String, dynamic>? baseContext,
    bool redactSensitive = true,
  })  : _logger = logger ??
            Logger(
              printer: PrettyPrinter(
                methodCount: 0,
                errorMethodCount: 5,
                lineLength: 80,
              ),
            ),
        _correlationId = correlationId,
        _baseContext = baseContext ?? {},
        _redactSensitive = redactSensitive;
  final Logger _logger;
  final String? _correlationId;
  final Map<String, dynamic> _baseContext;
  final bool _redactSensitive;

  static AppLogger? _instance;

  /// Gets or creates singleton instance.
  static AppLogger get instance {
    _instance ??= AppLogger._();
    return _instance!;
  }

  /// Initializes logger with configuration.
  static void initialize({
    Logger? logger,
    String? correlationId,
    Map<String, dynamic>? baseContext,
    bool redactSensitive = true,
  }) {
    _instance = AppLogger._(
      logger: logger,
      correlationId: correlationId,
      baseContext: baseContext,
      redactSensitive: redactSensitive,
    );
  }

  /// Creates a child logger with additional context.
  AppLogger withContext(Map<String, dynamic> context) => AppLogger._(
      logger: _logger,
      correlationId: _correlationId,
      baseContext: {..._baseContext, ...context},
      redactSensitive: _redactSensitive,
    );

  /// Creates a child logger with correlation ID.
  AppLogger withCorrelationId(String correlationId) => AppLogger._(
      logger: _logger,
      correlationId: correlationId,
      baseContext: _baseContext,
      redactSensitive: _redactSensitive,
    );

  /// Logs trace message.
  void trace(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.trace, message, context: context);
  }

  /// Logs debug message.
  void debug(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.debug, message, context: context);
  }

  /// Logs info message.
  void info(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.info, message, context: context);
  }

  /// Logs warning message.
  void warning(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.warning, message, context: context);
  }

  /// Logs error message.
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _log(
      LogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Logs fatal message.
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _log(
      LogLevel.fatal,
      message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final mergedContext = {..._baseContext, ...?context};
    final redactedContext =
        _redactSensitive ? _redactSensitiveData(mergedContext) : mergedContext;

    final entry = LogEntry(
      level: level,
      message: message,
      correlationId: _correlationId,
      context: redactedContext.isNotEmpty ? redactedContext : null,
      error: error,
      stackTrace: stackTrace,
    );

    final logMessage = _formatMessage(entry);

    switch (level) {
      case LogLevel.trace:
        _logger.t(logMessage);
      case LogLevel.debug:
        _logger.d(logMessage);
      case LogLevel.info:
        _logger.i(logMessage);
      case LogLevel.warning:
        _logger.w(logMessage);
      case LogLevel.error:
        _logger.e(logMessage, error: error, stackTrace: stackTrace);
      case LogLevel.fatal:
        _logger.f(logMessage, error: error, stackTrace: stackTrace);
    }
  }

  String _formatMessage(LogEntry entry) {
    final buffer = StringBuffer(entry.message);

    if (entry.correlationId != null) {
      buffer.write(' [${entry.correlationId}]');
    }

    if (entry.context != null && entry.context!.isNotEmpty) {
      buffer.write(' ${entry.context}');
    }

    return buffer.toString();
  }

  Map<String, dynamic> _redactSensitiveData(Map<String, dynamic> data) => data.map((key, value) {
      if (_isSensitiveKey(key)) {
        return MapEntry(key, '[REDACTED]');
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _redactSensitiveData(value));
      }
      if (value is String && _containsSensitivePattern(value)) {
        return MapEntry(key, '[REDACTED]');
      }
      return MapEntry(key, value);
    });

  bool _isSensitiveKey(String key) {
    final lowerKey = key.toLowerCase();
    return _sensitiveFields.any(lowerKey.contains);
  }

  bool _containsSensitivePattern(String value) {
    // Check for JWT-like patterns
    if (value.startsWith('eyJ') && value.contains('.')) {
      return true;
    }
    // Check for Bearer token
    if (value.toLowerCase().startsWith('bearer ')) {
      return true;
    }
    return false;
  }
}

/// Global logger instance for convenience.
AppLogger get logger => AppLogger.instance;
