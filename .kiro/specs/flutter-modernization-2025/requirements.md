# Requirements Document

## Introduction

Este documento define os requisitos para modernização do projeto Flutter Base 2025 como **frontend puro** consumindo uma **API Python** como backend. O Flutter será responsável apenas pela UI/UX e comunicação com a API, enquanto toda lógica de negócio, autenticação e persistência ficam no backend Python.

### Arquitetura Frontend-Backend

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER (Frontend)                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Presentation│  │   Domain    │  │       Data          │  │
│  │  (Widgets)  │──│ (Entities)  │──│ (API Client/DTOs)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/REST
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    PYTHON API (Backend)                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Routes    │  │  Services   │  │    Database         │  │
│  │  (FastAPI)  │──│  (Logic)    │──│   (PostgreSQL)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Escopo da Modernização (Frontend Only)

**Atualizações de SDK e Bibliotecas:**
- Flutter 3.27+ com suporte a Impeller e melhorias de performance
- Dart 3.6+ com digit separators e melhorias no language server
- Riverpod 3.0+ com AsyncNotifier para consumo de API
- go_router 14.x com StatefulShellRoute e type-safety
- Dio 5.x com interceptors para auth token e retry
- freezed 2.5+ para DTOs imutáveis e type-safe

**Arquitetura Frontend:**
- Clean Architecture adaptada para API consumption
- Generic ApiClient<T> para chamadas HTTP tipadas
- Generic Repository<T> como wrapper do API client
- Result<T> monad para error handling
- DTOs com freezed para serialização JSON

**Responsabilidades do Flutter:**
- UI/UX e navegação
- State management com Riverpod
- Consumo de API REST via Dio
- Cache local simples (SharedPreferences)
- Token storage seguro
- Offline indicator (sem offline-first)

**Responsabilidades da API Python:**
- Autenticação (JWT tokens)
- Autorização e permissões
- Lógica de negócio
- Persistência (PostgreSQL)
- Validações de dados
- Feature flags

## Glossary

- **FlutterBaseApp**: O sistema de template Flutter sendo modernizado
- **Generic Repository<T>**: Padrão de repositório tipado que funciona com qualquer entidade
- **Riverpod 3.0**: Versão mais recente do framework de state management com Mutations e Persistence
- **AsyncNotifier**: Classe do Riverpod para operações assíncronas com estado
- **Mutation**: Novo recurso do Riverpod 3.0 para side-effects com feedback de UI
- **Drift**: Biblioteca de persistência reativa baseada em SQLite (substitui Isar)
- **Docker Multi-Stage**: Técnica de build Docker que reduz tamanho da imagem final
- **Quality Gate**: Conjunto de critérios que código deve passar antes de merge
- **Digit Separators**: Recurso do Dart 3.6 para melhor legibilidade de números grandes
- **Pub Workspaces**: Recurso do Dart 3.6 para gerenciar múltiplos pacotes em monorepo

## Requirements

### Requirement 1: Atualização de Dependências para 2025

**User Story:** As a developer, I want the project to use the latest stable versions of Flutter and Dart, so that I can leverage new language features and performance improvements.

#### Acceptance Criteria

1. WHEN the project is initialized THEN FlutterBaseApp SHALL use Flutter SDK version 3.27.0 or higher
2. WHEN Dart code is compiled THEN FlutterBaseApp SHALL target Dart SDK version 3.6.0 or higher
3. WHEN numeric literals are written THEN FlutterBaseApp SHALL support digit separators (e.g., 1_000_000)
4. WHEN Riverpod is used THEN FlutterBaseApp SHALL use flutter_riverpod version 3.0.0 or higher
5. WHEN navigation is implemented THEN FlutterBaseApp SHALL use go_router version 14.x
6. WHEN HTTP requests are made THEN FlutterBaseApp SHALL use Dio version 5.x with interceptors
7. WHEN DTOs are created THEN FlutterBaseApp SHALL use freezed version 2.5+ with json_serializable
8. WHEN local cache is needed THEN FlutterBaseApp SHALL use SharedPreferences for simple key-value storage
9. WHEN secure storage is needed THEN FlutterBaseApp SHALL use flutter_secure_storage for tokens

### Requirement 2: Generic Repository Pattern<T>

**User Story:** As a developer, I want a generic repository pattern with full type safety, so that I can reduce boilerplate and maintain consistency across data access layers.

#### Acceptance Criteria

1. WHEN a repository is created THEN FlutterBaseApp SHALL implement BaseRepository<T, ID> interface with CRUD operations (create, read, update, delete)
2. WHEN data is fetched THEN FlutterBaseApp SHALL return Result<T> with typed Success<T> or Failure<T>
3. WHEN multiple entities are fetched THEN FlutterBaseApp SHALL return Result<PaginatedList<T>> with page, pageSize, total, and hasMore fields
4. WHEN repository methods are called THEN FlutterBaseApp SHALL enforce type safety at compile time via Dart generics
5. WHEN a new entity type is added THEN FlutterBaseApp SHALL require only entity-specific implementation extending BaseRepository<T, ID>
6. WHEN entity has relationships THEN FlutterBaseApp SHALL support eager loading via include parameter
7. WHEN filtering is needed THEN FlutterBaseApp SHALL accept Filter<T> generic specification object
8. WHEN sorting is needed THEN FlutterBaseApp SHALL accept Sort<T> generic specification with field and direction
9. WHEN batch operations are performed THEN FlutterBaseApp SHALL support createMany<T>, updateMany<T>, deleteMany<T> methods
10. WHEN repository is disposed THEN FlutterBaseApp SHALL clean up resources and cancel pending operations

### Requirement 3: Riverpod 3.0 Migration

**User Story:** As a developer, I want to use Riverpod 3.0 features, so that I can benefit from improved async handling, mutations, and persistence.

#### Acceptance Criteria

1. WHEN StateNotifier is used THEN FlutterBaseApp SHALL migrate to Notifier or AsyncNotifier classes from riverpod 3.0
2. WHEN async operations show progress THEN FlutterBaseApp SHALL use AsyncLoading(progress: double) parameter for progress indication
3. WHEN side-effects are performed THEN FlutterBaseApp SHALL use Mutation<T> objects for UI feedback with loading/error/success states
4. WHEN provider state needs persistence THEN FlutterBaseApp SHALL use @JsonPersist() annotation with JsonSqFliteStorage
5. WHEN testing providers THEN FlutterBaseApp SHALL use ProviderContainer.test() for automatic disposal after test completion
6. WHEN StateProvider is used THEN FlutterBaseApp SHALL migrate to Notifier with simple state
7. WHEN FutureProvider.future is used THEN FlutterBaseApp SHALL migrate to AsyncNotifier pattern
8. WHEN provider depends on another THEN FlutterBaseApp SHALL use ref.watch() for reactive updates
9. WHEN side effects are needed THEN FlutterBaseApp SHALL use ref.read() within event handlers only
10. WHEN provider is disposed THEN FlutterBaseApp SHALL use ref.onDispose() to clean up subscriptions and controllers
11. WHEN code generation is used THEN FlutterBaseApp SHALL use @riverpod annotation with riverpod_generator
12. WHEN async state changes THEN FlutterBaseApp SHALL preserve previous data/error when going back to loading state

### Requirement 4: Docker Containerization

**User Story:** As a DevOps engineer, I want Docker support for the Flutter application, so that I can deploy consistently across environments.

#### Acceptance Criteria

1. WHEN Docker build is executed THEN FlutterBaseApp SHALL use multi-stage build with builder and runtime stages to minimize image size below 100MB
2. WHEN web build is containerized THEN FlutterBaseApp SHALL serve static files via nginx:alpine with gzip compression and cache headers
3. WHEN Docker image is built THEN FlutterBaseApp SHALL cache Flutter SDK layer and pub dependencies layer separately for faster rebuilds
4. WHEN deployment folder is created THEN FlutterBaseApp SHALL contain Dockerfile, Dockerfile.dev, docker-compose.yml, docker-compose.prod.yml, and nginx.conf
5. WHEN container runs THEN FlutterBaseApp SHALL expose /health endpoint returning JSON with status, version, and timestamp
6. WHEN development environment is needed THEN FlutterBaseApp SHALL provide docker-compose.dev.yml with hot reload support
7. WHEN production environment is deployed THEN FlutterBaseApp SHALL use docker-compose.prod.yml with resource limits and restart policies
8. WHEN nginx serves content THEN FlutterBaseApp SHALL configure security headers (CSP, X-Frame-Options, X-Content-Type-Options)
9. WHEN static assets are served THEN FlutterBaseApp SHALL configure cache-control headers with max-age of 1 year for hashed assets
10. WHEN container starts THEN FlutterBaseApp SHALL complete health check within 30 seconds timeout

### Requirement 5: CI/CD Optimization

**User Story:** As a developer, I want optimized CI/CD pipelines, so that builds are faster and more reliable.

#### Acceptance Criteria

1. WHEN CI runs THEN FlutterBaseApp SHALL use Flutter 3.27+ via subosito/flutter-action@v2 in GitHub Actions workflows
2. WHEN dependencies are installed THEN FlutterBaseApp SHALL cache pub packages via actions/cache@v4 with pubspec.lock hash key
3. WHEN tests run THEN FlutterBaseApp SHALL execute unit, widget, and property-based tests in parallel using matrix strategy
4. WHEN code coverage is measured THEN FlutterBaseApp SHALL enforce minimum 80% line coverage threshold via codecov
5. WHEN PR is created THEN FlutterBaseApp SHALL run dart analyze --fatal-infos and dart format --set-exit-if-changed
6. WHEN release is tagged THEN FlutterBaseApp SHALL build and push Docker images to GitHub Container Registry (ghcr.io)
7. WHEN build fails THEN FlutterBaseApp SHALL notify via GitHub status checks with step-level error details
8. WHEN Android build runs THEN FlutterBaseApp SHALL use Java 17 via actions/setup-java@v4 with temurin distribution
9. WHEN iOS build runs THEN FlutterBaseApp SHALL run on macos-latest with Xcode 15+
10. WHEN web build runs THEN FlutterBaseApp SHALL generate source maps for debugging and upload as artifact
11. WHEN artifacts are generated THEN FlutterBaseApp SHALL upload via actions/upload-artifact@v4 with 7-day retention
12. WHEN workflow completes THEN FlutterBaseApp SHALL post summary with build times, test results, and coverage percentage

### Requirement 6: Generic Data Layer

**User Story:** As a developer, I want generic data sources and DTOs, so that I can reduce code duplication in the data layer.

#### Acceptance Criteria

1. WHEN remote data source is created THEN FlutterBaseApp SHALL implement BaseRemoteDataSource<T, ID> with get, getAll, create, update, delete methods
2. WHEN local data source is created THEN FlutterBaseApp SHALL implement BaseLocalDataSource<T, ID> with cache, getCached, clearCache, isCached methods
3. WHEN DTO is created THEN FlutterBaseApp SHALL implement Dto<E> interface with toEntity() returning E and static fromEntity(E) factory
4. WHEN JSON is serialized THEN FlutterBaseApp SHALL use @freezed with @JsonSerializable(genericArgumentFactories: true) for generic DTOs
5. WHEN API response is paginated THEN FlutterBaseApp SHALL use PaginatedResponse<T> with items, page, pageSize, totalItems, totalPages fields
6. WHEN API response wraps data THEN FlutterBaseApp SHALL use ApiResponse<T> with data, message, statusCode, timestamp fields
7. WHEN cache expires THEN FlutterBaseApp SHALL use CachePolicy with maxAge Duration and staleWhileRevalidate option
8. WHEN network fails THEN FlutterBaseApp SHALL fallback to cached data if available via CacheFallbackStrategy
9. WHEN data is transformed THEN FlutterBaseApp SHALL use Mapper<From, To> interface with map(From) and mapList(List<From>) methods
10. WHEN batch requests are made THEN FlutterBaseApp SHALL use BatchRequest<T> with items list and parallel/sequential execution option

### Requirement 7: Code Quality and SOLID Principles

**User Story:** As a tech lead, I want the codebase to follow SOLID, DRY, YAGNI, and Clean Code principles, so that it remains maintainable and scalable.

#### Acceptance Criteria

1. WHEN a class is created THEN FlutterBaseApp SHALL follow Single Responsibility Principle with one reason to change
2. WHEN dependencies are injected THEN FlutterBaseApp SHALL use abstract interfaces for Dependency Inversion Principle
3. WHEN code is duplicated more than twice THEN FlutterBaseApp SHALL extract to shared utilities following DRY
4. WHEN features are added THEN FlutterBaseApp SHALL implement only required functionality following YAGNI
5. WHEN functions are written THEN FlutterBaseApp SHALL limit to 50 lines maximum with verb-first naming (e.g., fetchUser, validateEmail)
6. WHEN files are created THEN FlutterBaseApp SHALL limit to 400 lines maximum with single type per file
7. WHEN classes are extended THEN FlutterBaseApp SHALL follow Open/Closed Principle allowing extension without modification
8. WHEN interfaces are implemented THEN FlutterBaseApp SHALL follow Interface Segregation with focused, cohesive interfaces
9. WHEN subclasses are used THEN FlutterBaseApp SHALL follow Liskov Substitution ensuring substitutability
10. WHEN cyclomatic complexity exceeds 10 THEN FlutterBaseApp SHALL refactor to reduce complexity
11. WHEN nesting exceeds 3 levels THEN FlutterBaseApp SHALL use early returns or extract methods
12. WHEN magic numbers are used THEN FlutterBaseApp SHALL extract to named constants with semantic meaning

### Requirement 8: Enhanced Testing Infrastructure

**User Story:** As a QA engineer, I want comprehensive testing infrastructure, so that I can ensure code quality through automated tests.

#### Acceptance Criteria

1. WHEN property tests run THEN FlutterBaseApp SHALL use glados with minimum 100 iterations per property via Glados<T>(iterations: 100)
2. WHEN mocks are created THEN FlutterBaseApp SHALL use mocktail for type-safe test doubles without code generation
3. WHEN generators are needed THEN FlutterBaseApp SHALL provide custom Arbitrary<T> implementations in test/helpers/generators.dart
4. WHEN integration tests run THEN FlutterBaseApp SHALL use integration_test package with flutter drive
5. WHEN test coverage is reported THEN FlutterBaseApp SHALL generate HTML report via genhtml and LCOV for CI
6. WHEN golden tests run THEN FlutterBaseApp SHALL compare widget screenshots with baseline images
7. WHEN async code is tested THEN FlutterBaseApp SHALL use expectLater with completes, throwsA, emitsInOrder matchers
8. WHEN providers are tested THEN FlutterBaseApp SHALL use ProviderContainer.test() with overrides for dependencies
9. WHEN HTTP calls are tested THEN FlutterBaseApp SHALL use MockDio or http_mock_adapter for request/response mocking
10. WHEN test files are organized THEN FlutterBaseApp SHALL mirror source structure in test/ directory
11. WHEN test names are written THEN FlutterBaseApp SHALL use descriptive names following "should [expected behavior] when [condition]" pattern
12. WHEN test setup is needed THEN FlutterBaseApp SHALL use setUp() and tearDown() for common initialization

### Requirement 9: Deployment Infrastructure

**User Story:** As a DevOps engineer, I want complete deployment infrastructure, so that I can deploy the application to production environments.

#### Acceptance Criteria

1. WHEN deployment folder exists THEN FlutterBaseApp SHALL contain deployment/docker/, deployment/k8s/, and deployment/scripts/ directories
2. WHEN environment variables are needed THEN FlutterBaseApp SHALL use .env.example template with flutter_dotenv package
3. WHEN secrets are managed THEN FlutterBaseApp SHALL document integration with AWS Secrets Manager, GCP Secret Manager, or Azure Key Vault
4. WHEN health checks are performed THEN FlutterBaseApp SHALL expose /health endpoint returning {status, version, uptime, dependencies}
5. WHEN logs are generated THEN FlutterBaseApp SHALL output structured JSON logs with timestamp, level, message, context fields
6. WHEN Kubernetes is used THEN FlutterBaseApp SHALL provide deployment.yaml, service.yaml, ingress.yaml, and configmap.yaml
7. WHEN horizontal scaling is needed THEN FlutterBaseApp SHALL provide hpa.yaml with CPU/memory based autoscaling
8. WHEN monitoring is needed THEN FlutterBaseApp SHALL expose /metrics endpoint in Prometheus format
9. WHEN deployment scripts are needed THEN FlutterBaseApp SHALL provide deploy.sh, rollback.sh, and health-check.sh scripts
10. WHEN environment configs differ THEN FlutterBaseApp SHALL provide separate configs for dev, staging, and prod environments

### Requirement 10: Modern Dart 3.6 Features

**User Story:** As a developer, I want to use modern Dart 3.6 features, so that code is more readable and maintainable.

#### Acceptance Criteria

1. WHEN large numbers are written THEN FlutterBaseApp SHALL use digit separators (e.g., const timeout = 30_000; const maxSize = 1_048_576;)
2. WHEN pattern matching is used THEN FlutterBaseApp SHALL leverage Dart 3 sealed classes with exhaustive switch expressions
3. WHEN lightweight data is returned THEN FlutterBaseApp SHALL use Dart records (e.g., (String name, int age) instead of Map)
4. WHEN zero-cost abstractions are needed THEN FlutterBaseApp SHALL use extension types (e.g., extension type UserId(String value))
5. WHEN class inheritance is restricted THEN FlutterBaseApp SHALL use final class modifier to prevent extension
6. WHEN class is abstract with known subtypes THEN FlutterBaseApp SHALL use sealed class for exhaustive pattern matching
7. WHEN class defines contract only THEN FlutterBaseApp SHALL use interface class modifier
8. WHEN class is for mixing THEN FlutterBaseApp SHALL use mixin class modifier
9. WHEN null safety is enforced THEN FlutterBaseApp SHALL use non-nullable types by default with explicit ? for nullable
10. WHEN collections are immutable THEN FlutterBaseApp SHALL use const constructors or UnmodifiableListView

### Requirement 11: Documentation and ADRs

**User Story:** As a developer, I want comprehensive documentation, so that I can understand architectural decisions and usage patterns.

#### Acceptance Criteria

1. WHEN significant decision is made THEN FlutterBaseApp SHALL create ADR in docs/adr/ with format ADR-NNN-title.md
2. WHEN public API is exposed THEN FlutterBaseApp SHALL document with /// dartdoc comments including @param, @returns, @throws
3. WHEN architecture changes THEN FlutterBaseApp SHALL update docs/architecture.md with Mermaid diagrams
4. WHEN new feature is added THEN FlutterBaseApp SHALL update README.md with usage examples and screenshots
5. WHEN breaking change occurs THEN FlutterBaseApp SHALL document migration path in CHANGELOG.md following Keep a Changelog format
6. WHEN ADR is created THEN FlutterBaseApp SHALL include Status, Context, Decision, Consequences, and Alternatives sections
7. WHEN API documentation is generated THEN FlutterBaseApp SHALL use dart doc to generate HTML documentation
8. WHEN code examples are provided THEN FlutterBaseApp SHALL include runnable examples in example/ directory
9. WHEN onboarding is needed THEN FlutterBaseApp SHALL provide docs/getting-started.md with step-by-step setup
10. WHEN troubleshooting is needed THEN FlutterBaseApp SHALL provide docs/troubleshooting.md with common issues and solutions

### Requirement 12: Performance Optimization

**User Story:** As a user, I want the application to be performant, so that I have a smooth experience.

#### Acceptance Criteria

1. WHEN widgets are stateless THEN FlutterBaseApp SHALL use const constructors to enable widget caching
2. WHEN lists are rendered THEN FlutterBaseApp SHALL use ListView.builder or SliverList for lazy loading with itemExtent when possible
3. WHEN images are loaded THEN FlutterBaseApp SHALL use CachedNetworkImage with memCacheWidth/memCacheHeight for memory optimization
4. WHEN provider state changes THEN FlutterBaseApp SHALL use ref.watch(provider.select((s) => s.field)) to minimize rebuilds
5. WHEN async operations complete THEN FlutterBaseApp SHALL dispose StreamSubscriptions and AnimationControllers via ref.onDispose
6. WHEN heavy computation is needed THEN FlutterBaseApp SHALL use compute() or Isolate.run() for background processing
7. WHEN animations run THEN FlutterBaseApp SHALL use RepaintBoundary to isolate repaints
8. WHEN app starts THEN FlutterBaseApp SHALL defer non-critical initialization using WidgetsBinding.instance.addPostFrameCallback
9. WHEN large data is processed THEN FlutterBaseApp SHALL use pagination with infinite scroll pattern
10. WHEN memory is constrained THEN FlutterBaseApp SHALL implement didReceiveMemoryWarning handling to clear caches

### Requirement 13: Security Hardening

**User Story:** As a security engineer, I want the application to follow security best practices, so that user data is protected.

#### Acceptance Criteria

1. WHEN sensitive data is stored THEN FlutterBaseApp SHALL use flutter_secure_storage with AES-256 encryption on Android and Keychain on iOS
2. WHEN API calls are made THEN FlutterBaseApp SHALL use HTTPS only with optional certificate pinning via SecurityContext
3. WHEN user input is received THEN FlutterBaseApp SHALL validate using Validators class and sanitize HTML/SQL special characters
4. WHEN tokens are stored THEN FlutterBaseApp SHALL implement secure token rotation with refresh token flow
5. WHEN debug mode is detected THEN FlutterBaseApp SHALL disable sensitive logging using kReleaseMode check
6. WHEN biometric auth is used THEN FlutterBaseApp SHALL use local_auth with fallback to PIN/password
7. WHEN deep links are received THEN FlutterBaseApp SHALL validate URL scheme and host before navigation
8. WHEN WebView is used THEN FlutterBaseApp SHALL disable JavaScript when not needed and validate URLs
9. WHEN clipboard is accessed THEN FlutterBaseApp SHALL clear sensitive data after use with timeout
10. WHEN app goes to background THEN FlutterBaseApp SHALL obscure sensitive screens with secure flag or overlay



### Requirement 14: Generic Use Case Pattern

**User Story:** As a developer, I want generic use cases with type-safe parameters and results, so that business logic is consistent and testable.

#### Acceptance Criteria

1. WHEN use case is created THEN FlutterBaseApp SHALL implement UseCase<Params, Result> interface with call(Params) method
2. WHEN use case has no parameters THEN FlutterBaseApp SHALL use NoParams singleton class
3. WHEN use case returns async result THEN FlutterBaseApp SHALL return Future<Result<T>> with typed success or failure
4. WHEN use case returns stream THEN FlutterBaseApp SHALL implement StreamUseCase<Params, Result> with Stream<Result<T>>
5. WHEN use case validates input THEN FlutterBaseApp SHALL throw ValidationFailure before executing business logic
6. WHEN use case is tested THEN FlutterBaseApp SHALL mock repository dependencies via constructor injection
7. WHEN use case logs execution THEN FlutterBaseApp SHALL log entry, exit, and duration for observability
8. WHEN use case fails THEN FlutterBaseApp SHALL map exceptions to typed AppFailure subclasses

### Requirement 15: Accessibility Compliance

**User Story:** As a user with disabilities, I want the application to be accessible, so that I can use it with assistive technologies.

#### Acceptance Criteria

1. WHEN interactive elements are created THEN FlutterBaseApp SHALL provide Semantics labels for screen readers
2. WHEN images are displayed THEN FlutterBaseApp SHALL provide semanticLabel or excludeFromSemantics
3. WHEN touch targets are created THEN FlutterBaseApp SHALL ensure minimum 48x48 logical pixels size
4. WHEN colors are used THEN FlutterBaseApp SHALL ensure WCAG 2.1 AA contrast ratio of 4.5:1 for text
5. WHEN forms are created THEN FlutterBaseApp SHALL associate labels with inputs and provide error announcements
6. WHEN focus changes THEN FlutterBaseApp SHALL maintain logical focus order and visible focus indicators
7. WHEN animations play THEN FlutterBaseApp SHALL respect MediaQuery.disableAnimations preference
8. WHEN text is displayed THEN FlutterBaseApp SHALL support dynamic type scaling up to 200%

### Requirement 16: Internationalization Enhancement

**User Story:** As a global user, I want the application to support my language and locale, so that I can use it in my preferred language.

#### Acceptance Criteria

1. WHEN app starts THEN FlutterBaseApp SHALL load translations from ARB files via flutter_localizations
2. WHEN locale changes THEN FlutterBaseApp SHALL update all strings immediately without restart
3. WHEN translation is missing THEN FlutterBaseApp SHALL fallback to English (en) as default locale
4. WHEN plurals are needed THEN FlutterBaseApp SHALL use ICU plural syntax in ARB files
5. WHEN dates are formatted THEN FlutterBaseApp SHALL use DateFormat with current locale from intl package
6. WHEN numbers are formatted THEN FlutterBaseApp SHALL use NumberFormat with current locale
7. WHEN RTL languages are used THEN FlutterBaseApp SHALL support right-to-left layout via Directionality
8. WHEN new language is added THEN FlutterBaseApp SHALL require only new ARB file without code changes
9. WHEN currency is displayed THEN FlutterBaseApp SHALL use locale-appropriate currency symbol and format
10. WHEN text contains variables THEN FlutterBaseApp SHALL use named placeholders in ARB (e.g., {userName})

### Requirement 17: Error Boundary and Recovery

**User Story:** As a user, I want the application to handle errors gracefully, so that I can continue using it even when problems occur.

#### Acceptance Criteria

1. WHEN widget throws error THEN FlutterBaseApp SHALL catch via ErrorWidget.builder and display friendly error UI
2. WHEN async error occurs THEN FlutterBaseApp SHALL display error state with retry action via AsyncValue.error
3. WHEN network fails THEN FlutterBaseApp SHALL show offline indicator and queue actions for retry
4. WHEN unhandled error occurs THEN FlutterBaseApp SHALL log to crash reporting service before showing error
5. WHEN error is recoverable THEN FlutterBaseApp SHALL provide clear recovery action (retry, refresh, go back)
6. WHEN error is fatal THEN FlutterBaseApp SHALL provide option to restart app or contact support
7. WHEN error contains sensitive data THEN FlutterBaseApp SHALL sanitize before logging or displaying
8. WHEN multiple errors occur THEN FlutterBaseApp SHALL aggregate and show summary instead of multiple dialogs


### Requirement 18: Build Flavors e Configuração de Ambiente

**User Story:** As a developer, I want separate build configurations for development, staging, and production, so that I can test and deploy safely.

#### Acceptance Criteria

1. WHEN app is built THEN FlutterBaseApp SHALL support three flavors: development, staging, and production
2. WHEN flavor is selected THEN FlutterBaseApp SHALL use flavor-specific app name, bundle ID, and app icon
3. WHEN flavor config is loaded THEN FlutterBaseApp SHALL use FlavorConfig singleton with baseUrl, apiKey, and feature flags
4. WHEN main entry point is created THEN FlutterBaseApp SHALL have main_development.dart, main_staging.dart, and main_production.dart
5. WHEN Android build runs THEN FlutterBaseApp SHALL configure productFlavors in build.gradle with applicationIdSuffix
6. WHEN iOS build runs THEN FlutterBaseApp SHALL configure Xcode schemes with separate bundle identifiers
7. WHEN environment variables differ THEN FlutterBaseApp SHALL load from .env.development, .env.staging, .env.production files
8. WHEN app is installed THEN FlutterBaseApp SHALL allow all three flavors to coexist on same device
9. WHEN flavor is detected THEN FlutterBaseApp SHALL display visual indicator (banner/badge) in non-production builds
10. WHEN API endpoints differ THEN FlutterBaseApp SHALL configure per-flavor base URLs in FlavorConfig

### Requirement 19: App Initialization e Splash Screen

**User Story:** As a user, I want a smooth app startup experience, so that I don't see blank screens or loading delays.

#### Acceptance Criteria

1. WHEN app launches THEN FlutterBaseApp SHALL display native splash screen via flutter_native_splash package
2. WHEN Flutter engine initializes THEN FlutterBaseApp SHALL preserve splash screen until app is ready via FlutterNativeSplash.preserve()
3. WHEN app initialization completes THEN FlutterBaseApp SHALL remove splash screen via FlutterNativeSplash.remove()
4. WHEN initialization runs THEN FlutterBaseApp SHALL execute in order: Firebase, DI, Storage, Auth check, Feature flags
5. WHEN initialization fails THEN FlutterBaseApp SHALL display error screen with retry option
6. WHEN cold start occurs THEN FlutterBaseApp SHALL complete initialization within 2 seconds on mid-range devices
7. WHEN splash screen is displayed THEN FlutterBaseApp SHALL match Flutter loading screen style for seamless transition
8. WHEN app resumes from background THEN FlutterBaseApp SHALL not show splash screen again
9. WHEN initialization progress is tracked THEN FlutterBaseApp SHALL log timing metrics for performance monitoring
10. WHEN deferred initialization is needed THEN FlutterBaseApp SHALL use WidgetsBinding.instance.addPostFrameCallback

### Requirement 20: Crash Reporting e Error Tracking

**User Story:** As a developer, I want comprehensive crash reporting, so that I can identify and fix issues in production.

#### Acceptance Criteria

1. WHEN crash occurs THEN FlutterBaseApp SHALL report to Firebase Crashlytics or Sentry with full stack trace
2. WHEN error is caught THEN FlutterBaseApp SHALL include breadcrumbs showing user actions before crash
3. WHEN crash is reported THEN FlutterBaseApp SHALL include device info, OS version, app version, and flavor
4. WHEN user is identified THEN FlutterBaseApp SHALL associate crashes with anonymized user ID
5. WHEN non-fatal error occurs THEN FlutterBaseApp SHALL log as non-fatal exception with context
6. WHEN Flutter error occurs THEN FlutterBaseApp SHALL capture via FlutterError.onError handler
7. WHEN async error occurs THEN FlutterBaseApp SHALL capture via PlatformDispatcher.instance.onError
8. WHEN Dart error occurs THEN FlutterBaseApp SHALL capture via runZonedGuarded
9. WHEN debug mode is active THEN FlutterBaseApp SHALL log errors to console instead of crash service
10. WHEN crash service is unavailable THEN FlutterBaseApp SHALL queue reports for later submission

### Requirement 21: Feature Flags e Remote Config

**User Story:** As a product manager, I want to control features remotely, so that I can enable/disable features without app updates.

#### Acceptance Criteria

1. WHEN app starts THEN FlutterBaseApp SHALL fetch feature flags from Firebase Remote Config
2. WHEN flag is checked THEN FlutterBaseApp SHALL return cached value if network unavailable
3. WHEN flag changes remotely THEN FlutterBaseApp SHALL update within configurable fetch interval
4. WHEN flag is accessed THEN FlutterBaseApp SHALL use FeatureFlags.isEnabled('feature_name') API
5. WHEN A/B test is configured THEN FlutterBaseApp SHALL support percentage-based rollouts
6. WHEN flag has default value THEN FlutterBaseApp SHALL use default if remote value unavailable
7. WHEN flags are fetched THEN FlutterBaseApp SHALL cache locally for offline access
8. WHEN flag controls UI THEN FlutterBaseApp SHALL rebuild affected widgets on flag change
9. WHEN flag is boolean THEN FlutterBaseApp SHALL support isEnabled check
10. WHEN flag is string/number THEN FlutterBaseApp SHALL support getValue<T> generic accessor

### Requirement 22: Analytics e User Tracking

**User Story:** As a product analyst, I want to track user behavior, so that I can understand how users interact with the app.

#### Acceptance Criteria

1. WHEN screen is viewed THEN FlutterBaseApp SHALL log screen_view event with screen name and class
2. WHEN user action occurs THEN FlutterBaseApp SHALL log custom event with action, category, and label
3. WHEN user property changes THEN FlutterBaseApp SHALL update user properties in analytics
4. WHEN navigation occurs THEN FlutterBaseApp SHALL use NavigatorObserver to auto-track screen views
5. WHEN analytics is initialized THEN FlutterBaseApp SHALL configure Firebase Analytics or equivalent
6. WHEN user opts out THEN FlutterBaseApp SHALL disable analytics collection respecting privacy
7. WHEN event is logged THEN FlutterBaseApp SHALL include timestamp, session ID, and user ID
8. WHEN conversion occurs THEN FlutterBaseApp SHALL log conversion event with value
9. WHEN debug mode is active THEN FlutterBaseApp SHALL enable analytics debug view
10. WHEN batch events are queued THEN FlutterBaseApp SHALL flush on app background or after threshold

### Requirement 23: Deep Linking e App Links

**User Story:** As a user, I want to open specific app screens from external links, so that I can navigate directly to content.

#### Acceptance Criteria

1. WHEN deep link is received THEN FlutterBaseApp SHALL parse URI and navigate to corresponding screen
2. WHEN app link is configured THEN FlutterBaseApp SHALL verify domain ownership via assetlinks.json (Android) and apple-app-site-association (iOS)
3. WHEN link contains parameters THEN FlutterBaseApp SHALL extract and pass to destination screen
4. WHEN link requires auth THEN FlutterBaseApp SHALL redirect to login then to original destination
5. WHEN invalid link is received THEN FlutterBaseApp SHALL navigate to fallback screen with error message
6. WHEN app is not installed THEN FlutterBaseApp SHALL configure deferred deep linking via Firebase Dynamic Links or equivalent
7. WHEN link is shared THEN FlutterBaseApp SHALL generate shareable deep link with tracking parameters
8. WHEN go_router handles link THEN FlutterBaseApp SHALL use redirect logic for auth-protected routes
9. WHEN link scheme is custom THEN FlutterBaseApp SHALL support myapp:// scheme for development
10. WHEN link is universal THEN FlutterBaseApp SHALL support https://myapp.com/path format for production

### Requirement 24: Push Notifications

**User Story:** As a user, I want to receive push notifications, so that I can stay informed about important updates.

#### Acceptance Criteria

1. WHEN app starts THEN FlutterBaseApp SHALL request notification permission via firebase_messaging
2. WHEN permission is granted THEN FlutterBaseApp SHALL register FCM token with backend
3. WHEN notification is received in foreground THEN FlutterBaseApp SHALL display local notification or in-app banner
4. WHEN notification is received in background THEN FlutterBaseApp SHALL display system notification
5. WHEN notification is tapped THEN FlutterBaseApp SHALL navigate to relevant screen via deep link
6. WHEN token refreshes THEN FlutterBaseApp SHALL update token on backend
7. WHEN notification contains data THEN FlutterBaseApp SHALL parse and handle payload appropriately
8. WHEN notification channels are needed THEN FlutterBaseApp SHALL configure Android notification channels
9. WHEN user opts out THEN FlutterBaseApp SHALL unsubscribe from topics and disable notifications
10. WHEN scheduled notification is needed THEN FlutterBaseApp SHALL use flutter_local_notifications for local scheduling

### Requirement 25: Makefile e Scripts de Automação

**User Story:** As a developer, I want automation scripts, so that I can run common tasks with simple commands.

#### Acceptance Criteria

1. WHEN Makefile exists THEN FlutterBaseApp SHALL provide targets for build, test, clean, and run
2. WHEN code generation is needed THEN FlutterBaseApp SHALL provide `make build` target running build_runner
3. WHEN tests run THEN FlutterBaseApp SHALL provide `make test` and `make test-coverage` targets
4. WHEN app is built THEN FlutterBaseApp SHALL provide `make apk-dev`, `make apk-prod`, `make ipa-dev`, `make ipa-prod` targets
5. WHEN code is formatted THEN FlutterBaseApp SHALL provide `make format` and `make check-format` targets
6. WHEN code is analyzed THEN FlutterBaseApp SHALL provide `make analyze` target with strict rules
7. WHEN dependencies are updated THEN FlutterBaseApp SHALL provide `make upgrade` target
8. WHEN Docker is used THEN FlutterBaseApp SHALL provide `make docker-build` and `make docker-run` targets
9. WHEN clean is needed THEN FlutterBaseApp SHALL provide `make clean` removing build artifacts and generated files
10. WHEN help is needed THEN FlutterBaseApp SHALL provide `make help` listing all available targets

