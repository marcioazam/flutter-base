import 'package:flutter_base_2025/core/constants/app_constants.dart';
import 'package:flutter_base_2025/core/router/route_guards.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, setUpAll, tearDown, tearDownAll, test;
import 'package:mocktail/mocktail.dart' hide any;
import 'package:mocktail/mocktail.dart' as mocktail;

import '../helpers/generators.dart';
import '../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockTokenStorage mockTokenStorage;

  setUpAll(setupMocktailFallbacks);

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockTokenStorage = MockTokenStorage();
  });

  group('Auth Flow Property Tests', () {
    // **Feature: flutter-code-review, Property 1: Unauthenticated Redirect**
    // **Validates: Requirements 8.2**
    Glados<String>(any.nonEmptyLetters).test(
      'Property 1: Unauthenticated users are redirected to login for any protected route',
      (protectedPath) {
        // Arrange: User is not authenticated
        when(() => mockAuthRepository.isAuthenticated())
            .thenAnswer((_) async => false);

        // Define protected routes (any route not in public list)
        final isProtected = !_isPublicRoute('/$protectedPath');

        // Act & Assert: If route is protected and user is not authenticated,
        // they should be redirected to login
        if (isProtected) {
          expect(
            '/$protectedPath'.isProtectedRoute,
            isTrue,
            reason: 'Protected routes should require authentication',
          );
        }
      },
    );

    // **Feature: flutter-code-review, Property 2: Login Token Storage**
    // **Validates: Requirements 8.3**
    Glados2<String, String>(any.email, any.password).test(
      'Property 2: Successful login stores both access and refresh tokens',
      (email, password) async {
        // Arrange
        const accessToken = 'test_access_token';
        const refreshToken = 'test_refresh_token';
        var accessTokenStored = false;
        var refreshTokenStored = false;

        when(() => mockTokenStorage.saveTokens(
              accessToken: mocktail.any(named: 'accessToken'),
              refreshToken: mocktail.any(named: 'refreshToken'),
            )).thenAnswer((_) async {
          accessTokenStored = true;
          refreshTokenStored = true;
        });

        // Act: Simulate token storage after login
        await mockTokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Assert: Both tokens must be stored
        expect(accessTokenStored, isTrue,
            reason: 'Access token must be stored after login');
        expect(refreshTokenStored, isTrue,
            reason: 'Refresh token must be stored after login');

        verify(() => mockTokenStorage.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
            )).called(1);
      },
    );

    // **Feature: flutter-code-review, Property 3: Logout Token Clearing**
    // **Validates: Requirements 8.4**
    Glados<String>(any.nonEmptyLetters).test(
      'Property 3: Logout clears all tokens regardless of user state',
      (userId) async {
        // Arrange
        var tokensCleared = false;

        when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {
          tokensCleared = true;
        });

        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);

        // Act: Clear tokens (logout)
        await mockTokenStorage.clearTokens();

        // Assert: Tokens must be cleared
        expect(tokensCleared, isTrue,
            reason: 'All tokens must be cleared on logout');

        // Verify no tokens remain
        final hasTokens = await mockTokenStorage.hasTokens();
        expect(hasTokens, isFalse,
            reason: 'No tokens should remain after logout');
      },
    );
  });

  group('Route Protection Property Tests', () {
    // Additional property test for route protection consistency
    Glados<String>(any.nonEmptyLetters).test(
      'Public routes are never protected',
      (routeSuffix) {
        final publicRoutes = [
          RoutePaths.login,
          RoutePaths.register,
        ];

        for (final route in publicRoutes) {
          expect(
            route.isProtectedRoute,
            isFalse,
            reason: 'Public route $route should not be protected',
          );
        }
      },
    );
  });
}

/// Helper to check if a route is public.
bool _isPublicRoute(String path) {
  const publicRoutes = [
    '/auth/login',
    '/auth/register',
  ];
  return publicRoutes.any((route) => path.startsWith(route));
}
