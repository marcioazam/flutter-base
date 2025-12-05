import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/app_constants.dart';

/// Route guard for authentication-based redirects.
class RouteGuard {
  final Ref _ref;

  /// Stores the original deep link path for redirect after login.
  String? _pendingDeepLink;

  RouteGuard(this._ref);

  /// Gets and clears the pending deep link.
  String? consumePendingDeepLink() {
    final link = _pendingDeepLink;
    _pendingDeepLink = null;
    return link;
  }

  /// Redirect logic for authentication.
  String? redirect(_, GoRouterState state) {
    final authState = _ref.read(authStateProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final currentPath = state.matchedLocation;
    final queryParams = state.uri.queryParameters;

    // Define auth routes
    final isAuthRoute = _isAuthRoute(currentPath);

    // If not authenticated and trying to access protected route
    if (!isAuthenticated && !isAuthRoute) {
      // Store the original path for redirect after login
      _pendingDeepLink = currentPath;
      
      // Include redirect parameter in login URL
      return Uri(
        path: RoutePaths.login,
        queryParameters: {'redirect': currentPath},
      ).toString();
    }

    // If authenticated and trying to access auth route
    if (isAuthenticated && isAuthRoute) {
      // Check for redirect parameter or pending deep link
      final redirectTo = queryParams['redirect'] ?? consumePendingDeepLink();
      if (redirectTo != null && !_isAuthRoute(redirectTo)) {
        return redirectTo;
      }
      return RoutePaths.home;
    }

    // No redirect needed
    return null;
  }

  bool _isAuthRoute(String path) {
    return path.startsWith('/auth') || 
           path == RoutePaths.login || 
           path == RoutePaths.register;
  }
}

/// Provider for route guard.
final routeGuardProvider = Provider<RouteGuard>((ref) {
  return RouteGuard(ref);
});

/// Extension for checking route protection.
extension RouteProtection on String {
  bool get isProtectedRoute {
    const publicRoutes = [
      RoutePaths.login,
      RoutePaths.register,
    ];
    return !publicRoutes.contains(this);
  }
}
