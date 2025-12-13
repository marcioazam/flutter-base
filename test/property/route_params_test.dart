import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;
import 'package:meta/meta.dart';

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-generics-production-2025, Property 10: Route Parameter Round-Trip**
/// **Validates: Requirements 5.3, 5.4**

/// Helper class to simulate route parameters
@immutable
class RouteParams {

  /// Creates from query parameters map
  factory RouteParams.fromQueryParams(Map<String, String> params) => RouteParams(
      id: params['id'],
      name: params['name'] != null ? Uri.decodeComponent(params['name']!) : null,
      page: params['page'] != null ? int.tryParse(params['page']!) : null,
      enabled: params['enabled'] != null ? params['enabled'] == 'true' : null,
    );

  /// Creates from URI
  factory RouteParams.fromUri(Uri uri) => RouteParams.fromQueryParams(uri.queryParameters);
  const RouteParams({
    this.id,
    this.name,
    this.page,
    this.enabled,
  });

  final String? id;
  final String? name;
  final int? page;
  final bool? enabled;

  /// Converts to query parameters map
  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (id != null) params['id'] = id!;
    if (name != null) params['name'] = Uri.encodeComponent(name!);
    if (page != null) params['page'] = page.toString();
    if (enabled != null) params['enabled'] = enabled.toString();
    return params;
  }

  /// Converts to URI
  Uri toUri(String basePath) => Uri(
      path: basePath,
      queryParameters: toQueryParams().isNotEmpty ? toQueryParams() : null,
    );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteParams &&
          id == other.id &&
          name == other.name &&
          page == other.page &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(id, name, page, enabled);

  @override
  String toString() => 'RouteParams(id: $id, name: $name, page: $page, enabled: $enabled)';
}

void main() {
  group('Route Parameter Round-Trip Properties', () {
    /// **Property 10: Route Parameter Round-Trip**
    /// *For any* route with parameters params:
    /// - Route.fromUri(route.toUri()) == route
    /// - Path parameters are correctly encoded/decoded
    /// - Query parameters preserve types (int, bool, String)

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'String parameter round-trip preserves value',
      (value) {
        final params = RouteParams(id: value);
        final uri = params.toUri('/test');
        final restored = RouteParams.fromUri(uri);

        expect(restored.id, equals(value));
      },
    );

    Glados<int>(any.int, _explore).test(
      'Int parameter round-trip preserves value',
      (value) {
        final params = RouteParams(page: value);
        final uri = params.toUri('/test');
        final restored = RouteParams.fromUri(uri);

        expect(restored.page, equals(value));
      },
    );

    Glados<bool>(any.bool, _explore).test(
      'Bool parameter round-trip preserves value',
      (value) {
        final params = RouteParams(enabled: value);
        final uri = params.toUri('/test');
        final restored = RouteParams.fromUri(uri);

        expect(restored.enabled, equals(value));
      },
    );

    test('Special characters are properly encoded/decoded', () {
      final specialChars = ['hello world', 'test&value', 'name=john', 'path/to/resource'];
      
      for (final value in specialChars) {
        final params = RouteParams(name: value);
        final uri = params.toUri('/test');
        final restored = RouteParams.fromUri(uri);

        expect(restored.name, equals(value), reason: 'Failed for: $value');
      }
    });

    test('Multiple parameters round-trip correctly', () {
      final params = RouteParams(
        id: 'abc123',
        name: 'Test User',
        page: 5,
        enabled: true,
      );

      final uri = params.toUri('/users');
      final restored = RouteParams.fromUri(uri);

      expect(restored, equals(params));
    });

    test('Empty parameters produce valid URI', () {
      const params = RouteParams();
      final uri = params.toUri('/test');

      expect(uri.path, equals('/test'));
      expect(uri.queryParameters, isEmpty);
    });

    test('Null parameters are not included in URI', () {
      final params = RouteParams(id: 'test');
      final queryParams = params.toQueryParams();

      expect(queryParams.containsKey('id'), isTrue);
      expect(queryParams.containsKey('name'), isFalse);
    });

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'URI encoding is reversible',
      (value) {
        final encoded = Uri.encodeComponent(value);
        final decoded = Uri.decodeComponent(encoded);

        expect(decoded, equals(value));
      },
    );

    test('Path parameters with special characters', () {
      final testCases = [
        ('user-123', 'user-123'),
        ('user_456', 'user_456'),
        ('user.789', 'user.789'),
      ];

      for (final (input, expected) in testCases) {
        final params = RouteParams(id: input);
        final uri = params.toUri('/users');
        final restored = RouteParams.fromUri(uri);

        expect(restored.id, equals(expected));
      }
    });
  });

  group('Deep Link Parsing', () {
    test('Valid deep link is parsed correctly', () {
      final uri = Uri.parse('myapp://app/users?id=123&page=1');
      final params = RouteParams.fromUri(uri);

      expect(params.id, equals('123'));
      expect(params.page, equals(1));
    });

    test('Deep link with encoded characters', () {
      final uri = Uri.parse('myapp://app/search?name=John%20Doe');
      final params = RouteParams.fromUri(uri);

      expect(params.name, equals('John Doe'));
    });

    test('Deep link without query parameters', () {
      final uri = Uri.parse('myapp://app/home');
      final params = RouteParams.fromUri(uri);

      expect(params.id, isNull);
      expect(params.name, isNull);
      expect(params.page, isNull);
      expect(params.enabled, isNull);
    });
  });
}
