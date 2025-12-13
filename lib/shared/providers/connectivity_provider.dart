import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_base_2025/core/observability/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for Connectivity instance.
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

/// Provider for current connectivity status.
final connectivityStatusProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.onConnectivityChanged;
});

/// Provider that returns true if device is online.
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider);
  return status.maybeWhen(
    data: (results) => !results.contains(ConnectivityResult.none),
    orElse: () => true,
  );
});

/// Provider for connectivity service with additional utilities.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService(ref.watch(connectivityProvider));
  ref.onDispose(service.dispose);
  return service;
});

/// Callback type for sync operations.
typedef SyncCallback = Future<void> Function();

/// Service for connectivity-related operations.
/// 
/// **Feature: flutter-state-of-art-2025**
/// **Validates: Requirements 36.4**
class ConnectivityService {

  ConnectivityService(this._connectivity) {
    _initConnectivityListener();
  }
  final Connectivity _connectivity;
  final List<SyncCallback> _syncCallbacks = [];
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOffline = false;

  void _initConnectivityListener() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isOffline = results.contains(ConnectivityResult.none);

      if (_wasOffline && !isOffline) {
        _triggerSync();
      }

      _wasOffline = isOffline;
    });
  }

  Future<void> _triggerSync() async {
    AppLogger.instance.info('Connectivity restored, triggering sync operations');

    for (final callback in _syncCallbacks) {
      try {
        await callback();
      } on Exception catch (e, stack) {
        AppLogger.instance.error('Sync callback failed', error: e, stackTrace: stack);
      }
    }
  }

  /// Registers a callback to be called when connectivity is restored.
  void registerSyncCallback(SyncCallback callback) {
    _syncCallbacks.add(callback);
    AppLogger.instance.debug('Sync callback registered');
  }

  /// Unregisters a sync callback.
  void unregisterSyncCallback(SyncCallback callback) {
    _syncCallbacks.remove(callback);
    AppLogger.instance.debug('Sync callback unregistered');
  }

  /// Manually triggers all sync callbacks.
  Future<void> triggerManualSync() async {
    await _triggerSync();
  }

  /// Check current connectivity status.
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Gets the current connection type.
  Future<ConnectionType> getConnectionType() async {
    final results = await _connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectionType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionType.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectionType.ethernet;
    } else if (results.contains(ConnectivityResult.vpn)) {
      return ConnectionType.vpn;
    } else {
      return ConnectionType.none;
    }
  }

  /// Stream of connectivity changes.
  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none),
    );

  /// Stream of connection type changes.
  Stream<ConnectionType> get onConnectionTypeChanged => _connectivity.onConnectivityChanged.map((results) {
      if (results.contains(ConnectivityResult.wifi)) {
        return ConnectionType.wifi;
      } else if (results.contains(ConnectivityResult.mobile)) {
        return ConnectionType.mobile;
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return ConnectionType.ethernet;
      } else if (results.contains(ConnectivityResult.vpn)) {
        return ConnectionType.vpn;
      } else {
        return ConnectionType.none;
      }
    });

  /// Disposes resources.
  void dispose() {
    _subscription?.cancel();
    _syncCallbacks.clear();
  }
}

/// Connection type enum.
enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  vpn,
  none,
}
