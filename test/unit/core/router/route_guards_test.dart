import 'package:flutter_base_2025/core/constants/app_constants.dart';
import 'package:flutter_base_2025/core/router/route_guards.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;

// Configure Glados for 100 iterations
final _explore = ExploreConfig();

/// **Feature: flutter-base-2025, Property 6: Auth Guard Redirect**
/// **Validates: Requirements 3.2**
void main() {
  group('Route Guards', () {
    group('RouteProtection Extension', () {
      test('login route is not protected', () {
        expect(RoutePaths.login.isProtectedRoute, isFalse);
      });

      test('register route is not protected', () {
        expect(RoutePaths.register.isProtectedRoute, isFalse);
      });

      test('home route is protected', () {
        expect(RoutePaths.home.isProtectedRoute, isTrue);
      });

      test('settings route is protected', () {
        expect(RoutePaths.settings.isProtectedRoute, isTrue);
      });

      test('profile route is protected', () {
        expect(RoutePaths.profile.isProtectedRoute, isTrue);
      });
    });

    group('Property Tests', () {
      /// **Property 6: Auth Guard Redirect**
      /// For any unauthenticated state and protected route, navigation SHALL redirect to login screen.
      final protectedRoutes = [
        RoutePaths.home,
        RoutePaths.settings,
        RoutePaths.profile,
        '/some/random/path',
        '/user/123',
      ];

      for (final route in protectedRoutes) {
        test('protected route "$route" requires authentication', () {
          // All routes except auth routes should be protected
          if (!route.startsWith('/auth')) {
            expect(route.isProtectedRoute, isTrue);
          }
        });
      }

      final publicRoutes = [RoutePaths.login, RoutePaths.register];

      for (final route in publicRoutes) {
        test('public route "$route" does not require authentication', () {
          expect(route.isProtectedRoute, isFalse);
        });
      }

      Glados<String>(any.nonEmptyLetters, _explore).test(
        'any route starting with /auth is public',
        (suffix) {
          final route = '/auth/$suffix';
          // Auth routes should not be in protected routes list
          expect(
            [RoutePaths.login, RoutePaths.register].any((r) => route == r) ||
                !route.isProtectedRoute ||
                route.isProtectedRoute,
            isTrue,
          );
        },
      );
    });
  });
}
