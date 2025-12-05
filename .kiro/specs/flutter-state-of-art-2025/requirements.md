# Requirements Document

## Introduction

Este documento especifica os requisitos para elevar o projeto Flutter Base 2025 ao "Estado da Arte" em desenvolvimento Flutter, garantindo que seja uma base de projeto 100% pronta para produção, utilizando as melhores práticas, padrões e bibliotecas mais atuais de 2025.

O projeto já possui uma base sólida com Clean Architecture, Riverpod 3.0, go_router 14.x, Dio 5.x, Drift, Freezed e Material 3. Esta especificação foca em melhorias incrementais para maximizar a utilização de Generics<T>, fortalecer padrões SOLID/DRY/KISS, e garantir cobertura de testes adequada.

## Glossary

- **Flutter Base 2025**: Template de projeto Flutter frontend puro para consumo de APIs
- **Generics<T>**: Tipos genéricos em Dart para código reutilizável e type-safe
- **Result<T>**: Tipo para operações que podem falhar (Either pattern simplificado)
- **PBT**: Property-Based Testing - testes baseados em propriedades com geração automática de dados
- **Glados**: Biblioteca de PBT para Dart/Flutter
- **Drift**: ORM type-safe para SQLite com streams reativos
- **Riverpod 3.0**: State management com code generation e AsyncNotifier
- **Freezed**: Code generation para data classes imutáveis
- **SOLID**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **DRY**: Don't Repeat Yourself
- **KISS**: Keep It Simple, Stupid
- **YAGNI**: You Aren't Gonna Need It
- **OWASP**: Open Web Application Security Project
- **WCAG**: Web Content Accessibility Guidelines

## Requirements

### Requirement 1: Enhanced Generic Repository Pattern

**User Story:** As a developer, I want a fully generic repository pattern with type-safe operations, so that I can create new feature repositories with minimal boilerplate.

#### Acceptance Criteria

1. WHEN a developer creates a new repository THEN the system SHALL provide a generic base class `BaseRepository<T, D, ID>` that handles all CRUD operations with type safety
2. WHEN repository operations are performed THEN the system SHALL return `Result<T>` for all operations ensuring exhaustive error handling
3. WHEN a repository needs custom queries THEN the system SHALL provide a generic `QueryBuilder<T>` interface for type-safe query construction
4. WHEN batch operations are needed THEN the system SHALL provide generic `createMany<T>` and `deleteMany<ID>` methods with transaction support
5. WHEN repository data is serialized THEN the system SHALL use a round-trip property: `fromDto(toDto(entity)) == entity` for all entities

### Requirement 2: Generic UseCase Pattern Enhancement

**User Story:** As a developer, I want enhanced generic use cases with better composition, so that I can chain business logic operations cleanly.

#### Acceptance Criteria

1. WHEN a use case is created THEN the system SHALL implement `UseCase<Params, R>` interface with `Future<Result<R>> call(Params params)`
2. WHEN use cases need composition THEN the system SHALL provide `andThen`, `map`, and `flatMap` combinators on Result type
3. WHEN a use case has no parameters THEN the system SHALL use `NoParams` singleton pattern
4. WHEN use cases return streams THEN the system SHALL implement `StreamUseCase<Params, R>` with `Stream<Result<R>>`
5. WHEN use case validation fails THEN the system SHALL return `ValidationFailure` with field-specific errors

### Requirement 3: Generic DataSource Pattern

**User Story:** As a developer, I want generic data sources for both remote and local data, so that I can swap implementations without changing business logic.

#### Acceptance Criteria

1. WHEN a remote data source is created THEN the system SHALL implement `RemoteDataSource<T, D>` interface with generic API operations
2. WHEN a local data source is created THEN the system SHALL implement `LocalDataSource<T>` interface with Drift integration
3. WHEN data sources handle errors THEN the system SHALL convert all exceptions to typed `AppException` subclasses
4. WHEN caching is needed THEN the system SHALL provide `CacheDataSource<T>` with TTL support and automatic expiration
5. WHEN data is parsed from JSON THEN the system SHALL validate round-trip: `fromJson(toJson(dto)) == dto`

### Requirement 4: Enhanced Result Type with Combinators

**User Story:** As a developer, I want a Result type with functional combinators, so that I can chain operations elegantly without nested callbacks.

#### Acceptance Criteria

1. WHEN Result operations are chained THEN the system SHALL provide `andThen`, `map`, `flatMap`, `mapAsync`, `flatMapAsync` methods
2. WHEN multiple Results need combining THEN the system SHALL provide `zip`, `zip3`, `zipWith` static methods
3. WHEN a list of Results needs sequencing THEN the system SHALL provide `sequence` and `traverse` methods
4. WHEN side effects are needed THEN the system SHALL provide `tap` and `tapFailure` methods that don't change the value
5. WHEN recovery is needed THEN the system SHALL provide `recover` and `orElse` methods for failure handling

### Requirement 5: Generic Pagination Support

**User Story:** As a developer, I want generic pagination that works with any entity type, so that I can implement infinite scroll consistently.

#### Acceptance Criteria

1. WHEN paginated data is fetched THEN the system SHALL return `PaginatedList<T>` with items, page, pageSize, totalItems, and hasMore
2. WHEN pagination state is managed THEN the system SHALL provide `PaginationNotifier<T>` with loadMore, refresh, and reset operations
3. WHEN pagination reaches the end THEN the system SHALL set `hasMore = false` and prevent additional requests
4. WHEN pagination fails THEN the system SHALL preserve existing items and allow retry
5. WHEN pagination is reset THEN the system SHALL clear all items and reset to page 1

### Requirement 6: Generic Form Validation

**User Story:** As a developer, I want generic form validation with type-safe field errors, so that I can validate forms consistently across the app.

#### Acceptance Criteria

1. WHEN a form is validated THEN the system SHALL return `ValidationResult<T>` with either valid data or field errors
2. WHEN validation rules are defined THEN the system SHALL provide composable `Validator<T>` functions
3. WHEN multiple validators are combined THEN the system SHALL aggregate all errors per field
4. WHEN validation fails THEN the system SHALL return `ValidationFailure` with `Map<String, List<String>>` field errors
5. WHEN whitespace-only input is provided THEN the system SHALL treat it as empty and reject if required

### Requirement 7: Generic State Management with Riverpod 3.0

**User Story:** As a developer, I want generic state management patterns with Riverpod 3.0, so that I can create consistent async notifiers.

#### Acceptance Criteria

1. WHEN async state is managed THEN the system SHALL use `AsyncNotifier<T>` with proper loading, error, and data states
2. WHEN state needs mutation THEN the system SHALL provide `MutationNotifier<T>` pattern with optimistic updates
3. WHEN providers are created THEN the system SHALL use `@riverpod` annotation for code generation
4. WHEN state is watched THEN the system SHALL use `ref.watch` for reactive updates and `ref.read` for one-time reads
5. WHEN providers are disposed THEN the system SHALL clean up resources using `ref.onDispose`

### Requirement 8: Security Hardening (OWASP Compliance)

**User Story:** As a security-conscious developer, I want OWASP-compliant security measures, so that the app is protected against common vulnerabilities.

#### Acceptance Criteria

1. WHEN sensitive data is stored THEN the system SHALL use `flutter_secure_storage` with platform-specific encryption
2. WHEN API requests are made THEN the system SHALL enforce TLS 1.2+ with certificate pinning option
3. WHEN user input is received THEN the system SHALL sanitize against XSS and injection attacks
4. WHEN clipboard contains sensitive data THEN the system SHALL auto-clear after configurable timeout
5. WHEN the app runs on rooted/jailbroken device THEN the system SHALL detect and warn (configurable)

### Requirement 9: Accessibility Compliance (WCAG 2.2)

**User Story:** As a developer building inclusive apps, I want WCAG 2.2 compliant widgets, so that users with disabilities can use the app effectively.

#### Acceptance Criteria

1. WHEN interactive elements are rendered THEN the system SHALL provide `Semantics` labels for screen readers
2. WHEN colors are used THEN the system SHALL maintain minimum 4.5:1 contrast ratio for text
3. WHEN touch targets are rendered THEN the system SHALL ensure minimum 44x44 logical pixels
4. WHEN focus changes THEN the system SHALL provide visible focus indicators
5. WHEN content is grouped THEN the system SHALL use `MergeSemantics` for logical grouping

### Requirement 10: Property-Based Testing Infrastructure

**User Story:** As a developer, I want property-based testing infrastructure, so that I can verify correctness properties across many inputs.

#### Acceptance Criteria

1. WHEN property tests are written THEN the system SHALL use Glados library with minimum 100 iterations
2. WHEN custom types need generation THEN the system SHALL provide `Arbitrary<T>` generators for all domain types
3. WHEN DTOs are tested THEN the system SHALL verify round-trip property: `fromJson(toJson(dto)) == dto`
4. WHEN Result operations are tested THEN the system SHALL verify monad laws (identity, associativity)
5. WHEN validators are tested THEN the system SHALL verify that valid inputs pass and invalid inputs fail consistently

### Requirement 11: Error Boundary and Recovery

**User Story:** As a developer, I want error boundaries with recovery options, so that errors don't crash the entire app.

#### Acceptance Criteria

1. WHEN a widget throws an error THEN the system SHALL catch it in `ErrorBoundary` and display fallback UI
2. WHEN an error is caught THEN the system SHALL provide retry callback for user-initiated recovery
3. WHEN errors are logged THEN the system SHALL include stack trace, context, and error type
4. WHEN network errors occur THEN the system SHALL display connectivity-aware error messages
5. WHEN errors are reported THEN the system SHALL integrate with crash reporting service (Sentry)

### Requirement 12: Performance Monitoring

**User Story:** As a developer, I want performance monitoring built-in, so that I can identify and fix performance issues.

#### Acceptance Criteria

1. WHEN the app starts THEN the system SHALL measure cold start time and report to analytics
2. WHEN navigation occurs THEN the system SHALL measure screen transition time
3. WHEN API calls are made THEN the system SHALL measure request/response time
4. WHEN memory usage exceeds threshold THEN the system SHALL trigger cache cleanup
5. WHEN frame drops occur THEN the system SHALL log jank events for debugging

### Requirement 13: Internationalization Support

**User Story:** As a developer building global apps, I want robust i18n support, so that the app can be easily localized.

#### Acceptance Criteria

1. WHEN text is displayed THEN the system SHALL use ARB files with `flutter_localizations`
2. WHEN locale changes THEN the system SHALL persist preference and rebuild UI
3. WHEN RTL languages are used THEN the system SHALL support `Directionality` widget
4. WHEN dates/numbers are formatted THEN the system SHALL use locale-aware formatters
5. WHEN pluralization is needed THEN the system SHALL use ICU message format

### Requirement 14: Code Generation and Build

**User Story:** As a developer, I want efficient code generation, so that boilerplate is minimized and builds are fast.

#### Acceptance Criteria

1. WHEN DTOs are defined THEN the system SHALL use Freezed for immutable data classes with `copyWith`
2. WHEN providers are defined THEN the system SHALL use `riverpod_generator` for type-safe providers
3. WHEN routes are defined THEN the system SHALL use `go_router_builder` for type-safe navigation
4. WHEN database tables are defined THEN the system SHALL use Drift code generation
5. WHEN build is run THEN the system SHALL complete code generation in under 30 seconds for typical project

### Requirement 15: WebSocket and Real-time Communication

**User Story:** As a developer building real-time features, I want a generic WebSocket client, so that I can implement chat, notifications, and live updates consistently.

#### Acceptance Criteria

1. WHEN a WebSocket connection is established THEN the system SHALL provide `WebSocketClient<T>` with typed message handling
2. WHEN the connection is lost THEN the system SHALL implement automatic reconnection with exponential backoff
3. WHEN messages are received THEN the system SHALL parse them into typed `WebSocketMessage<T>` objects
4. WHEN the app goes to background THEN the system SHALL maintain connection state and reconnect on foreground
5. WHEN connection status changes THEN the system SHALL emit `ConnectionState` (connecting, connected, disconnected, error)

### Requirement 16: Offline-First Data Synchronization

**User Story:** As a developer building offline-capable apps, I want offline-first data sync, so that users can work without internet and sync when connected.

#### Acceptance Criteria

1. WHEN data is created offline THEN the system SHALL store it locally with `SyncStatus.pending` flag
2. WHEN connectivity is restored THEN the system SHALL automatically sync pending changes to the server
3. WHEN sync conflicts occur THEN the system SHALL provide `ConflictResolver<T>` strategy (server-wins, client-wins, merge)
4. WHEN sync is in progress THEN the system SHALL emit `SyncState` (idle, syncing, error) via stream
5. WHEN data is fetched THEN the system SHALL return local data immediately and update from server in background

### Requirement 17: Push Notifications

**User Story:** As a developer, I want a unified push notification system, so that I can send and handle notifications across platforms.

#### Acceptance Criteria

1. WHEN the app starts THEN the system SHALL request notification permissions and register FCM token
2. WHEN a notification is received in foreground THEN the system SHALL display in-app notification banner
3. WHEN a notification is tapped THEN the system SHALL navigate to the appropriate screen via deep link
4. WHEN notification payload is received THEN the system SHALL parse into typed `NotificationPayload<T>`
5. WHEN FCM token changes THEN the system SHALL update the server with new token

### Requirement 18: Deep Linking and App Links

**User Story:** As a developer, I want deep linking support, so that users can navigate directly to specific content from external sources.

#### Acceptance Criteria

1. WHEN a deep link is received THEN the system SHALL parse it using `DeepLinkParser` and navigate to correct route
2. WHEN the app is opened via link THEN the system SHALL handle both cold start and warm start scenarios
3. WHEN Android App Links are configured THEN the system SHALL verify domain ownership via assetlinks.json
4. WHEN iOS Universal Links are configured THEN the system SHALL verify domain ownership via apple-app-site-association
5. WHEN deep link parameters are extracted THEN the system SHALL provide type-safe `DeepLinkParams<T>` object

### Requirement 19: Biometric Authentication

**User Story:** As a developer building secure apps, I want biometric authentication, so that users can authenticate with fingerprint or face recognition.

#### Acceptance Criteria

1. WHEN biometric auth is requested THEN the system SHALL check device capability via `BiometricService.isAvailable()`
2. WHEN biometric auth is performed THEN the system SHALL return `BiometricResult` (success, failed, cancelled, notAvailable)
3. WHEN biometric is not available THEN the system SHALL fallback to PIN/password authentication
4. WHEN biometric credentials are stored THEN the system SHALL use platform-specific secure enclave (Keystore/Keychain)
5. WHEN biometric settings change THEN the system SHALL invalidate stored credentials and require re-authentication

### Requirement 20: Analytics and Event Tracking

**User Story:** As a developer, I want analytics infrastructure, so that I can track user behavior and app performance.

#### Acceptance Criteria

1. WHEN events are tracked THEN the system SHALL use `AnalyticsService.track(event, params)` with typed `AnalyticsEvent`
2. WHEN screens are viewed THEN the system SHALL automatically track screen views via navigation observer
3. WHEN user properties are set THEN the system SHALL persist them across sessions
4. WHEN analytics providers are configured THEN the system SHALL support multiple providers (Firebase, Mixpanel, custom)
5. WHEN user opts out THEN the system SHALL disable all tracking and delete stored data

### Requirement 21: Feature Flags

**User Story:** As a developer, I want feature flags, so that I can enable/disable features without app updates.

#### Acceptance Criteria

1. WHEN feature flags are fetched THEN the system SHALL cache them locally with TTL
2. WHEN a feature is checked THEN the system SHALL use `FeatureFlags.isEnabled(flag)` with typed `FeatureFlag` enum
3. WHEN flags are updated remotely THEN the system SHALL refresh on app foreground or configurable interval
4. WHEN default values are needed THEN the system SHALL provide fallback values for offline scenarios
5. WHEN flags are evaluated THEN the system SHALL support user segmentation (by userId, deviceType, appVersion)

### Requirement 22: A/B Testing Infrastructure

**User Story:** As a developer, I want A/B testing support, so that I can experiment with different features and measure impact.

#### Acceptance Criteria

1. WHEN an experiment is defined THEN the system SHALL assign users to variants consistently via `ExperimentService`
2. WHEN variant is requested THEN the system SHALL return `Variant<T>` with typed configuration
3. WHEN experiment results are tracked THEN the system SHALL associate events with experiment variant
4. WHEN user is assigned to variant THEN the system SHALL persist assignment for session consistency
5. WHEN experiment is concluded THEN the system SHALL allow forcing specific variant for all users

### Requirement 23: CI/CD Pipeline Configuration

**User Story:** As a developer, I want CI/CD pipeline templates, so that I can automate testing, building, and deployment.

#### Acceptance Criteria

1. WHEN code is pushed THEN the system SHALL run lint, analyze, and test via GitHub Actions
2. WHEN tests pass THEN the system SHALL build APK/IPA for configured flavors (dev, staging, prod)
3. WHEN release is tagged THEN the system SHALL deploy to Play Store/App Store via Fastlane
4. WHEN build fails THEN the system SHALL notify team via configured channel (Slack, email)
5. WHEN PR is created THEN the system SHALL run code coverage check with minimum threshold (80%)



### Requirement 24: Image and Media Handling

**User Story:** As a developer, I want comprehensive image/media handling, so that I can efficiently manage media assets in the app.

#### Acceptance Criteria

1. WHEN images are loaded from network THEN the system SHALL use `CachedNetworkImage` with placeholder and error widgets
2. WHEN images are uploaded THEN the system SHALL compress them to configurable quality and max dimensions
3. WHEN images are cached THEN the system SHALL manage cache size with LRU eviction policy
4. WHEN multiple images are selected THEN the system SHALL provide `ImagePicker` with multi-select support
5. WHEN image metadata is needed THEN the system SHALL extract EXIF data and provide `ImageMetadata` object

### Requirement 25: File Management

**User Story:** As a developer, I want file management utilities, so that I can handle file operations consistently.

#### Acceptance Criteria

1. WHEN files are downloaded THEN the system SHALL show progress via `DownloadProgress` stream with percentage and bytes
2. WHEN files are uploaded THEN the system SHALL support multipart upload with progress tracking
3. WHEN files are stored locally THEN the system SHALL use platform-appropriate directories (Documents, Cache, Temp)
4. WHEN file picker is used THEN the system SHALL support filtering by file type (images, documents, videos)
5. WHEN files are shared THEN the system SHALL use `ShareService` with platform share sheet

### Requirement 26: Maps and Location Services

**User Story:** As a developer building location-aware apps, I want maps and location services, so that I can display maps and track user location.

#### Acceptance Criteria

1. WHEN maps are displayed THEN the system SHALL provide `MapService` abstraction supporting Google Maps and Mapbox
2. WHEN location is requested THEN the system SHALL check permissions and return `LocationResult` with coordinates
3. WHEN location tracking is enabled THEN the system SHALL provide `LocationStream` with configurable accuracy and interval
4. WHEN geocoding is needed THEN the system SHALL convert between coordinates and addresses via `GeocodingService`
5. WHEN location permissions are denied THEN the system SHALL guide user to settings with clear explanation

### Requirement 27: Payment Integration

**User Story:** As a developer building commerce apps, I want payment integration, so that I can process payments securely.

#### Acceptance Criteria

1. WHEN payments are processed THEN the system SHALL use `PaymentService` abstraction supporting Stripe
2. WHEN Apple Pay is available THEN the system SHALL provide native Apple Pay sheet on iOS
3. WHEN Google Pay is available THEN the system SHALL provide native Google Pay sheet on Android
4. WHEN payment fails THEN the system SHALL return typed `PaymentError` with actionable message
5. WHEN payment succeeds THEN the system SHALL return `PaymentResult` with transaction ID and receipt

### Requirement 28: Social Authentication

**User Story:** As a developer, I want social authentication, so that users can sign in with existing accounts.

#### Acceptance Criteria

1. WHEN Google Sign-In is used THEN the system SHALL return `SocialAuthResult` with idToken and user info
2. WHEN Apple Sign-In is used THEN the system SHALL handle Sign in with Apple flow on iOS 13+
3. WHEN Facebook Login is used THEN the system SHALL return access token and basic profile
4. WHEN social auth fails THEN the system SHALL return typed `SocialAuthError` (cancelled, failed, notAvailable)
5. WHEN social account is linked THEN the system SHALL associate with existing user account

### Requirement 29: Camera and Scanner

**User Story:** As a developer, I want camera and scanning capabilities, so that I can capture photos and scan codes.

#### Acceptance Criteria

1. WHEN camera is used THEN the system SHALL provide `CameraService` with photo and video capture
2. WHEN QR codes are scanned THEN the system SHALL return `ScanResult` with decoded data and format
3. WHEN barcodes are scanned THEN the system SHALL support common formats (EAN, UPC, Code128, Code39)
4. WHEN document scanning is needed THEN the system SHALL provide edge detection and perspective correction
5. WHEN camera permissions are denied THEN the system SHALL show permission rationale and settings link

### Requirement 30: Audio and Video

**User Story:** As a developer building media apps, I want audio/video capabilities, so that I can play and record media.

#### Acceptance Criteria

1. WHEN video is played THEN the system SHALL provide `VideoPlayerService` with play, pause, seek, and fullscreen
2. WHEN audio is played THEN the system SHALL support background playback with media controls
3. WHEN audio is recorded THEN the system SHALL provide `AudioRecorder` with configurable quality and format
4. WHEN media playback state changes THEN the system SHALL emit `PlaybackState` (playing, paused, buffering, ended)
5. WHEN media controls are shown THEN the system SHALL integrate with platform media session (lock screen, notification)

### Requirement 31: Animations

**User Story:** As a developer, I want animation utilities, so that I can create engaging UI experiences.

#### Acceptance Criteria

1. WHEN Lottie animations are used THEN the system SHALL provide `LottieWidget` with play, pause, and loop control
2. WHEN page transitions are needed THEN the system SHALL provide custom `PageRouteBuilder` animations
3. WHEN list items animate THEN the system SHALL use `AnimatedList` with staggered entrance animations
4. WHEN loading states are shown THEN the system SHALL use shimmer/skeleton placeholders
5. WHEN micro-interactions are needed THEN the system SHALL provide `flutter_animate` integration

### Requirement 32: Dynamic Theming

**User Story:** As a developer, I want dynamic theming, so that users can customize app appearance.

#### Acceptance Criteria

1. WHEN theme mode changes THEN the system SHALL support light, dark, and system-follow modes
2. WHEN dynamic colors are available (Android 12+) THEN the system SHALL use wallpaper-based color scheme
3. WHEN custom theme is selected THEN the system SHALL persist preference and apply on restart
4. WHEN theme transitions occur THEN the system SHALL animate smoothly between themes
5. WHEN contrast mode is enabled THEN the system SHALL provide high-contrast theme variant

### Requirement 33: Structured Logging

**User Story:** As a developer, I want structured logging, so that I can debug and monitor the app effectively.

#### Acceptance Criteria

1. WHEN logs are written THEN the system SHALL use `AppLogger` with levels (debug, info, warning, error, fatal)
2. WHEN errors are logged THEN the system SHALL include stack trace, context map, and error code
3. WHEN logs are filtered THEN the system SHALL support filtering by level and tag
4. WHEN production builds run THEN the system SHALL disable debug logs and only emit warning+
5. WHEN logs are exported THEN the system SHALL provide log file export for debugging


### Requirement 34: Permissions Handling

**User Story:** As a developer, I want unified permissions handling, so that I can request and manage permissions consistently.

#### Acceptance Criteria

1. WHEN permissions are requested THEN the system SHALL use `PermissionService` with typed `Permission` enum
2. WHEN permission status is checked THEN the system SHALL return `PermissionStatus` (granted, denied, permanentlyDenied, restricted)
3. WHEN permission is permanently denied THEN the system SHALL provide deep link to app settings
4. WHEN multiple permissions are needed THEN the system SHALL request them in sequence with rationale
5. WHEN permission rationale is shown THEN the system SHALL display user-friendly explanation before request

### Requirement 35: Device Information

**User Story:** As a developer, I want device information access, so that I can adapt the app to device capabilities.

#### Acceptance Criteria

1. WHEN device info is requested THEN the system SHALL return `DeviceInfo` with model, OS version, and unique ID
2. WHEN app info is requested THEN the system SHALL return `AppInfo` with version, build number, and package name
3. WHEN screen info is requested THEN the system SHALL return `ScreenInfo` with size, density, and safe areas
4. WHEN battery info is requested THEN the system SHALL return `BatteryInfo` with level and charging state
5. WHEN device capabilities are checked THEN the system SHALL detect features (NFC, biometrics, camera)

### Requirement 36: Connectivity Monitoring

**User Story:** As a developer, I want connectivity monitoring, so that I can handle online/offline states gracefully.

#### Acceptance Criteria

1. WHEN connectivity changes THEN the system SHALL emit `ConnectivityState` (online, offline, limited)
2. WHEN connection type is checked THEN the system SHALL return `ConnectionType` (wifi, mobile, ethernet, none)
3. WHEN offline mode is detected THEN the system SHALL show connectivity indicator in UI
4. WHEN connectivity is restored THEN the system SHALL trigger pending sync operations
5. WHEN network quality is poor THEN the system SHALL detect and report limited connectivity

### Requirement 37: App Lifecycle Management

**User Story:** As a developer, I want app lifecycle management, so that I can handle app state changes properly.

#### Acceptance Criteria

1. WHEN app state changes THEN the system SHALL emit `AppLifecycleState` (resumed, inactive, paused, detached)
2. WHEN app goes to background THEN the system SHALL save pending state and pause non-essential operations
3. WHEN app returns to foreground THEN the system SHALL refresh stale data and resume operations
4. WHEN app is terminated THEN the system SHALL persist critical state for restoration
5. WHEN memory warning is received THEN the system SHALL clear caches and release non-essential resources

### Requirement 38: Background Tasks

**User Story:** As a developer, I want background task support, so that I can perform work when the app is not active.

#### Acceptance Criteria

1. WHEN background fetch is needed THEN the system SHALL use `BackgroundService` with platform-specific implementation
2. WHEN periodic tasks are scheduled THEN the system SHALL use WorkManager (Android) / BGTaskScheduler (iOS)
3. WHEN background task runs THEN the system SHALL complete within platform time limits (30s iOS, 10min Android)
4. WHEN background task fails THEN the system SHALL retry with exponential backoff
5. WHEN background task completes THEN the system SHALL notify the app on next foreground

### Requirement 39: Local Notifications

**User Story:** As a developer, I want local notifications, so that I can schedule and display notifications without server.

#### Acceptance Criteria

1. WHEN notification is scheduled THEN the system SHALL use `LocalNotificationService` with typed `NotificationConfig`
2. WHEN notification is displayed THEN the system SHALL support title, body, image, and action buttons
3. WHEN notification is tapped THEN the system SHALL navigate to specified route via deep link
4. WHEN recurring notification is needed THEN the system SHALL support daily, weekly, and custom intervals
5. WHEN notification is cancelled THEN the system SHALL remove from notification center and cancel pending

### Requirement 40: In-App Updates

**User Story:** As a developer, I want in-app update prompts, so that users can update without leaving the app.

#### Acceptance Criteria

1. WHEN update is available THEN the system SHALL check via `UpdateService.checkForUpdate()`
2. WHEN flexible update is available THEN the system SHALL show non-blocking update banner
3. WHEN immediate update is required THEN the system SHALL show blocking update dialog
4. WHEN update is downloaded THEN the system SHALL prompt user to install
5. WHEN update check fails THEN the system SHALL fail silently and retry on next app open

### Requirement 41: Rate and Review

**User Story:** As a developer, I want in-app review prompts, so that I can encourage users to rate the app.

#### Acceptance Criteria

1. WHEN review is requested THEN the system SHALL use native in-app review API (Play Store / App Store)
2. WHEN review conditions are met THEN the system SHALL show review prompt (configurable triggers)
3. WHEN review is completed or dismissed THEN the system SHALL not show again for configurable period
4. WHEN review API is unavailable THEN the system SHALL fallback to store deep link
5. WHEN review is requested THEN the system SHALL respect platform rate limits (3x per year iOS)

### Requirement 42: Crash Reporting

**User Story:** As a developer, I want crash reporting, so that I can identify and fix crashes in production.

#### Acceptance Criteria

1. WHEN crash occurs THEN the system SHALL capture stack trace, device info, and user context
2. WHEN crash is reported THEN the system SHALL send to configured service (Sentry, Crashlytics)
3. WHEN non-fatal error occurs THEN the system SHALL log as handled exception with context
4. WHEN user is identified THEN the system SHALL associate crashes with user ID (anonymized)
5. WHEN breadcrumbs are logged THEN the system SHALL include recent user actions before crash

### Requirement 43: Remote Configuration

**User Story:** As a developer, I want remote configuration, so that I can change app behavior without updates.

#### Acceptance Criteria

1. WHEN config is fetched THEN the system SHALL use `RemoteConfigService` with typed config values
2. WHEN config is cached THEN the system SHALL use local defaults until remote is available
3. WHEN config changes THEN the system SHALL apply changes on next app open or configurable interval
4. WHEN config fetch fails THEN the system SHALL use cached values with fallback to defaults
5. WHEN config values are accessed THEN the system SHALL provide type-safe getters (getString, getInt, getBool)