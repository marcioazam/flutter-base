# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2.0] - 2025-12-04

### Added
- CompositeRepository<T, ID> for orchestrating cache, local, and remote sources
- CompositeUseCase<Params, R> for chaining multiple use cases
- CancellableUseCase for cancellable operations
- NoParamsStreamUseCase for streaming without parameters
- fpdart 1.2.0 as functional programming reference
- All 16 requirements from flutter-2025-state-of-art-review spec implemented
- 12 correctness properties verified with property-based testing

### Changed
- Updated flutter_riverpod to 3.0.3+
- Updated go_router to 17.0.0+
- Updated drift to 2.29.0+
- Updated freezed to 3.2.3+
- Updated glados to 1.1.7+
- Updated freezed_annotation to 3.0.0+
- Project version bumped to 3.2.0

### Verified Implementations
- Result<T> with full monad laws (left identity, right identity, associativity)
- BaseRepository<T, ID> with createMany, deleteMany, watchAll, exists, count, findFirst
- ApiRepository<T, D, ID> with DTO-Entity conversion
- DriftRepository<T, ID> for type-safe SQLite operations
- CacheDataSource<T> with TTL and LRU eviction (MemoryCacheDataSource, LruCacheDataSource)
- CompositeRepository<T, ID> with cache -> local -> remote strategy
- ValidationResult with CompositeValidator aggregating all errors
- PaginationNotifier<T> with loadInitial, loadMore, refresh, reset
- WebSocketClient with typed messages and exponential backoff reconnection
- FeatureFlags and ExperimentService with variant persistence
- WCAG 2.1 accessibility utilities (contrast ratio, touch targets)
- Exception to Failure exhaustive mapping

### Property Tests (36 files in test/property/)
- result_test.dart - Monad laws verification
- dto_test.dart - Round-trip serialization
- validation_test.dart - Composition aggregates all errors
- cache_test.dart - TTL expiration and LRU eviction
- exception_mapping_test.dart - Exhaustive mapping
- accessibility_test.dart - WCAG contrast ratio symmetry
- pagination_notifier_test.dart - State preservation on error
- websocket_test.dart - Message round-trip
- feature_flags_test.dart - Variant persistence

### Documentation
- Updated architecture.md with all new services
- Complete property-based testing coverage for all correctness properties
- All ADRs complete (ADR-008 through ADR-010)
- All 23 tasks in spec completed and verified

## [3.1.0] - 2025-12-04

### Added
- Flutter 3.38 / Dart 3.10 support with dot shorthands
- Drift database with type-safe SQLite abstraction
- DriftRepository<T, ID> generic pattern for local data access
- SyncRepository with conflict resolution strategies
- AIService interface for Gemini/OpenAI integration
- MockAIService for development and testing
- AI error mapping to AppFailure hierarchy
- ErrorBoundary widget with retry functionality
- DefaultErrorWidget and CompactErrorWidget
- PredictivePopScope for Android 15+ back gesture
- UnsavedChangesMixin for form protection
- MemoryMonitor with threshold-based cache cleanup
- AccessibilityTestUtils for WCAG 2.2 compliance
- Widget Previewer annotations (experimental)
- Patrol E2E testing framework integration
- Property-based tests for all new features

### Changed
- Updated SDK constraint to `>=3.10.0 <4.0.0`
- Updated Flutter constraint to `>=3.38.0`
- Optimized build.yaml for faster code generation
- Enhanced PerformanceMonitor with memory tracking
- Improved analysis_options.yaml with stricter rules

### Android
- Added NDK r28 for 16KB page size support (Android 15+)
- Enabled predictive back gesture callback
- Updated to Java 17 for Gradle 8.14 compatibility
- Added proguard rules for Drift/SQLite

### Documentation
- Updated README with new features
- Added ADR for Drift migration decision

## [3.0.0] - 2025-10-XX

### Added
- Flutter 3.27+ and Dart 3.6+ support
- Riverpod 3.0 with AsyncNotifier and code generation
- Generic Repository pattern with type safety
- Generic UseCase pattern
- Result<T> monad for error handling
- PaginatedList<T> for pagination
- Flavor configuration (development, staging, production)
- App initialization with splash screen preservation
- CrashReporter abstraction
- AnalyticsService with NavigatorObserver
- FeatureFlags service
- Mutation pattern for side-effects
- RTL support
- Accessibility widgets
- Property-based tests with glados
- Docker deployment
- GitHub Actions CI/CD
- Comprehensive documentation

### Changed
- Migrated from StateNotifier to AsyncNotifier
- Updated go_router to 14.x
- Updated dio to 5.x
- Updated freezed to 2.5+
- Simplified architecture for API-first frontend
- Removed local database (drift/isar)

### Removed
- Firebase direct integration (now via API)
- Offline-first sync
- Kubernetes manifests (over-engineering for static frontend)

## [1.0.0] - 2024-XX-XX

### Added
- Initial project structure
- Basic authentication flow
- Theme support
- Localization (en, pt)
