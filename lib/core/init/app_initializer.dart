import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../config/app_config.dart';
import '../observability/analytics_service.dart';
import '../observability/app_logger.dart';
import '../observability/crash_reporter.dart';
import '../observability/feature_flags.dart';

/// Initialization step with name and action.
typedef InitStep = ({String name, Future<void> Function() action});

/// Result of app initialization.
sealed class InitResult {
  const InitResult();
}

/// Initialization succeeded.
final class InitSuccess extends InitResult {
  final Duration duration;
  const InitSuccess(this.duration);
}

/// Initialization failed.
final class InitFailure extends InitResult {
  final String step;
  final Object error;
  final StackTrace stackTrace;
  const InitFailure(this.step, this.error, this.stackTrace);

  /// Returns user-friendly error message for production.
  String get userMessage {
    if (AppConfig.instance.isProduction) {
      return 'Unable to start the app. Please try again later.';
    }
    return 'Initialization failed at $step: $error';
  }
}

/// App initializer that handles startup sequence.
class AppInitializer {
  final Flavor flavor;
  final void Function(String step, double progress)? onProgress;

  AppInitializer({
    required this.flavor,
    this.onProgress,
  });

  /// Initializes the app with all required services.
  Future<InitResult> initialize() async {
    final stopwatch = Stopwatch()..start();

    final steps = _buildSteps();
    var currentStep = 0;

    for (final step in steps) {
      try {
        onProgress?.call(step.name, currentStep / steps.length);
        await step.action();
        currentStep++;
      } catch (e, st) {
        stopwatch.stop();
        // Only log detailed errors in non-production
        if (flavor != Flavor.production) {
          AppLogger.instance.error(
            'Init failed at ${step.name}',
            error: e,
            stackTrace: st,
          );
        }
        return InitFailure(step.name, e, st);
      }
    }

    stopwatch.stop();
    AppLogger.instance.info('App initialized in ${stopwatch.elapsedMilliseconds}ms');
    return InitSuccess(stopwatch.elapsed);
  }

  List<InitStep> _buildSteps() => [
        (
          name: 'Config',
          action: () => AppConfig.initialize(flavor),
        ),
        (
          name: 'Logger',
          action: () async => _initializeLogger(),
        ),
        (
          name: 'CrashReporter',
          action: () => CrashReporterService.instance.initialize(),
        ),
        (
          name: 'Analytics',
          action: () => AnalyticsServiceInstance.instance.initialize(),
        ),
        (
          name: 'FeatureFlags',
          action: () => FeatureFlagsService.instance.initialize(),
        ),
      ];

  /// Initializes logger with production-appropriate settings.
  void _initializeLogger() {
    AppLogger.initialize(
      redactSensitive: true,
      baseContext: {
        'flavor': flavor.name,
        'version': '1.0.0',
      },
    );
  }

  /// Sets up global error handling with production-safe messages.
  static void setupErrorHandling() {
    FlutterError.onError = (details) {
      // In production, don't show detailed error UI
      if (!AppConfig.instance.isProduction) {
        FlutterError.presentError(details);
      }
      CrashReporterService.instance.recordFlutterError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      CrashReporterService.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Preserves native splash screen.
  static WidgetsBinding preserveSplash() {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: binding);
    return binding;
  }

  /// Removes native splash screen.
  static void removeSplash() {
    FlutterNativeSplash.remove();
  }
}

/// Runs app with error zone and production-safe error handling.
Future<void> runAppWithErrorHandling(
  FutureOr<void> Function() appRunner,
) async {
  await runZonedGuarded(
    () async {
      AppInitializer.setupErrorHandling();
      await appRunner();
    },
    (error, stack) {
      // Report to crash service
      CrashReporterService.instance.recordError(error, stack);
      
      // Only log details in non-production
      if (!AppConfig.instance.isProduction) {
        AppLogger.instance.error(
          'Unhandled error',
          error: error,
          stackTrace: stack,
        );
      }
    },
  );
}

/// Production-safe error message helper.
String getProductionSafeErrorMessage(Object error) {
  if (AppConfig.instance.isProduction) {
    return 'Something went wrong. Please try again.';
  }
  return error.toString();
}
