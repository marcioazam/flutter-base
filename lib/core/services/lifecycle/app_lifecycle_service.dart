import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// App lifecycle state.
enum AppLifecycleState {
  resumed,
  inactive,
  paused,
  detached,
  hidden,
}

/// App lifecycle configuration.
class AppLifecycleConfig {

  const AppLifecycleConfig({
    this.staleDataThreshold = const Duration(minutes: 5),
    this.refreshOnResume = true,
    this.pauseOnBackground = true,
  });
  final Duration staleDataThreshold;
  final bool refreshOnResume;
  final bool pauseOnBackground;
}

/// Abstract app lifecycle service interface.
abstract interface class AppLifecycleService {
  /// Stream of lifecycle state changes.
  Stream<AppLifecycleState> get stateChanges;

  /// Current lifecycle state.
  AppLifecycleState get currentState;

  /// Time when app went to background.
  DateTime? get backgroundTime;

  /// Whether data is considered stale.
  bool get isDataStale;

  /// Registers a callback for resume.
  void onResume(VoidCallback callback);

  /// Registers a callback for pause.
  void onPause(VoidCallback callback);

  /// Registers a callback for stale data refresh.
  void onStaleRefresh(VoidCallback callback);

  /// Removes a resume callback.
  void removeResumeCallback(VoidCallback callback);

  /// Removes a pause callback.
  void removePauseCallback(VoidCallback callback);

  /// Disposes resources.
  void dispose();
}

/// App lifecycle service implementation.
class AppLifecycleServiceImpl
    with WidgetsBindingObserver
    implements AppLifecycleService {

  AppLifecycleServiceImpl({
    this.config = const AppLifecycleConfig(),
  }) {
    WidgetsBinding.instance.addObserver(this);
  }
  final AppLifecycleConfig config;

  final _stateController = StreamController<AppLifecycleState>.broadcast();
  final _resumeCallbacks = <VoidCallback>[];
  final _pauseCallbacks = <VoidCallback>[];
  final _staleRefreshCallbacks = <VoidCallback>[];

  AppLifecycleState _currentState = AppLifecycleState.resumed;
  DateTime? _backgroundTime;

  @override
  Stream<AppLifecycleState> get stateChanges => _stateController.stream;

  @override
  AppLifecycleState get currentState => _currentState;

  @override
  DateTime? get backgroundTime => _backgroundTime;

  @override
  bool get isDataStale {
    if (_backgroundTime == null) return false;
    return DateTime.now().difference(_backgroundTime!) >
        config.staleDataThreshold;
  }

  @override
  void didChangeAppLifecycleState(ui.AppLifecycleState state) {
    final newState = _mapState(state);
    _currentState = newState;
    _stateController.add(newState);

    switch (newState) {
      case AppLifecycleState.resumed:
        _handleResume();
      case AppLifecycleState.paused:
        _handlePause();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _handleResume() {
    final wasStale = isDataStale;
    _backgroundTime = null;

    for (final callback in _resumeCallbacks) {
      callback();
    }

    if (wasStale && config.refreshOnResume) {
      for (final callback in _staleRefreshCallbacks) {
        callback();
      }
    }
  }

  void _handlePause() {
    _backgroundTime = DateTime.now();

    if (config.pauseOnBackground) {
      for (final callback in _pauseCallbacks) {
        callback();
      }
    }
  }

  AppLifecycleState _mapState(ui.AppLifecycleState state) => switch (state) {
      ui.AppLifecycleState.resumed => AppLifecycleState.resumed,
      ui.AppLifecycleState.inactive => AppLifecycleState.inactive,
      ui.AppLifecycleState.paused => AppLifecycleState.paused,
      ui.AppLifecycleState.detached => AppLifecycleState.detached,
      ui.AppLifecycleState.hidden => AppLifecycleState.hidden,
    };

  @override
  void onResume(VoidCallback callback) {
    _resumeCallbacks.add(callback);
  }

  @override
  void onPause(VoidCallback callback) {
    _pauseCallbacks.add(callback);
  }

  @override
  void onStaleRefresh(VoidCallback callback) {
    _staleRefreshCallbacks.add(callback);
  }

  @override
  void removeResumeCallback(VoidCallback callback) {
    _resumeCallbacks.remove(callback);
  }

  @override
  void removePauseCallback(VoidCallback callback) {
    _pauseCallbacks.remove(callback);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateController.close();
    _resumeCallbacks.clear();
    _pauseCallbacks.clear();
    _staleRefreshCallbacks.clear();
  }
}

/// App lifecycle service factory.
AppLifecycleService createAppLifecycleService({
  AppLifecycleConfig config = const AppLifecycleConfig(),
}) => AppLifecycleServiceImpl(config: config);
