import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:flutter_base_2025/core/observability/app_logger.dart';

/// Result of a scan operation.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 29.2, 29.3**
class ScanResult {

  const ScanResult({
    required this.data,
    required this.format,
    required this.scannedAt, this.rawBytes,
  });
  final String data;
  final BarcodeFormat format;
  final Uint8List? rawBytes;
  final DateTime scannedAt;

  Map<String, dynamic> toMap() => {
        'data': data,
        'format': format.name,
        'scannedAt': scannedAt.toIso8601String(),
      };
}

/// Supported barcode formats.
enum BarcodeFormat {
  qrCode,
  ean13,
  ean8,
  upcA,
  upcE,
  code128,
  code39,
  code93,
  codabar,
  itf,
  pdf417,
  aztec,
  dataMatrix,
  unknown,
}

/// Camera capture mode.
enum CaptureMode {
  photo,
  video,
}

/// Camera facing direction.
enum CameraFacing {
  front,
  back,
}

/// Flash mode.
enum FlashMode {
  off,
  on,
  auto,
  torch,
}

/// Camera capture result.
class CaptureResult {

  const CaptureResult({
    required this.path,
    required this.mode,
    required this.capturedAt, this.width,
    this.height,
    this.durationMs,
  });
  final String path;
  final CaptureMode mode;
  final int? width;
  final int? height;
  final int? durationMs;
  final DateTime capturedAt;

  bool get isPhoto => mode == CaptureMode.photo;
  bool get isVideo => mode == CaptureMode.video;
}

/// Camera configuration.
class CameraConfig {

  const CameraConfig({
    this.facing = CameraFacing.back,
    this.flashMode = FlashMode.auto,
    this.zoom = 1.0,
    this.enableAudio = true,
    this.maxDurationSeconds,
  });
  final CameraFacing facing;
  final FlashMode flashMode;
  final double zoom;
  final bool enableAudio;
  final int? maxDurationSeconds;

  CameraConfig copyWith({
    CameraFacing? facing,
    FlashMode? flashMode,
    double? zoom,
    bool? enableAudio,
    int? maxDurationSeconds,
  }) => CameraConfig(
      facing: facing ?? this.facing,
      flashMode: flashMode ?? this.flashMode,
      zoom: zoom ?? this.zoom,
      enableAudio: enableAudio ?? this.enableAudio,
      maxDurationSeconds: maxDurationSeconds ?? this.maxDurationSeconds,
    );
}

/// Scanner configuration.
class ScannerConfig {

  const ScannerConfig({
    this.formats = const [BarcodeFormat.qrCode],
    this.beepOnScan = true,
    this.vibrateOnScan = true,
    this.autoFocus = true,
    this.continuousScan = false,
  });
  final List<BarcodeFormat> formats;
  final bool beepOnScan;
  final bool vibrateOnScan;
  final bool autoFocus;
  final bool continuousScan;
}

/// Camera service error.
class CameraError implements Exception {

  const CameraError({
    required this.message,
    required this.type,
    this.originalError,
  });
  final String message;
  final CameraErrorType type;
  final Object? originalError;

  @override
  String toString() => 'CameraError($type): $message';
}

enum CameraErrorType {
  permissionDenied,
  cameraUnavailable,
  captureError,
  scanError,
  configurationError,
  unknown,
}

/// Abstract interface for camera and scanner service.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 29.1, 29.2, 29.3, 29.5**
abstract interface class CameraService {
  /// Initializes the camera.
  Future<void> initialize([CameraConfig config]);

  /// Disposes camera resources.
  Future<void> dispose();

  /// Checks if camera permission is granted.
  Future<bool> hasPermission();

  /// Requests camera permission.
  Future<bool> requestPermission();

  /// Captures a photo.
  Future<CaptureResult> capturePhoto();

  /// Starts video recording.
  Future<void> startVideoRecording();

  /// Stops video recording and returns result.
  Future<CaptureResult> stopVideoRecording();

  /// Gets current camera configuration.
  CameraConfig get config;

  /// Updates camera configuration.
  Future<void> updateConfig(CameraConfig config);

  /// Switches between front and back camera.
  Future<void> switchCamera();

  /// Sets flash mode.
  Future<void> setFlashMode(FlashMode mode);

  /// Sets zoom level (1.0 to maxZoom).
  Future<void> setZoom(double zoom);

  /// Gets maximum zoom level.
  double get maxZoom;

  /// Stream of camera state changes.
  Stream<CameraState> get stateStream;
}

/// Camera state.
enum CameraState {
  uninitialized,
  initializing,
  ready,
  capturing,
  recording,
  error,
  disposed,
}

/// Abstract interface for barcode/QR scanner.
abstract interface class ScannerService {
  /// Initializes the scanner.
  Future<void> initialize([ScannerConfig config]);

  /// Disposes scanner resources.
  Future<void> dispose();

  /// Starts scanning.
  Future<void> startScan();

  /// Stops scanning.
  Future<void> stopScan();

  /// Stream of scan results.
  Stream<ScanResult> get scanStream;

  /// Scans a single code and returns result.
  Future<ScanResult?> scanOnce();

  /// Gets current scanner configuration.
  ScannerConfig get config;

  /// Updates scanner configuration.
  Future<void> updateConfig(ScannerConfig config);
}

/// Mock camera service for development/testing.
class MockCameraService implements CameraService {
  CameraConfig _config = const CameraConfig();
  CameraState _state = CameraState.uninitialized;
  final _stateController = _MockStreamController<CameraState>();

  @override
  Future<void> initialize([CameraConfig? config]) async {
    _state = CameraState.initializing;
    _stateController.add(_state);

    await Future<void>.delayed(const Duration(milliseconds: 500));

    _config = config ?? const CameraConfig();
    _state = CameraState.ready;
    _stateController.add(_state);

    AppLogger.instance.info('MockCameraService initialized');
  }

  @override
  Future<void> dispose() async {
    _state = CameraState.disposed;
    _stateController.add(_state);
    _stateController.close();
  }

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<CaptureResult> capturePhoto() async {
    _state = CameraState.capturing;
    _stateController.add(_state);

    await Future<void>.delayed(const Duration(milliseconds: 200));

    _state = CameraState.ready;
    _stateController.add(_state);

    return CaptureResult(
      path: '/mock/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      mode: CaptureMode.photo,
      width: 1920,
      height: 1080,
      capturedAt: DateTime.now(),
    );
  }

  @override
  Future<void> startVideoRecording() async {
    _state = CameraState.recording;
    _stateController.add(_state);
  }

  @override
  Future<CaptureResult> stopVideoRecording() async {
    _state = CameraState.ready;
    _stateController.add(_state);

    return CaptureResult(
      path: '/mock/video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      mode: CaptureMode.video,
      width: 1920,
      height: 1080,
      durationMs: 5000,
      capturedAt: DateTime.now(),
    );
  }

  @override
  CameraConfig get config => _config;

  @override
  Future<void> updateConfig(CameraConfig config) async {
    _config = config;
  }

  @override
  Future<void> switchCamera() async {
    _config = _config.copyWith(
      facing: _config.facing == CameraFacing.back
          ? CameraFacing.front
          : CameraFacing.back,
    );
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    _config = _config.copyWith(flashMode: mode);
  }

  @override
  Future<void> setZoom(double zoom) async {
    _config = _config.copyWith(zoom: zoom.clamp(1.0, maxZoom));
  }

  @override
  double get maxZoom => 5;

  @override
  Stream<CameraState> get stateStream => _stateController.stream;
}

/// Mock scanner service for development/testing.
class MockScannerService implements ScannerService {
  ScannerConfig _config = const ScannerConfig();
  final _scanController = _MockStreamController<ScanResult>();
  bool _isScanning = false;

  @override
  Future<void> initialize([ScannerConfig? config]) async {
    _config = config ?? const ScannerConfig();
    AppLogger.instance.info('MockScannerService initialized');
  }

  @override
  Future<void> dispose() async {
    _scanController.close();
  }

  @override
  Future<void> startScan() async {
    _isScanning = true;
  }

  @override
  Future<void> stopScan() async {
    _isScanning = false;
  }

  @override
  Stream<ScanResult> get scanStream => _scanController.stream;

  @override
  Future<ScanResult?> scanOnce() async {
    await Future<void>.delayed(const Duration(seconds: 1));

    return ScanResult(
      data: 'https://example.com/mock-qr-code',
      format: BarcodeFormat.qrCode,
      scannedAt: DateTime.now(),
    );
  }

  @override
  ScannerConfig get config => _config;

  @override
  Future<void> updateConfig(ScannerConfig config) async {
    _config = config;
  }

  /// Simulates a scan result (for testing).
  @visibleForTesting
  void simulateScan(ScanResult result) {
    if (_isScanning) {
      _scanController.add(result);
    }
  }
}

/// Simple mock stream controller.
class _MockStreamController<T> {
  final List<void Function(T)> _listeners = [];
  bool _isClosed = false;

  Stream<T> get stream => _MockStream(this);

  void add(T event) {
    if (_isClosed) return;
    for (final listener in _listeners) {
      listener(event);
    }
  }

  void close() {
    _isClosed = true;
    _listeners.clear();
  }

  void _addListener(void Function(T) listener) {
    _listeners.add(listener);
  }
}

class _MockStream<T> extends Stream<T> {

  _MockStream(this._controller);
  final _MockStreamController<T> _controller;

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (onData != null) {
      _controller._addListener(onData);
    }
    return _MockStreamSubscription();
  }
}

class _MockStreamSubscription<T> implements StreamSubscription<T> {
  @override
  Future<void> cancel() async {}

  @override
  void onData(void Function(T data)? handleData) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void onError(Function? handleError) {}

  @override
  void pause([Future<void>? resumeSignal]) {}

  @override
  void resume() {}

  @override
  bool get isPaused => false;

  @override
  Future<E> asFuture<E>([E? futureValue]) => Future.value(futureValue as E);
}
