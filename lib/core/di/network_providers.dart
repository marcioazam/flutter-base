/// Network-related providers.
///
/// Contains providers for:
/// - API Client (Dio-based REST client)
/// - gRPC Client
/// - WebSocket Client
/// - GraphQL Client
/// - HTTP interceptors (Auth, Logging, Retry)
///
/// **Pattern:**
/// All providers use @riverpod code generation.
library;

// TODO: Move providers from lib/core/network/
// TODO: Move providers from lib/core/grpc/providers/
// Example:
// ```dart
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:flutter_base_2025/core/network/api_client.dart';
//
// part 'network_providers.g.dart';
//
// @riverpod
// ApiClient apiClient(Ref ref) {
//   // Initialize Dio with interceptors
//   return ApiClient(/* ... */);
// }
//
// @riverpod
// GrpcClient grpcClient(Ref ref) {
//   return ref.watch(grpcClientProvider);
// }
// ```
