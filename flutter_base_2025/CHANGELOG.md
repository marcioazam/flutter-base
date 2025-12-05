# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2.0] - 2025-12-04

### Added
- BackgroundTaskService for scheduled background work with retry logic
- All 43 requirements from flutter-state-of-art-2025 spec implemented
- Complete property-based testing coverage

### Documentation
- Updated architecture.md with all new services
- Added Phase 16 to tasks.md for final verification
- All ADRs complete (ADR-008 through ADR-010)

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
