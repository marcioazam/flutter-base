abstract final class AppConstants {
  static const String appName = 'Flutter Base 2025';
  static const String apiBaseUrl = 'https://api.example.com';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
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
