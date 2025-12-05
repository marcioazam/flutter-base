import 'package:flutter/services.dart';

import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// Biometric authentication types.
enum BiometricType { fingerprint, face, iris, none }

/// Biometric authentication status.
enum BiometricStatus { available, notAvailable, notEnrolled, lockedOut }

/// Abstract interface for biometric authentication.
abstract interface class BiometricService {
  /// Checks if biometric authentication is available.
  Future<bool> isAvailable();

  /// Gets the available biometric type.
  Future<BiometricType> getAvailableType();

  /// Gets the biometric status.
  Future<BiometricStatus> getStatus();

  /// Authenticates using biometrics with optional fallback.
  Future<Result<bool>> authenticate({
    required String reason,
    bool biometricOnly = false,
  });

  /// Cancels ongoing authentication.
  Future<void> cancelAuthentication();
}

/// Biometric service implementation using local_auth.
/// Note: Requires local_auth package to be added to pubspec.yaml
class BiometricServiceImpl implements BiometricService {
  static const int _maxRetries = 3;
  int _retryCount = 0;

  @override
  Future<bool> isAvailable() async {
    // Placeholder - requires local_auth package
    // final localAuth = LocalAuthentication();
    // return await localAuth.canCheckBiometrics && await localAuth.isDeviceSupported();
    return false;
  }

  @override
  Future<BiometricType> getAvailableType() async {
    // Placeholder - requires local_auth package
    // final localAuth = LocalAuthentication();
    // final biometrics = await localAuth.getAvailableBiometrics();
    // if (biometrics.contains(BiometricType.face)) return BiometricType.face;
    // if (biometrics.contains(BiometricType.fingerprint)) return BiometricType.fingerprint;
    // if (biometrics.contains(BiometricType.iris)) return BiometricType.iris;
    return BiometricType.none;
  }

  @override
  Future<BiometricStatus> getStatus() async {
    final available = await isAvailable();
    if (!available) return BiometricStatus.notAvailable;

    // Check enrollment status
    // Placeholder - requires local_auth package
    return BiometricStatus.available;
  }

  @override
  Future<Result<bool>> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final available = await isAvailable();
      if (!available) {
        if (biometricOnly) {
          return Failure(AuthFailure('Biometric authentication not available'));
        }
        // Fallback to PIN/password
        return _authenticateWithFallback(reason);
      }

      // Placeholder - requires local_auth package
      // final localAuth = LocalAuthentication();
      // final result = await localAuth.authenticate(
      //   localizedReason: reason,
      //   options: AuthenticationOptions(
      //     stickyAuth: true,
      //     biometricOnly: biometricOnly,
      //   ),
      // );

      // Simulated success for now
      const result = true;

      if (result) {
        _retryCount = 0;
        return const Success(true);
      }

      _retryCount++;
      if (_retryCount >= _maxRetries) {
        _retryCount = 0;
        if (!biometricOnly) {
          return _authenticateWithFallback(reason);
        }
        return Failure(AuthFailure('Maximum retry attempts exceeded'));
      }

      return const Success(false);
    } on PlatformException catch (e) {
      _retryCount++;
      if (_retryCount >= _maxRetries && !biometricOnly) {
        _retryCount = 0;
        return _authenticateWithFallback(reason);
      }
      return Failure(AuthFailure(e.message ?? 'Biometric authentication failed'));
    }
  }

  Future<Result<bool>> _authenticateWithFallback(String reason) async {
    // Fallback to device credentials (PIN/password/pattern)
    try {
      // Placeholder - requires local_auth package
      // final localAuth = LocalAuthentication();
      // final result = await localAuth.authenticate(
      //   localizedReason: reason,
      //   options: const AuthenticationOptions(
      //     stickyAuth: true,
      //     biometricOnly: false,
      //   ),
      // );
      // return Success(result);

      return const Success(true);
    } on PlatformException catch (e) {
      return Failure(AuthFailure(e.message ?? 'Authentication failed'));
    }
  }

  @override
  Future<void> cancelAuthentication() async {
    // Placeholder - requires local_auth package
    // final localAuth = LocalAuthentication();
    // await localAuth.stopAuthentication();
    _retryCount = 0;
  }
}

/// Biometric service provider for dependency injection.
BiometricService createBiometricService() => BiometricServiceImpl();
