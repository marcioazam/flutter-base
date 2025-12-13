import 'package:flutter_base_2025/core/cache/hive_cache_config.dart';
import 'package:flutter_base_2025/core/cache/hive_cache_datasource.dart';
import 'package:flutter_base_2025/core/cache/hive_initializer.dart';
import 'package:flutter_base_2025/core/config/app_config.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hive_providers.g.dart';

/// Provider for Hive cache configuration.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 4.5**
@riverpod
HiveCacheConfig hiveCacheConfig(Ref ref) {
  final appConfig = ref.watch(appConfigProvider);

  return appConfig.isProduction
      ? HiveCacheConfig.production()
      : HiveCacheConfig.development();
}

/// Provider for opening a Hive box.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 4.5**
@riverpod
Future<Box<Map<dynamic, dynamic>>> cacheBox(
  Ref ref,
  String boxName, {
  bool encrypted = false,
}) async {
  if (encrypted) {
    return HiveInitializer.openEncryptedBox<Map<dynamic, dynamic>>(boxName);
  }
  return HiveInitializer.openBox<Map<dynamic, dynamic>>(boxName);
}

/// Factory function type for creating HiveCacheDataSource.
typedef HiveCacheDataSourceFactory<T> = HiveCacheDataSource<T> Function({
  required Box<Map<dynamic, dynamic>> box,
  required T Function(Map<String, dynamic>) fromJson,
  required Map<String, dynamic> Function(T) toJson,
  HiveCacheConfig? config,
});

/// Create a HiveCacheDataSource for a specific type.
///
/// Usage:
/// ```dart
/// final userCache = createHiveCacheDataSource<User>(
///   box: await ref.watch(cacheBoxProvider('users').future),
///   fromJson: User.fromJson,
///   toJson: (user) => user.toJson(),
/// );
/// ```
HiveCacheDataSource<T> createHiveCacheDataSource<T>({
  required Box<Map<dynamic, dynamic>> box,
  required T Function(Map<String, dynamic>) fromJson,
  required Map<String, dynamic> Function(T) toJson,
  HiveCacheConfig? config,
}) =>
    HiveCacheDataSource<T>(
      box: box,
      fromJson: fromJson,
      toJson: toJson,
      config: config ?? const HiveCacheConfig(),
    );
