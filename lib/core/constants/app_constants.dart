abstract final class AppConstants {
  static const String appName = 'Flutter Base 2025';

  // Note: Use AppConfig.apiBaseUrl for environment-specific URLs
  // static const String apiBaseUrl - REMOVED (use AppConfig instead)

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Note: Use RetryConfig for retry settings
  // static const int maxRetryAttempts - REMOVED (use RetryConfig instead)
  // static const Duration retryDelay - REMOVED (use RetryConfig instead)

  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'pt'];
}

abstract final class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
}

abstract final class RouteNames {
  static const String home = 'home';
  static const String login = 'login';
  static const String register = 'register';
  static const String settings = 'settings';
  static const String profile = 'profile';
}

abstract final class RoutePaths {
  static const String home = '/';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String settings = '/settings';
  static const String profile = '/profile';
}
