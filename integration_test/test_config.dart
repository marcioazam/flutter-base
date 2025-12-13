// =============================================================================
// Integration Test Configuration
// =============================================================================
// Centralized configuration for integration tests.
// =============================================================================

import 'package:patrol/patrol.dart';

/// Patrol test configuration
///
/// Customize timeouts, frame policy, and other settings here.
const patrolConfig = PatrolTesterConfig(
  
  // Policy for handling frames during tests
  // Use fullyLive for tests that need real-time animations
  // Use benchmarkLive for faster execution
);

/// Test configuration constants
///
/// SECURITY: These are test-only credentials.
/// Never use production credentials in tests.
abstract final class TestConfig {
  // ===========================================================================
  // Test Credentials
  // ===========================================================================
  
  /// Test user email - use only in test environment
  static const testEmail = 'test@example.com';
  
  /// Test user password - use only in test environment
  static const testPassword = 'Test123!@#';

  // ===========================================================================
  // Timeouts
  // ===========================================================================
  
  /// Default timeout for async operations
  static const defaultTimeout = Duration(seconds: 30);
  
  /// Timeout for network operations
  static const networkTimeout = Duration(seconds: 15);
  
  /// Timeout for animations to settle
  static const settleTimeout = Duration(seconds: 5);

  // ===========================================================================
  // Deep Links
  // ===========================================================================
  
  /// App scheme for deep links
  static const appScheme = 'flutterbase';
  
  /// Settings deep link
  static const settingsDeepLink = '$appScheme://settings';
  
  /// Profile deep link
  static const profileDeepLink = '$appScheme://profile';

  // ===========================================================================
  // Test Data
  // ===========================================================================
  
  /// Sample valid email for form tests
  static const validEmail = 'valid@example.com';
  
  /// Sample invalid email for validation tests
  static const invalidEmail = 'invalid-email';
  
  /// Sample weak password for validation tests
  static const weakPassword = '123';
  
  /// Sample strong password for validation tests
  static const strongPassword = 'StrongP@ss123!';
}
