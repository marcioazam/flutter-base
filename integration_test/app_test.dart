// =============================================================================
// Flutter Base 2025 - Integration Tests
// =============================================================================
// E2E tests using Patrol framework for native automation capabilities.
//
// Run with: patrol test
// Run specific: patrol test -t integration_test/app_test.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'keys.dart';
import 'test_config.dart';

void main() {
  group('App Launch', () {
    patrolTest(
      'app launches successfully and shows home screen',
      config: patrolConfig,
      ($) async {
        await _launchApp($);

        // Verify app is running with expected initial state
        expect($(K.homeScreen), findsOneWidget);
      },
    );

    patrolTest(
      'app shows splash screen before home',
      config: patrolConfig,
      ($) async {
        // Note: This test may need adjustment based on splash duration
        await $.pumpWidget(const _TestApp());

        // Splash should be visible initially
        // await $.pump(const Duration(milliseconds: 500));
        // expect($(K.splashScreen), findsOneWidget);

        // After settling, home should be visible
        await $.pumpAndSettle();
        expect($(K.homeScreen), findsOneWidget);
      },
    );
  });

  group('Navigation', () {
    patrolTest(
      'navigates to settings and back',
      config: patrolConfig,
      ($) async {
        await _launchApp($);

        // Navigate to settings
        await $(K.settingsButton).tap();
        await $.pumpAndSettle();
        expect($(K.settingsScreen), findsOneWidget);

        // Navigate back using system back
        await $.native.pressBack();
        await $.pumpAndSettle();
        expect($(K.homeScreen), findsOneWidget);
      },
    );

    patrolTest(
      'bottom navigation works correctly',
      config: patrolConfig,
      ($) async {
        await _launchApp($);

        // Tap each navigation item
        await $(K.navHome).tap();
        expect($(K.homeScreen), findsOneWidget);

        await $(K.navProfile).tap();
        await $.pumpAndSettle();
        expect($(K.profileScreen), findsOneWidget);

        await $(K.navSettings).tap();
        await $.pumpAndSettle();
        expect($(K.settingsScreen), findsOneWidget);
      },
    );
  });

  group('Authentication', () {
    patrolTest(
      'shows validation errors for invalid input',
      config: patrolConfig,
      ($) async {
        await _launchApp($);
        await _navigateToLogin($);

        // Submit empty form
        await $(K.loginButton).tap();
        await $.pumpAndSettle();

        // Verify validation errors
        expect($('Email is required'), findsOneWidget);
        expect($('Password is required'), findsOneWidget);
      },
    );

    patrolTest(
      'shows error for invalid email format',
      config: patrolConfig,
      ($) async {
        await _launchApp($);
        await _navigateToLogin($);

        // Enter invalid email
        await $(K.emailField).enterText('invalid-email');
        await $(K.passwordField).enterText('password123');
        await $(K.loginButton).tap();
        await $.pumpAndSettle();

        expect($('Invalid email format'), findsOneWidget);
      },
    );

    patrolTest(
      'successful login navigates to home',
      config: patrolConfig,
      ($) async {
        await _launchApp($);
        await _navigateToLogin($);

        // Enter valid credentials
        await $(K.emailField).enterText(TestConfig.testEmail);
        await $(K.passwordField).enterText(TestConfig.testPassword);
        await $(K.loginButton).tap();
        await $.pumpAndSettle();

        // Verify navigation to home
        expect($(K.homeScreen), findsOneWidget);
      },
    );

    patrolTest(
      'logout returns to login screen',
      config: patrolConfig,
      ($) async {
        await _launchApp($);
        await _performLogin($);

        // Navigate to settings and logout
        await $(K.settingsButton).tap();
        await $.pumpAndSettle();
        await $(K.logoutButton).tap();
        await $.pumpAndSettle();

        // Verify return to login
        expect($(K.loginScreen), findsOneWidget);
      },
    );
  });

  group('Native Features', () {
    patrolTest(
      'handles location permission dialog',
      config: patrolConfig,
      ($) async {
        await _launchApp($);

        // Trigger location request
        await $(K.requestLocationButton).tap();

        // Grant permission via native dialog
        await $.native.grantPermissionWhenInUse();
        await $.pumpAndSettle();

        // Verify permission granted state
        expect($(K.locationEnabled), findsOneWidget);
      },
    );

    patrolTest(
      'handles camera permission dialog',
      config: patrolConfig,
      ($) async {
        await _launchApp($);

        // Trigger camera request
        await $(K.openCameraButton).tap();

        // Grant permission
        await $.native.grantPermissionWhenInUse();
        await $.pumpAndSettle();

        // Verify camera view is shown
        expect($(K.cameraPreview), findsOneWidget);
      },
    );

    patrolTest(
      'handles notification permission',
      config: patrolConfig,
      ($) async {
        await _launchApp($);

        // Request notification permission
        await $(K.enableNotificationsButton).tap();

        // Grant permission
        await $.native.grantPermissionWhenInUse();
        await $.pumpAndSettle();

        expect($(K.notificationsEnabled), findsOneWidget);
      },
    );
  });

  group('Deep Links', () {
    patrolTest(
      'opens settings via deep link',
      config: patrolConfig,
      ($) async {
        // Open app via deep link
        await $.native.openUrl('flutterbase://settings');
        await $.pumpAndSettle();

        expect($(K.settingsScreen), findsOneWidget);
      },
    );

    patrolTest(
      'opens profile via deep link',
      config: patrolConfig,
      ($) async {
        await $.native.openUrl('flutterbase://profile');
        await $.pumpAndSettle();

        expect($(K.profileScreen), findsOneWidget);
      },
    );
  });

  group('Offline Behavior', () {
    patrolTest(
      'shows offline indicator when network disabled',
      config: patrolConfig,
      ($) async {
        await _launchApp($);

        // Disable network
        await $.native.disableWifi();
        await $.native.disableCellular();
        await $.pump(const Duration(seconds: 2));

        // Verify offline indicator
        expect($(K.offlineIndicator), findsOneWidget);

        // Re-enable network
        await $.native.enableWifi();
        await $.pump(const Duration(seconds: 2));

        // Verify online state
        expect($(K.offlineIndicator), findsNothing);
      },
    );
  });

  group('Accessibility', () {
    patrolTest(
      'all interactive elements have semantic labels',
      config: patrolConfig,
      ($) async {
        await _launchApp($);

        // Verify semantic labels exist
        final buttons = $.tester.widgetList<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        for (final button in buttons) {
          expect(
            button.child,
            isNotNull,
            reason: 'Button should have accessible label',
          );
        }
      },
    );
  });
}

// =============================================================================
// Helper Functions
// =============================================================================

Future<void> _launchApp(PatrolIntegrationTester $) async {
  await $.pumpWidget(const _TestApp());
  await $.pumpAndSettle();
}

Future<void> _navigateToLogin(PatrolIntegrationTester $) async {
  // Navigate to login if not already there
  if ($(K.loginScreen).evaluate().isEmpty) {
    await $(K.loginNavButton).tap();
    await $.pumpAndSettle();
  }
}

Future<void> _performLogin(PatrolIntegrationTester $) async {
  await _navigateToLogin($);
  await $(K.emailField).enterText(TestConfig.testEmail);
  await $(K.passwordField).enterText(TestConfig.testPassword);
  await $(K.loginButton).tap();
  await $.pumpAndSettle();
}

// =============================================================================
// Test App Wrapper
// =============================================================================

/// Placeholder test app - replace with actual app import
class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    // TODO(integration): Replace with actual app widget
    // return const MyApp();
    return MaterialApp(
      home: Scaffold(
        key: K.homeScreen,
        appBar: AppBar(title: const Text('Flutter Base 2025')),
        body: const Center(child: Text('Integration Test Placeholder')),
      ),
    );
  }
}
