/// Root provider container for the application.
///
/// This file consolidates all infrastructure providers:
/// - Network clients (API, gRPC)
/// - Storage (Hive, Drift, TokenStorage)
/// - Core services (Logger, Crash Reporter, Analytics)
/// - Integrations (Third-party services)
///
/// **Usage:**
/// Import this file in main.dart to access all providers:
/// ```dart
/// import 'package:flutter_base_2025/core/di/app_providers.dart';
/// ```
///
/// **Convention:**
/// - Infrastructure providers belong here
/// - Feature-specific providers stay in features/*/presentation/providers/
/// - Shared UI state providers stay in lib/shared/providers/
library;

// Export all infrastructure provider modules
export 'core_providers.dart';
export 'network_providers.dart';
export 'storage_providers.dart';
