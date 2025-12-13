import 'package:flutter_base_2025/core/config/app_config.dart';
import 'package:flutter_base_2025/core/grpc/grpc_client.dart';
import 'package:flutter_base_2025/core/grpc/grpc_config.dart';
import 'package:flutter_base_2025/core/storage/token_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'grpc_providers.g.dart';

/// Provider for gRPC configuration.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 4.5**
///
/// Reads gRPC configuration from environment variables via AppConfig.
/// Falls back to defaults if not configured.
@riverpod
GrpcConfig grpcConfig(Ref ref) {
  final appConfig = ref.watch(appConfigProvider);

  return GrpcConfig(
    host: appConfig.grpcHost,
    port: appConfig.grpcPort,
    useTls: appConfig.grpcUseTls,
    timeout: Duration(seconds: appConfig.grpcTimeoutSeconds),
    maxRetries: appConfig.grpcMaxRetries,
  );
}

/// Provider for GrpcClient.
///
/// **Feature: architecture-alignment-2025**
/// **Validates: Requirements 4.5**
///
/// Creates a GrpcClient with proper configuration and token storage.
/// Automatically disposes the client when the provider is disposed.
@riverpod
GrpcClient grpcClient(Ref ref) {
  final config = ref.watch(grpcConfigProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);

  final client = GrpcClient(config: config, tokenStorage: tokenStorage);

  // Cleanup on dispose
  ref.onDispose(() async {
    await client.dispose();
  });

  return client;
}
