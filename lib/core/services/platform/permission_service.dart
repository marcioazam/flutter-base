import 'package:flutter/foundation.dart';

import 'package:flutter_base_2025/core/observability/app_logger.dart';

/// Permission types supported by the app.
///
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 34.1**
enum Permission {
  camera,
  microphone,
  photos,
  storage,
  location,
  locationAlways,
  notification,
  contacts,
  calendar,
  bluetooth,
  sensors,
}

/// Permission status.
///
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 34.2**
enum PermissionStatus {
  /// Permission has been granted.
  granted,

  /// Permission has been denied.
  denied,

  /// Permission has been permanently denied (user must go to settings).
  permanentlyDenied,

  /// Permission is restricted (iOS parental controls, etc.).
  restricted,

  /// Permission status is unknown or limited.
  limited,
}

/// Result of a permission request.
class PermissionResult {
  const PermissionResult({
    required this.permission,
    required this.status,
    this.message,
  });
  final Permission permission;
  final PermissionStatus status;
  final String? message;

  bool get isGranted => status == PermissionStatus.granted;
  bool get isDenied => status == PermissionStatus.denied;
  bool get isPermanentlyDenied => status == PermissionStatus.permanentlyDenied;
  bool get isRestricted => status == PermissionStatus.restricted;
}

/// Permission rationale configuration.
class PermissionRationale {
  const PermissionRationale({
    required this.title,
    required this.message,
    this.iconAsset,
    this.positiveButton = 'Continue',
    this.negativeButton = 'Not Now',
  });
  final String title;
  final String message;
  final String? iconAsset;
  final String positiveButton;
  final String negativeButton;
}

/// Default rationales for common permissions.
abstract final class DefaultRationales {
  static const camera = PermissionRationale(
    title: 'Camera Access',
    message:
        'We need camera access to take photos and scan QR codes. Your photos are never shared without your permission.',
  );

  static const microphone = PermissionRationale(
    title: 'Microphone Access',
    message:
        'We need microphone access to record audio and video. Your recordings are stored securely.',
  );

  static const photos = PermissionRationale(
    title: 'Photo Library Access',
    message:
        'We need access to your photo library to let you select and share images.',
  );

  static const location = PermissionRationale(
    title: 'Location Access',
    message:
        'We need your location to show nearby places and provide location-based features.',
  );

  static const notification = PermissionRationale(
    title: 'Notification Access',
    message:
        "We'd like to send you notifications about important updates and messages.",
  );

  static const contacts = PermissionRationale(
    title: 'Contacts Access',
    message:
        'We need access to your contacts to help you connect with friends.',
  );

  static PermissionRationale forPermission(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return camera;
      case Permission.microphone:
        return microphone;
      case Permission.photos:
      case Permission.storage:
        return photos;
      case Permission.location:
      case Permission.locationAlways:
        return location;
      case Permission.notification:
        return notification;
      case Permission.contacts:
        return contacts;
      default:
        return PermissionRationale(
          title: '${permission.name} Access',
          message: 'This feature requires ${permission.name} permission.',
        );
    }
  }
}

/// Abstract interface for permission service.
///
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 34.1, 34.2, 34.3, 34.4, 34.5**
abstract interface class PermissionService {
  /// Checks the status of a permission.
  Future<PermissionStatus> check(Permission permission);

  /// Requests a permission.
  Future<PermissionResult> request(Permission permission);

  /// Requests multiple permissions in sequence.
  Future<List<PermissionResult>> requestMultiple(List<Permission> permissions);

  /// Opens app settings for the user to grant permissions.
  Future<bool> openSettings();

  /// Checks if should show rationale before requesting.
  Future<bool> shouldShowRationale(Permission permission);
}

/// Mock permission service for development/testing.
class MockPermissionService implements PermissionService {
  final Map<Permission, PermissionStatus> _statuses = {};

  @override
  Future<PermissionStatus> check(Permission permission) async =>
      _statuses[permission] ?? PermissionStatus.denied;

  @override
  Future<PermissionResult> request(Permission permission) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final currentStatus = _statuses[permission];
    if (currentStatus == PermissionStatus.permanentlyDenied) {
      return PermissionResult(
        permission: permission,
        status: PermissionStatus.permanentlyDenied,
        message: 'Permission permanently denied. Please enable in settings.',
      );
    }

    _statuses[permission] = PermissionStatus.granted;
    AppLogger.instance.debug('Permission granted: ${permission.name}');

    return PermissionResult(
      permission: permission,
      status: PermissionStatus.granted,
    );
  }

  @override
  Future<List<PermissionResult>> requestMultiple(
    List<Permission> permissions,
  ) async {
    final results = <PermissionResult>[];

    for (final permission in permissions) {
      final result = await request(permission);
      results.add(result);

      if (!result.isGranted) {
        break;
      }
    }

    return results;
  }

  @override
  Future<bool> openSettings() async {
    AppLogger.instance.debug('Opening app settings');
    return true;
  }

  @override
  Future<bool> shouldShowRationale(Permission permission) async {
    final status = _statuses[permission];
    return status == PermissionStatus.denied;
  }

  /// Sets permission status (for testing).
  @visibleForTesting
  void setStatus(Permission permission, PermissionStatus status) {
    _statuses[permission] = status;
  }

  /// Resets all permissions (for testing).
  @visibleForTesting
  void reset() {
    _statuses.clear();
  }
}

/// Singleton for global access.
class PermissionServiceProvider {
  static PermissionService? _instance;

  static PermissionService get instance {
    _instance ??= MockPermissionService();
    return _instance!;
  }

  static void setInstance(PermissionService service) {
    _instance = service;
  }
}
