import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_base_2025/core/observability/app_logger.dart';

/// Device information.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 35.1**
class DeviceInfo {

  const DeviceInfo({
    required this.model,
    required this.osVersion,
    required this.platform,
    required this.uniqueId,
    required this.isPhysicalDevice,
    this.manufacturer,
  });
  final String model;
  final String osVersion;
  final String platform;
  final String uniqueId;
  final bool isPhysicalDevice;
  final String? manufacturer;

  Map<String, dynamic> toMap() => {
        'model': model,
        'osVersion': osVersion,
        'platform': platform,
        'uniqueId': uniqueId,
        'isPhysicalDevice': isPhysicalDevice,
        if (manufacturer != null) 'manufacturer': manufacturer,
      };
}

/// App information.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 35.2**
class AppInfo {

  const AppInfo({
    required this.version,
    required this.buildNumber,
    required this.packageName,
    required this.appName,
  });
  final String version;
  final String buildNumber;
  final String packageName;
  final String appName;

  String get fullVersion => '$version+$buildNumber';

  Map<String, dynamic> toMap() => {
        'version': version,
        'buildNumber': buildNumber,
        'packageName': packageName,
        'appName': appName,
        'fullVersion': fullVersion,
      };
}

/// Screen information.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 35.3**
class ScreenInfo {

  const ScreenInfo({
    required this.width,
    required this.height,
    required this.pixelRatio,
    required this.safeAreas,
    required this.brightness,
  });
  final double width;
  final double height;
  final double pixelRatio;
  final EdgeInsets safeAreas;
  final Brightness brightness;

  double get physicalWidth => width * pixelRatio;
  double get physicalHeight => height * pixelRatio;
  double get aspectRatio => width / height;

  bool get isTablet => width > 600;
  bool get isLandscape => width > height;

  Map<String, dynamic> toMap() => {
        'width': width,
        'height': height,
        'pixelRatio': pixelRatio,
        'physicalWidth': physicalWidth,
        'physicalHeight': physicalHeight,
        'aspectRatio': aspectRatio,
        'isTablet': isTablet,
        'isLandscape': isLandscape,
        'brightness': brightness.name,
      };
}

/// Battery information.
class BatteryInfo {

  const BatteryInfo({
    required this.level,
    required this.state,
  });
  final int level;
  final BatteryState state;

  bool get isCharging =>
      state == BatteryState.charging || state == BatteryState.full;
  bool get isLow => level < 20;

  Map<String, dynamic> toMap() => {
        'level': level,
        'state': state.name,
        'isCharging': isCharging,
        'isLow': isLow,
      };
}

enum BatteryState {
  unknown,
  charging,
  discharging,
  full,
  notCharging,
}

/// Device capabilities.
class DeviceCapabilities {

  const DeviceCapabilities({
    this.hasNfc = false,
    this.hasBiometrics = false,
    this.hasCamera = false,
    this.hasFrontCamera = false,
    this.hasGps = false,
    this.hasAccelerometer = false,
    this.hasGyroscope = false,
  });
  final bool hasNfc;
  final bool hasBiometrics;
  final bool hasCamera;
  final bool hasFrontCamera;
  final bool hasGps;
  final bool hasAccelerometer;
  final bool hasGyroscope;

  Map<String, dynamic> toMap() => {
        'hasNfc': hasNfc,
        'hasBiometrics': hasBiometrics,
        'hasCamera': hasCamera,
        'hasFrontCamera': hasFrontCamera,
        'hasGps': hasGps,
        'hasAccelerometer': hasAccelerometer,
        'hasGyroscope': hasGyroscope,
      };
}

/// Abstract interface for device info service.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 35.1, 35.2, 35.3**
abstract interface class DeviceInfoService {
  /// Gets device information.
  Future<DeviceInfo> getDeviceInfo();

  /// Gets app information.
  Future<AppInfo> getAppInfo();

  /// Gets screen information.
  ScreenInfo getScreenInfo();

  /// Gets battery information.
  Future<BatteryInfo> getBatteryInfo();

  /// Gets device capabilities.
  Future<DeviceCapabilities> getCapabilities();

  /// Gets a unique device identifier.
  Future<String> getDeviceId();
}

/// Mock device info service for development/testing.
class MockDeviceInfoService implements DeviceInfoService {
  @override
  Future<DeviceInfo> getDeviceInfo() async {
    String platform;
    if (kIsWeb) {
      platform = 'web';
    } else if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    } else if (Platform.isMacOS) {
      platform = 'macos';
    } else if (Platform.isWindows) {
      platform = 'windows';
    } else if (Platform.isLinux) {
      platform = 'linux';
    } else {
      platform = 'unknown';
    }

    return DeviceInfo(
      model: 'Mock Device',
      osVersion: Platform.operatingSystemVersion,
      platform: platform,
      uniqueId: 'mock-device-id-12345',
      isPhysicalDevice: !kDebugMode,
      manufacturer: 'Mock Manufacturer',
    );
  }

  @override
  Future<AppInfo> getAppInfo() async => const AppInfo(
      version: '1.0.0',
      buildNumber: '1',
      packageName: 'com.example.flutter_base_2025',
      appName: 'Flutter Base 2025',
    );

  @override
  ScreenInfo getScreenInfo() {
    final view = PlatformDispatcher.instance.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    final padding = view.padding;

    return ScreenInfo(
      width: size.width,
      height: size.height,
      pixelRatio: view.devicePixelRatio,
      safeAreas: EdgeInsets.fromViewPadding(padding, view.devicePixelRatio),
      brightness: view.platformDispatcher.platformBrightness,
    );
  }

  @override
  Future<BatteryInfo> getBatteryInfo() async => const BatteryInfo(
      level: 85,
      state: BatteryState.discharging,
    );

  @override
  Future<DeviceCapabilities> getCapabilities() async => const DeviceCapabilities(
      hasNfc: true,
      hasBiometrics: true,
      hasCamera: true,
      hasFrontCamera: true,
      hasGps: true,
      hasAccelerometer: true,
      hasGyroscope: true,
    );

  @override
  Future<String> getDeviceId() async => 'mock-device-id-12345';
}

/// Singleton for global access.
class DeviceInfoServiceProvider {
  static DeviceInfoService? _instance;

  static DeviceInfoService get instance {
    _instance ??= MockDeviceInfoService();
    return _instance!;
  }

  static void setInstance(DeviceInfoService service) {
    _instance = service;
  }
}
