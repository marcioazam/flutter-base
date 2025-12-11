/// Breadcrumb for crash reporting.
class Breadcrumb {

  Breadcrumb({
    required this.message,
    required this.category,
    DateTime? timestamp,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();
  final String message;
  final String category;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
}

/// Abstract crash reporter interface.
abstract interface class CrashReporter {
  /// Initializes the crash reporter.
  Future<void> initialize();

  /// Reports an error.
  Future<void> reportError(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
    bool fatal = false,
  });

  /// Adds a breadcrumb for context.
  void addBreadcrumb(Breadcrumb breadcrumb);

  /// Sets user information.
  void setUser({String? id, String? email, String? name});

  /// Clears user information.
  void clearUser();

  /// Sets a custom tag.
  void setTag(String key, String value);

  /// Sets extra context data.
  void setExtra(String key, dynamic value);
}

/// Stub implementation for Sentry crash reporter.
/// Uncomment sentry_flutter in pubspec.yaml to use.
class SentryCrashReporter implements CrashReporter {

  SentryCrashReporter({
    required this.dsn,
    this.environment = 'development',
  });
  final String dsn;
  final String environment;
  final List<Breadcrumb> _breadcrumbs = [];
  final Map<String, String> _tags = {};
  final Map<String, dynamic> _extras = {};

  // User info stored for when Sentry is enabled
  // ignore: unused_field
  String? _userId;
  // ignore: unused_field
  String? _userEmail;
  // ignore: unused_field
  String? _userName;

  @override
  Future<void> initialize() async {
    // TODO: Initialize Sentry when package is enabled
    // await SentryFlutter.init(
    //   (options) {
    //     options.dsn = dsn;
    //     options.environment = environment;
    //     options.tracesSampleRate = 1.0;
    //   },
    // );
  }

  @override
  Future<void> reportError(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
    bool fatal = false,
  }) async {
    // TODO: Report to Sentry when package is enabled
    // await Sentry.captureException(
    //   error,
    //   stackTrace: stackTrace,
    //   withScope: (scope) {
    //     if (context != null) {
    //       scope.setContexts('custom', context);
    //     }
    //     for (final breadcrumb in _breadcrumbs) {
    //       scope.addBreadcrumb(SentryBreadcrumb(
    //         message: breadcrumb.message,
    //         category: breadcrumb.category,
    //         timestamp: breadcrumb.timestamp,
    //         data: breadcrumb.data,
    //       ));
    //     }
    //   },
    // );
  }

  @override
  void addBreadcrumb(Breadcrumb breadcrumb) {
    _breadcrumbs.add(breadcrumb);
    // Keep only last 100 breadcrumbs
    if (_breadcrumbs.length > 100) {
      _breadcrumbs.removeAt(0);
    }
  }

  @override
  void setUser({String? id, String? email, String? name}) {
    _userId = id;
    _userEmail = email;
    _userName = name;
    // TODO: Set Sentry user when package is enabled
    // Sentry.configureScope((scope) {
    //   scope.setUser(SentryUser(id: id, email: email, username: name));
    // });
  }

  @override
  void clearUser() {
    _userId = null;
    _userEmail = null;
    _userName = null;
    // TODO: Clear Sentry user when package is enabled
    // Sentry.configureScope((scope) => scope.setUser(null));
  }

  @override
  void setTag(String key, String value) {
    _tags[key] = value;
    // TODO: Set Sentry tag when package is enabled
    // Sentry.configureScope((scope) => scope.setTag(key, value));
  }

  @override
  void setExtra(String key, dynamic value) {
    _extras[key] = value;
    // TODO: Set Sentry extra when package is enabled
    // Sentry.configureScope((scope) => scope.setExtra(key, value));
  }
}

/// No-op crash reporter for development/testing.
class NoOpCrashReporter implements CrashReporter {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> reportError(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
    bool fatal = false,
  }) async {}

  @override
  void addBreadcrumb(Breadcrumb breadcrumb) {}

  @override
  void setUser({String? id, String? email, String? name}) {}

  @override
  void clearUser() {}

  @override
  void setTag(String key, String value) {}

  @override
  void setExtra(String key, dynamic value) {}
}

/// Singleton wrapper for CrashReporter with Flutter error support.
class CrashReporterService {
  static CrashReporter? _instance;

  static CrashReporter get instance {
    _instance ??= NoOpCrashReporter();
    return _instance!;
  }

  static void setInstance(CrashReporter reporter) {
    _instance = reporter;
  }

  /// Records a Flutter error.
  static Future<void> recordFlutterError(dynamic details) async {
    if (details is Error) {
      await instance.reportError(details, StackTrace.current);
    } else {
      final dynamic rawException = details.exception;
      final Object exception = rawException is Object ? rawException : details as Object;
      final dynamic rawStack = details.stack;
      final StackTrace stack = rawStack is StackTrace ? rawStack : StackTrace.current;
      await instance.reportError(exception, stack);
    }
  }

  /// Records an error with optional fatal flag.
  static Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  }) async {
    await instance.reportError(error, stackTrace, fatal: fatal);
  }
}
