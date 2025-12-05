import 'package:flutter/foundation.dart';

import 'app_logger.dart';
import 'crash_reporter.dart';

/// Sentry configuration.
class SentryConfig {
  final String dsn;
  final String environment;
  final double tracesSampleRate;
  final bool enableAutoSessionTracking;
  final bool attachStacktrace;
  final List<String> inAppIncludes;

  const SentryConfig({
    required this.dsn,
    required this.environment,
    this.tracesSampleRate = 0.2,
    this.enableAutoSessionTracking = true,
    this.attachStacktrace = true,
    this.inAppIncludes = const [],
  });
}

/// Sentry crash reporter implementation.
/// Note: Requires sentry_flutter package.
class SentryCrashReporter implements CrashReporter {
  final SentryConfig config;
  String? _userId;
  final Map<String, dynamic> _customKeys = {};

  SentryCrashReporter({required this.config});

  @override
  Future<void> initialize() async {
    // Placeholder - requires sentry_flutter package
    // await SentryFlutter.init(
    //   (options) {
    //     options.dsn = config.dsn;
    //     options.environment = config.environment;
    //     options.tracesSampleRate = config.tracesSampleRate;
    //     options.enableAutoSessionTracking = config.enableAutoSessionTracking;
    //     options.attachStacktrace = config.attachStacktrace;
    //     options.addInAppInclude('flutter_base_2025');
    //     for (final include in config.inAppIncludes) {
    //       options.addInAppInclude(include);
    //     }
    //   },
    // );

    AppLogger.info('SentryCrashReporter initialized for ${config.environment}');
  }

  @override
  Future<void> setUserId(String userId) async {
    _userId = userId;
    // Placeholder - requires sentry_flutter package
    // Sentry.configureScope((scope) {
    //   scope.setUser(SentryUser(id: userId));
    // });
    AppLogger.debug('Sentry: User ID set to $userId');
  }

  @override
  Future<void> clearUserId() async {
    _userId = null;
    // Placeholder - requires sentry_flutter package
    // Sentry.configureScope((scope) {
    //   scope.setUser(null);
    // });
    AppLogger.debug('Sentry: User ID cleared');
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    // Placeholder - requires sentry_flutter package
    // await Sentry.captureException(
    //   error,
    //   stackTrace: stackTrace,
    //   withScope: (scope) {
    //     if (reason != null) {
    //       scope.setTag('reason', reason);
    //     }
    //     scope.setLevel(fatal ? SentryLevel.fatal : SentryLevel.error);
    //     for (final entry in _customKeys.entries) {
    //       scope.setExtra(entry.key, entry.value);
    //     }
    //   },
    // );

    final severity = fatal ? 'FATAL' : 'ERROR';
    AppLogger.error(
      '[Sentry $severity] ${reason ?? error.toString()}',
      error,
      stackTrace,
    );
    if (_userId != null) {
      AppLogger.debug('User: $_userId');
    }
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    // Placeholder - requires sentry_flutter package
    // await Sentry.captureException(
    //   details.exception,
    //   stackTrace: details.stack,
    //   withScope: (scope) {
    //     scope.setTag('flutter_error', 'true');
    //     scope.setExtra('library', details.library);
    //     scope.setExtra('context', details.context?.toString());
    //   },
    // );

    AppLogger.error(
      '[Sentry FLUTTER] ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
  }

  @override
  Future<void> log(String message) async {
    // Placeholder - requires sentry_flutter package
    // Sentry.addBreadcrumb(Breadcrumb(
    //   message: message,
    //   timestamp: DateTime.now(),
    //   level: SentryLevel.info,
    // ));

    AppLogger.debug('[Sentry Breadcrumb] $message');
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    _customKeys[key] = value;
    // Placeholder - requires sentry_flutter package
    // Sentry.configureScope((scope) {
    //   scope.setExtra(key, value);
    // });
    AppLogger.debug('[Sentry Custom Key] $key: $value');
  }

  @override
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    for (final entry in keys.entries) {
      await setCustomKey(entry.key, entry.value);
    }
  }

  /// Starts a performance transaction.
  Future<void> startTransaction(String name, String operation) async {
    // Placeholder - requires sentry_flutter package
    // final transaction = Sentry.startTransaction(name, operation);
    // return transaction;
    AppLogger.debug('[Sentry Transaction] Started: $name ($operation)');
  }

  /// Captures a message.
  Future<void> captureMessage(
    String message, {
    String level = 'info',
  }) async {
    // Placeholder - requires sentry_flutter package
    // await Sentry.captureMessage(
    //   message,
    //   level: _mapLevel(level),
    // );
    AppLogger.info('[Sentry Message] $message');
  }
}

/// Factory to create Sentry crash reporter.
CrashReporter createSentryCrashReporter(SentryConfig config) {
  return SentryCrashReporter(config: config);
}
