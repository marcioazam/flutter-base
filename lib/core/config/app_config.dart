import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App configuration provider.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.instance);

/// Flavor enum for different environments.
enum Flavor { development, staging, production }

/// Configuration validation errors.
class ConfigValidationError implements Exception {

  ConfigValidationError(this.message, {this.missingKeys = const []});
  final String message;
  final List<String> missingKeys;

  @override
  String toString() => 'ConfigValidationError: $message';
}

/// Application configuration based on flavor/environment.
class AppConfig {

  AppConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
    required this.showDebugBanner,
    required this.enableAnalytics,
    required this.enableCrashReporting,
  });
  final Flavor flavor;
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;
  final bool showDebugBanner;
  final bool enableAnalytics;
  final bool enableCrashReporting;

  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  /// Required environment keys.
  static const _requiredKeys = ['API_BASE_URL', 'APP_NAME'];

  /// Initializes config from environment with validation.
  static Future<void> initialize(Flavor flavor) async {
    var envLoaded = false;
    try {
      await dotenv.load(fileName: _envFileName(flavor));
      envLoaded = true;
      // Validate required keys only if env file was loaded
      _validateEnvironment();
    } catch (e) {
      // Fallback to defaults if env file not found (useful for tests)
      assert(() {
        // ignore: avoid_print
        print('AppConfig: Using defaults, env file not loaded: $e');
        return true;
      }());
    }
    
    _instance = AppConfig._(
      flavor: flavor,
      apiBaseUrl: envLoaded ? (dotenv.env['API_BASE_URL'] ?? _defaultApiUrl(flavor)) : _defaultApiUrl(flavor),
      appName: envLoaded ? (dotenv.env['APP_NAME'] ?? _defaultAppName(flavor)) : _defaultAppName(flavor),
      enableLogging: flavor != Flavor.production,
      showDebugBanner: flavor != Flavor.production,
      enableAnalytics: envLoaded 
          ? _parseBool(dotenv.env['ENABLE_ANALYTICS'], defaultValue: flavor != Flavor.development)
          : flavor != Flavor.development,
      enableCrashReporting: envLoaded 
          ? _parseBool(dotenv.env['ENABLE_CRASH_REPORTING'], defaultValue: flavor != Flavor.development)
          : flavor != Flavor.development,
    );
  }

  /// Validates environment configuration on startup.
  static void _validateEnvironment() {
    final missingKeys = <String>[];
    
    for (final key in _requiredKeys) {
      if (dotenv.env[key] == null || dotenv.env[key]!.isEmpty) {
        missingKeys.add(key);
      }
    }
    
    if (missingKeys.isNotEmpty) {
      throw ConfigValidationError(
        'Missing required environment variables: ${missingKeys.join(", ")}',
        missingKeys: missingKeys,
      );
    }
    
    // Validate API URL format
    final apiUrl = dotenv.env['API_BASE_URL'];
    if (apiUrl != null && !_isValidUrl(apiUrl)) {
      throw ConfigValidationError('Invalid API_BASE_URL format: $apiUrl');
    }
  }

  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  static bool _parseBool(String? value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true' || value == '1';
  }

  static String _envFileName(Flavor flavor) => switch (flavor) {
        Flavor.development => '.env.development',
        Flavor.staging => '.env.staging',
        Flavor.production => '.env.production',
      };

  static String _defaultApiUrl(Flavor flavor) => switch (flavor) {
        Flavor.development => 'http://localhost:8000/api/v1',
        Flavor.staging => 'https://staging-api.example.com/api/v1',
        Flavor.production => 'https://api.example.com/api/v1',
      };

  static String _defaultAppName(Flavor flavor) => switch (flavor) {
        Flavor.development => 'App Dev',
        Flavor.staging => 'App Staging',
        Flavor.production => 'App',
      };

  bool get isDevelopment => flavor == Flavor.development;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProduction => flavor == Flavor.production;
}
