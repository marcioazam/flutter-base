/// Core infrastructure providers.
///
/// Contains providers for:
/// - Logger (AppLogger)
/// - Crash Reporter (Sentry, etc.)
/// - Analytics (Firebase Analytics, etc.)
/// - Feature Flags
/// - Remote Config
/// - Experiment Service (A/B testing)
///
/// **Pattern:**
/// All providers use @riverpod code generation for consistency.
library;

// TODO: Move logger provider from lib/core/observability/
// TODO: Move crash reporter provider
// TODO: Move analytics provider
// TODO: Move feature flags provider from lib/core/config/
// Example:
// ```dart
// @riverpod
// AppLogger appLogger(Ref ref) => AppLogger.instance;
// ```
