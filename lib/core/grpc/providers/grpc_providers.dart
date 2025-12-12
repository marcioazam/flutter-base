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
  
  // Default gRPC configuration based on flavor
  // In production, these should come from environment variables
  return GrpcConfig(
    host: _getGrpcHost(appConfig),
    port: _getGrpcPort(appConfig),
    useTls: appConfig.isProduction,
    timeout: const Duration(seconds: 30),
    maxRetries: 3,
  );
}

String _getGrpcHost(AppConfig config) {
  // TODO: Add GRPC_HOST to .env files and AppConfig
  // For now, derive from API base URL or use defaults
  return switch (config.flavor) {
    Flavor.development => 'localhost',
    Flavor.staging => 'grpc-staging.example.com',
    Flavor.production => 'grpc.example.com',
  };
}

int _getGrpcPort(AppConfig config) {
  // TODO: Add GRPC_PORT to .env files and AppConfig
  return switch (config.flavor) {
    Flavor.development => 50051,
    Flavor.staging => 443,
    Flavor.production => 443,
  };
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

  final client = GrpcClient(
    config: config,
    tokenStorage: tokenStorage,
  );

  // Cleanup on dispose
  ref.onDispose(() async {
    await client.dispose();
  });

  return client;
}
