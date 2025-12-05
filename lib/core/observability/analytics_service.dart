import 'package:flutter/widgets.dart';

import 'package:flutter_base_2025/core/observability/app_logger.dart';

/// Abstract interface for analytics tracking.
abstract interface class AnalyticsService {
  /// Initializes the analytics service.
  Future<void> initialize();

  /// Logs a screen view event.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  });

  /// Logs a custom event.
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  /// Sets the user identifier.
  Future<void> setUserId(String userId);

  /// Clears the user identifier.
  Future<void> clearUserId();

  /// Sets a user property.
  Future<void> setUserProperty({
    required String name,
    required String value,
  });

  /// Enables or disables analytics collection.
  Future<void> setAnalyticsCollectionEnabled(bool enabled);
}

/// Console-based analytics for development.
class ConsoleAnalyticsService implements AnalyticsService {
  bool _enabled = true;

  @override
  Future<void> initialize() async {
    AppLogger.instance.info('AnalyticsService initialized (console mode)');
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_enabled) return;
    AppLogger.instance.debug(
      '[ANALYTICS] Screen View: $screenName${screenClass != null ? ' ($screenClass)' : ''}',
    );
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_enabled) return;
    AppLogger.instance.debug(
      '[ANALYTICS] Event: $name${parameters != null ? ' $parameters' : ''}',
    );
  }

  @override
  Future<void> setUserId(String userId) async {
    if (!_enabled) return;
    AppLogger.instance.debug('[ANALYTICS] User ID: $userId');
  }

  @override
  Future<void> clearUserId() async {
    if (!_enabled) return;
    AppLogger.instance.debug('[ANALYTICS] User ID cleared');
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!_enabled) return;
    AppLogger.instance.debug('[ANALYTICS] User Property: $name = $value');
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _enabled = enabled;
    AppLogger.instance.debug('[ANALYTICS] Collection enabled: $enabled');
  }
}

/// Navigator observer for automatic screen tracking.
class AnalyticsNavigatorObserver extends NavigatorObserver {

  AnalyticsNavigatorObserver(this._analytics);
  final AnalyticsService _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackScreen(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackScreen(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackScreen(previousRoute);
    }
  }

  void _trackScreen(Route<dynamic> route) {
    final screenName = route.settings.name ?? 'unknown';
    if (screenName != 'unknown' && !screenName.startsWith('/')) {
      return;
    }
    _analytics.logScreenView(
      screenName: screenName,
      screenClass: route.runtimeType.toString(),
    );
  }
}

/// Singleton instance for global access.
class AnalyticsServiceInstance {
  static AnalyticsService? _instance;

  static AnalyticsService get instance {
    _instance ??= ConsoleAnalyticsService();
    return _instance!;
  }

  static void setInstance(AnalyticsService service) {
    _instance = service;
  }
}
