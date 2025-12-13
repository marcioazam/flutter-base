/// Core module barrel file.
///
/// Export all core infrastructure modules.
library;

// Cache
export 'cache/cache_datasource.dart';
export 'cache/cache_entry.dart';
export 'cache/cache_repository.dart';
export 'cache/hive_cache_config.dart';
export 'cache/hive_cache_datasource.dart';
export 'cache/hive_cache_entry.dart';
export 'cache/hive_initializer.dart';

// Config
export 'config/app_config.dart';
export 'config/experiment_service.dart';
export 'config/feature_flags.dart';
export 'config/remote_config_service.dart';
export 'config/retry_config.dart';

// Constants
export 'constants/app_constants.dart';
export 'constants/validation_patterns.dart';

// Database
export 'database/app_database.dart';
export 'database/sync_repository.dart';

// Dependency Injection
export 'di/app_providers.dart';
export 'di/core_providers.dart';
export 'di/network_providers.dart';
export 'di/storage_providers.dart';

// Errors
export 'errors/exception_mapper.dart';
export 'errors/exceptions.dart';
export 'errors/failures.dart';

// Base classes (abstractions)
export 'base/api_repository.dart';
export 'base/base_datasource.dart';
export 'base/base_dto.dart';
export 'base/base_repository.dart';
export 'base/base_usecase.dart';
export 'base/composite_repository.dart';
export 'base/drift_repository.dart';
export 'base/paginated_list.dart';
export 'base/paginated_response.dart';
export 'base/pagination_notifier.dart';

// gRPC
export 'grpc/grpc_client.dart';
export 'grpc/grpc_config.dart';
export 'grpc/grpc_status_mapper.dart';

// Init
export 'init/app_initializer.dart';

// Network
export 'network/api_client.dart';
export 'network/circuit_breaker.dart';
export 'network/graphql_client.dart';
export 'network/resilient_api_client.dart';
export 'network/websocket_client.dart';

// Observability
export 'observability/analytics_service.dart';
export 'observability/app_logger.dart';
export 'observability/crash_reporter.dart';
export 'observability/performance_monitor.dart';
export 'observability/sentry_crash_reporter.dart' hide SentryCrashReporter;

// Router
export 'router/app_router.dart';
export 'router/route_guards.dart';

// Security
export 'security/certificate_pinning_service.dart';
export 'security/deep_link_validator.dart';
export 'security/input_sanitizer.dart';
export 'security/secure_random.dart';
export 'security/security_utils.dart'
    hide DeepLinkValidator, InputSanitizer, SecureRandom;

// Storage
export 'storage/persistence_storage.dart';
export 'storage/token_storage.dart';

// Theme
export 'theme/accessibility.dart';
export 'theme/accessibility_service.dart';
export 'theme/app_colors.dart';
export 'theme/app_theme.dart';
export 'theme/app_typography.dart';

// Utils
export 'utils/extension_types.dart';
export 'utils/form_controller.dart' hide Validator;
export 'utils/mutation.dart';
export 'utils/result.dart';
export 'utils/validation.dart';
