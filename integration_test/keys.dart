// =============================================================================
// Integration Test Keys
// =============================================================================
// Centralized widget keys for consistent test targeting.
// Use these keys in both production code and tests.
//
// Usage in widgets: key: K.homeScreen
// Usage in tests: $(K.homeScreen)
// =============================================================================

import 'package:flutter/foundation.dart';

/// Shorthand alias for Keys class
typedef K = Keys;

/// Centralized widget keys for integration tests
///
/// Benefits:
/// - Prevents typos in key strings
/// - Single source of truth
/// - IDE autocomplete support
/// - Easy refactoring
abstract final class Keys {
  // ===========================================================================
  // Screens
  // ===========================================================================
  static const splashScreen = Key('splashScreen');
  static const homeScreen = Key('homeScreen');
  static const loginScreen = Key('loginScreen');
  static const profileScreen = Key('profileScreen');
  static const settingsScreen = Key('settingsScreen');

  // ===========================================================================
  // Navigation
  // ===========================================================================
  static const navHome = Key('navHome');
  static const navProfile = Key('navProfile');
  static const navSettings = Key('navSettings');
  static const settingsButton = Key('settingsButton');
  static const loginNavButton = Key('loginNavButton');

  // ===========================================================================
  // Authentication
  // ===========================================================================
  static const emailField = Key('emailField');
  static const passwordField = Key('passwordField');
  static const loginButton = Key('loginButton');
  static const logoutButton = Key('logoutButton');
  static const forgotPasswordButton = Key('forgotPasswordButton');
  static const registerButton = Key('registerButton');

  // ===========================================================================
  // Permissions & Native Features
  // ===========================================================================
  static const requestLocationButton = Key('requestLocationButton');
  static const locationEnabled = Key('locationEnabled');
  static const openCameraButton = Key('openCameraButton');
  static const cameraPreview = Key('cameraPreview');
  static const enableNotificationsButton = Key('enableNotificationsButton');
  static const notificationsEnabled = Key('notificationsEnabled');

  // ===========================================================================
  // Connectivity
  // ===========================================================================
  static const offlineIndicator = Key('offlineIndicator');
  static const retryButton = Key('retryButton');

  // ===========================================================================
  // Common UI Elements
  // ===========================================================================
  static const loadingIndicator = Key('loadingIndicator');
  static const errorMessage = Key('errorMessage');
  static const successMessage = Key('successMessage');
  static const snackBar = Key('snackBar');
  static const dialog = Key('dialog');
  static const confirmButton = Key('confirmButton');
  static const cancelButton = Key('cancelButton');

  // ===========================================================================
  // Lists & Scrollables
  // ===========================================================================
  static const mainListView = Key('mainListView');
  static const refreshIndicator = Key('refreshIndicator');
  static const emptyState = Key('emptyState');

  // ===========================================================================
  // Forms
  // ===========================================================================
  static const formContainer = Key('formContainer');
  static const submitButton = Key('submitButton');
  static const clearButton = Key('clearButton');
}
