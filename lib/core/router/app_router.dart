import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_base_2025/core/constants/app_constants.dart';
import 'package:flutter_base_2025/core/router/route_guards.dart';
import 'package:flutter_base_2025/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_base_2025/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_base_2025/features/home/presentation/pages/home_page.dart';
import 'package:flutter_base_2025/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_base_2025/shared/widgets/main_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provider for GoRouter instance.
final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state changes to trigger router refresh
  ref.watch(authStateProvider);
  final routeGuard = RouteGuard(ref);

  // Create a simple notifier that triggers on auth changes
  final refreshNotifier = _RouterRefreshNotifier();
  ref.listen(authStateProvider, (_, __) => refreshNotifier.notify());

  return GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
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

/// Simple notifier for GoRouter refresh.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Stream that notifies GoRouter when auth state changes.
/// @deprecated Use _RouterRefreshNotifier instead
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream([Stream<dynamic>? stream]) {
    notifyListeners();
    if (stream != null) {
      _subscription = stream.asBroadcastStream().listen((_) {
        notifyListeners();
      });
    }
  }

  StreamSubscription<dynamic>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
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
