import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/widgets/main_shell.dart';
import '../constants/app_constants.dart';
import 'route_guards.dart';

/// Provider for GoRouter instance.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final routeGuard = RouteGuard(ref);

  return GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authState),
    redirect: routeGuard.redirect,
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const LoginPage(isRegister: true),
      ),

      // Main app routes (with shell for bottom navigation)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.settings,
            name: RouteNames.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(), // Placeholder
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

/// Stream that notifies GoRouter when auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(AsyncValue<AuthState> authState) {
    notifyListeners();
  }
}

/// Deep link configuration.
abstract final class DeepLinks {
  static const String scheme = 'flutterbase';
  static const String host = 'app';

  static Uri buildUri(String path) => Uri(
        scheme: scheme,
        host: host,
        path: path,
      );

  static String? parseDeepLink(Uri uri) {
    if (uri.scheme == scheme && uri.host == host) {
      return uri.path;
    }
    return null;
  }
}
