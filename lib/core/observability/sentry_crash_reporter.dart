import 'package:flutter/foundation.dart';

import 'package:flutter_base_2025/core/observability/app_logger.dart';
import 'package:flutter_base_2025/core/observability/crash_reporter.dart';

/// Sentry configuration.
class SentryConfig {
  const SentryConfig({
    required this.dsn,
    required this.environment,
    this.tracesSampleRate = 0.2,
    this.enableAutoSessionTracking = true,
    this.attachStacktrace = true,
    this.inAppIncludes = const [],
  });

  final String dsn;
  final String environment;
  final double tracesSampleRate;
  final bool enableAutoSessionTracking;
  final bool attachStacktrace;
  final List<String> inAppIncludes;
}

/// Sentry crash reporter implementation.
/// Note: Requires sentry_flutter package.
class SentryCrashReporter implements CrashReporter {
  SentryCrashReporter({required this.config});

  final SentryConfig config;
  String? _userId;
  final Map<String, dynamic> _customKeys = {};
  final List<Breadcrumb> _breadcrumbs = [];

  @override
  Future<void> initialize() async {
    AppLogger.instance.info(
      'SentryCrashReporter initialized for ${config.environment}',
    );
  }

  @override
  Future<void> reportError(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
    bool fatal = false,
  }) async {
    final severity = fatal ? 'FATAL' : 'ERROR';
    AppLogger.instance.error(
      '[Sentry $severity] $error',
      error: error,
      stackTrace: stackTrace,
    );
    if (_userId != null) {
      AppLogger.instance.debug('User: $_userId');
    }
  }

  @override
  void addBreadcrumb(Breadcrumb breadcrumb) {
    _breadcrumbs.add(breadcrumb);
    if (_breadcrumbs.length > 100) {
      _breadcrumbs.removeAt(0);
    }
    AppLogger.instance.debug('[Sentry Breadcrumb] ${breadcrumb.message}');
  }

  @override
  void setUser({String? id, String? email, String? name}) {
    _userId = id;
    AppLogger.instance.debug(
      'Sentry: User set - id: $id, email: $email, name: $name',
    );
  }

  @override
  void clearUser() {
    _userId = null;
    AppLogger.instance.debug('Sentry: User cleared');
  }

  @override
  void setTag(String key, String value) {
    AppLogger.instance.debug('[Sentry Tag] $key: $value');
  }

  @override
  void setExtra(String key, dynamic value) {
    _customKeys[key] = value;
    AppLogger.instance.debug('[Sentry Extra] $key: $value');
  }

  /// Records a Flutter error.
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    AppLogger.instance.error(
      '[Sentry FLUTTER] ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
  }

  /// Starts a performance transaction.
  Future<void> startTransaction(String name, String operation) async {
    AppLogger.instance.debug(
      '[Sentry Transaction] Started: $name ($operation)',
    );
  }

  /// Captures a message.
  Future<void> captureMessage(String message, {String level = 'info'}) async {
    AppLogger.instance.info('[Sentry Message] $message');
  }
}

/// Factory to create Sentry crash reporter.
CrashReporter createSentryCrashReporter(SentryConfig config) =>
    SentryCrashReporter(config: config);
