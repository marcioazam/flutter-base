import 'package:flutter_base_2025/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: flutter-modernization-2025, Property 15: Flavor Config Isolation**
/// **Validates: Requirements 18.1, 18.3**
void main() {
  group('Flavor Config Isolation Properties', () {
    test('Development flavor has correct configuration', () async {
      await AppConfig.initialize(Flavor.development);
      final config = AppConfig.instance;

      expect(config.flavor, equals(Flavor.development));
      expect(config.isDevelopment, isTrue);
      expect(config.isStaging, isFalse);
      expect(config.isProduction, isFalse);
      expect(config.enableLogging, isTrue);
      expect(config.showDebugBanner, isTrue);
    });

    test('Staging flavor has correct configuration', () async {
      await AppConfig.initialize(Flavor.staging);
      final config = AppConfig.instance;

      expect(config.flavor, equals(Flavor.staging));
      expect(config.isDevelopment, isFalse);
      expect(config.isStaging, isTrue);
      expect(config.isProduction, isFalse);
      expect(config.enableLogging, isTrue);
      expect(config.showDebugBanner, isTrue);
    });

    test('Production flavor has correct configuration', () async {
      await AppConfig.initialize(Flavor.production);
      final config = AppConfig.instance;

      expect(config.flavor, equals(Flavor.production));
      expect(config.isDevelopment, isFalse);
      expect(config.isStaging, isFalse);
      expect(config.isProduction, isTrue);
      expect(config.enableLogging, isFalse);
      expect(config.showDebugBanner, isFalse);
    });

    test('Each flavor has distinct API base URL', () async {
      await AppConfig.initialize(Flavor.development);
      final devUrl = AppConfig.instance.apiBaseUrl;

      await AppConfig.initialize(Flavor.staging);
      final stagingUrl = AppConfig.instance.apiBaseUrl;

      await AppConfig.initialize(Flavor.production);
      final prodUrl = AppConfig.instance.apiBaseUrl;

      expect(devUrl, isNot(equals(stagingUrl)));
      expect(stagingUrl, isNot(equals(prodUrl)));
      expect(devUrl, isNot(equals(prodUrl)));
    });

    test('Each flavor has distinct app name', () async {
      await AppConfig.initialize(Flavor.development);
      final devName = AppConfig.instance.appName;

      await AppConfig.initialize(Flavor.staging);
      final stagingName = AppConfig.instance.appName;

      await AppConfig.initialize(Flavor.production);
      final prodName = AppConfig.instance.appName;

      expect(devName, contains('Dev'));
      expect(stagingName, contains('Staging'));
      expect(prodName, isNot(contains('Dev')));
      expect(prodName, isNot(contains('Staging')));
    });

    test('Flavor enum has all expected values', () {
      expect(Flavor.values, hasLength(3));
      expect(Flavor.values, contains(Flavor.development));
      expect(Flavor.values, contains(Flavor.staging));
      expect(Flavor.values, contains(Flavor.production));
    });
  });
}
