import 'package:flutter_base_2025/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-modernization-2025, Property 10: Deep Link Navigation Resolution**
/// **Validates: Requirements 23.1**

void main() {
  group('Deep Link Navigation Resolution Properties', () {
    test('buildUri creates valid URI with scheme and host', () {
      final uri = DeepLinks.buildUri('/home');

      expect(uri.scheme, equals(DeepLinks.scheme));
      expect(uri.host, equals(DeepLinks.host));
      expect(uri.path, equals('/home'));
    });

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'buildUri preserves path',
      (path) {
        final validPath = '/${path.replaceAll(RegExp(r'[^\w/]'), '_')}';
        final uri = DeepLinks.buildUri(validPath);

        expect(uri.path, equals(validPath));
      },
    );

    test('parseDeepLink extracts path from valid URI', () {
      final uri = Uri(
        scheme: DeepLinks.scheme,
        host: DeepLinks.host,
        path: '/settings',
      );

      final path = DeepLinks.parseDeepLink(uri);

      expect(path, equals('/settings'));
    });

    test('parseDeepLink returns null for invalid scheme', () {
      final uri = Uri(
        scheme: 'https',
        host: DeepLinks.host,
        path: '/home',
      );

      final path = DeepLinks.parseDeepLink(uri);

      expect(path, isNull);
    });

    test('parseDeepLink returns null for invalid host', () {
      final uri = Uri(
        scheme: DeepLinks.scheme,
        host: 'wrong-host',
        path: '/home',
      );

      final path = DeepLinks.parseDeepLink(uri);

      expect(path, isNull);
    });

    test('round-trip: buildUri then parseDeepLink preserves path', () {
      const originalPath = '/profile/123';
      final uri = DeepLinks.buildUri(originalPath);
      final parsedPath = DeepLinks.parseDeepLink(uri);

      expect(parsedPath, equals(originalPath));
    });

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'round-trip preserves any valid path',
      (path) {
        final validPath = '/${path.replaceAll(RegExp(r'[^\w/]'), '_')}';
        final uri = DeepLinks.buildUri(validPath);
        final parsedPath = DeepLinks.parseDeepLink(uri);

        expect(parsedPath, equals(validPath));
      },
    );

    test('deep link with query parameters', () {
      final uri = Uri(
        scheme: DeepLinks.scheme,
        host: DeepLinks.host,
        path: '/product',
        queryParameters: {'id': '123', 'ref': 'home'},
      );

      expect(uri.queryParameters['id'], equals('123'));
      expect(uri.queryParameters['ref'], equals('home'));
    });

    test('deep link scheme constant is correct', () {
      expect(DeepLinks.scheme, equals('flutterbase'));
    });

    test('deep link host constant is correct', () {
      expect(DeepLinks.host, equals('app'));
    });

    group('Path patterns', () {
      test('home path', () {
        final uri = DeepLinks.buildUri('/home');
        expect(DeepLinks.parseDeepLink(uri), equals('/home'));
      });

      test('settings path', () {
        final uri = DeepLinks.buildUri('/settings');
        expect(DeepLinks.parseDeepLink(uri), equals('/settings'));
      });

      test('profile path', () {
        final uri = DeepLinks.buildUri('/profile');
        expect(DeepLinks.parseDeepLink(uri), equals('/profile'));
      });

      test('nested path', () {
        final uri = DeepLinks.buildUri('/settings/notifications');
        expect(DeepLinks.parseDeepLink(uri), equals('/settings/notifications'));
      });

      test('path with id parameter', () {
        final uri = DeepLinks.buildUri('/user/12345');
        expect(DeepLinks.parseDeepLink(uri), equals('/user/12345'));
      });
    });
  });
}
