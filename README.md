<p align="center">
  <img src="logo.png" alt="Flutter Base 2025" width="200"/>
</p>

<h1 align="center">Flutter Base 2025</h1>

<p align="center">
  <strong>Production-Ready Flutter Template with Clean Architecture</strong>
</p>

<p align="center">
  <a href="#features">Features</a> |
  <a href="#architecture">Architecture</a> |
  <a href="#modules">Modules</a> |
  <a href="#quick-start">Quick Start</a> |
  <a href="#code-examples">Code Examples</a> |
  <a href="#testing">Testing</a> |
  <a href="#cicd">CI/CD</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Riverpod-3.0+-00D1B2" alt="Riverpod"/>
  <img src="https://img.shields.io/badge/Tests-650+-brightgreen" alt="Tests"/>
  <img src="https://img.shields.io/badge/Coverage-80%25+-brightgreen" alt="Coverage"/>
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License"/>
  <img src="https://img.shields.io/badge/Version-3.4.0-blue" alt="Version"/>
</p>

---

## Overview

Flutter Base 2025 is a **production-ready template** implementing **Clean Architecture** with modern best practices for 2025. Designed as a pure frontend consuming REST/gRPC APIs, it provides a solid foundation for scalable, maintainable, and testable mobile applications.

### Key Highlights

- **650+ automated tests** (unit, property, integration, smoke, architecture)
- **100% type-safe** generic patterns with Result monad
- **Multi-layer caching** (Memory → SQLite → Remote)
- **Comprehensive security** (OWASP Top 10, input sanitization, certificate pinning)
- **Full observability** (logging, analytics, crash reporting, performance monitoring)
- **Multi-environment support** (development, staging, production)
- **CI/CD ready** with GitHub Actions workflows

### System Context (C4 Level 1)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              SYSTEM CONTEXT                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│    ┌──────────┐         ┌─────────────────────┐         ┌──────────────┐   │
│    │          │         │                     │         │              │   │
│    │   User   │────────▶│  Flutter Base 2025  │────────▶│  Backend API │   │
│    │          │         │     (Frontend)      │         │   (Python)   │   │
│    └──────────┘         └─────────────────────┘         └──────────────┘   │
│                                   │                            │           │
│                                   │                            │           │
│                                   ▼                            ▼           │
│                         ┌─────────────────┐          ┌─────────────────┐   │
│                         │  Local Storage  │          │    Database     │   │
│                         │  (SQLite/Drift) │          │   (PostgreSQL)  │   │
│                         └─────────────────┘          └─────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Responsibilities

| Component | This Project | Backend API |
|-----------|:------------:|:-----------:|
| UI/UX Components | Yes | - |
| State Management | Yes | - |
| API Consumption | Yes | - |
| Token Storage | Yes | - |
| Local Cache | Yes | - |
| Business Logic | - | Yes |
| Authentication | - | Yes |
| Data Persistence | - | Yes |
| Authorization | - | Yes |

---

## Features

### Core Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.38+ | UI Framework with Dart 3.10 dot shorthands |
| Riverpod | 3.0.3+ | State Management with code generation |
| go_router | 17.0.0+ | Declarative navigation with type-safety |
| Dio | 5.7.0+ | HTTP client with interceptors |
| Drift | 2.29.0+ | Type-safe SQLite with reactive queries |
| Freezed | 3.2.3+ | Immutable data classes and unions |
| fpdart | 1.2.0+ | Functional programming utilities |

### Generic Patterns (100% Type-Safe)

| Pattern | Description |
|---------|-------------|
| `Result<T>` | Monad with full laws (left/right identity, associativity) |
| `BaseRepository<T, ID>` | CRUD operations with pagination and streaming |
| `ApiRepository<T, D, ID>` | DTO-Entity conversion with error mapping |
| `DriftRepository<T, ID>` | Type-safe SQLite operations |
| `CacheDataSource<T>` | TTL expiration + LRU eviction |
| `CompositeRepository<T, ID>` | Cache -> Local -> Remote strategy |
| `UseCase<Params, R>` | Business logic encapsulation |
| `CompositeUseCase` | Use case chaining |
| `PaginationNotifier<T>` | Infinite scroll with state preservation |

### Security Features

| Feature | Implementation |
|---------|----------------|
| Secure Storage | flutter_secure_storage for tokens |
| Input Sanitization | XSS/Injection prevention |
| Certificate Pinning | SSL/TLS validation |
| No Hardcoded Secrets | Environment variables only |
| OWASP Compliance | Top 10 vulnerabilities addressed |

---

## Architecture

### Container Diagram (C4 Level 2)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUTTER BASE 2025                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        PRESENTATION LAYER                             │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────────────────────────┐  │  │
│  │  │    Pages    │  │   Widgets   │  │   Providers (Riverpod 3.0)    │  │  │
│  │  │             │  │             │  │                               │  │  │
│  │  │  - HomePage │  │  - Buttons  │  │  - AuthNotifier               │  │  │
│  │  │  - Login    │  │  - Cards    │  │  - UserNotifier               │  │  │
│  │  │  - Profile  │  │  - Forms    │  │  - SettingsNotifier           │  │  │
│  │  └─────────────┘  └─────────────┘  └───────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                          DOMAIN LAYER                                 │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────────────────────────┐  │  │
│  │  │  Entities   │  │  Use Cases  │  │   Repository Interfaces       │  │  │
│  │  │             │  │             │  │                               │  │  │
│  │  │  - User     │  │  - Login    │  │  - IAuthRepository            │  │  │
│  │  │  - Product  │  │  - Logout   │  │  - IUserRepository            │  │  │
│  │  │  - Order    │  │  - GetUser  │  │  - IProductRepository         │  │  │
│  │  └─────────────┘  └─────────────┘  └───────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                           DATA LAYER                                  │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────────────────────────┐  │  │
│  │  │    DTOs     │  │ DataSources │  │   Repository Implementations  │  │  │
│  │  │             │  │             │  │                               │  │  │
│  │  │  - UserDTO  │  │  - Remote   │  │  - AuthRepositoryImpl         │  │  │
│  │  │  - ApiResp  │  │  - Local    │  │  - UserRepositoryImpl         │  │  │
│  │  │  - Request  │  │  - Cache    │  │  - CompositeRepository        │  │  │
│  │  └─────────────┘  └─────────────┘  └───────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATA FLOW                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   User Action                                                               │
│       │                                                                     │
│       ▼                                                                     │
│   ┌─────────┐    ┌─────────┐    ┌────────────┐    ┌────────────┐           │
│   │ Widget  │───▶│Provider │───▶│  UseCase   │───▶│ Repository │           │
│   └─────────┘    └─────────┘    └────────────┘    └────────────┘           │
│                                                          │                  │
│                                                          ▼                  │
│                                        ┌─────────────────────────────────┐  │
│                                        │      CompositeRepository        │  │
│                                        │                                 │  │
│                                        │  1. Check Cache (Memory/LRU)    │  │
│                                        │         │                       │  │
│                                        │         ▼ miss                  │  │
│                                        │  2. Check Local (Drift/SQLite)  │  │
│                                        │         │                       │  │
│                                        │         ▼ miss                  │  │
│                                        │  3. Fetch Remote (Dio/API)      │  │
│                                        │         │                       │  │
│                                        │         ▼                       │  │
│                                        │  4. Update Local + Cache        │  │
│                                        └─────────────────────────────────┘  │
│                                                          │                  │
│                                                          ▼                  │
│   ┌─────────┐    ┌─────────┐    ┌────────────┐    ┌────────────┐           │
│   │   UI    │◀───│  State  │◀───│ Result<T>  │◀───│   Data     │           │
│   │ Update  │    │ Update  │    │ Success/   │    │  Response  │           │
│   └─────────┘    └─────────┘    │  Failure   │    └────────────┘           │
│                                 └────────────┘                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Layer Dependencies

| Layer | Contains | Depends On | Rules |
|-------|----------|------------|-------|
| Presentation | Pages, Widgets, Providers | Domain | No business logic |
| Domain | Entities, UseCases, Interfaces | Nothing | Pure Dart only |
| Data | DTOs, DataSources, Repositories | Domain | Implements interfaces |

---

## Project Structure

```text
flutter_base_2025/
├── lib/
│   ├── app/                     # App bootstrap and configuration
│   │   ├── app.dart             # Main app widget (FlutterBaseApp)
│   │   ├── bootstrap.dart       # App initialization logic
│   │   └── app_barrel.dart      # Barrel exports
│   ├── core/                    # Core infrastructure (see Modules section)
│   │   ├── base/                # Generic patterns (Repository, UseCase, DTO)
│   │   ├── cache/               # Caching (Hive, LRU, TTL)
│   │   ├── config/              # App configuration and feature flags
│   │   ├── constants/           # Application constants
│   │   ├── database/            # Drift/SQLite database
│   │   ├── di/                  # Dependency injection providers
│   │   ├── errors/              # Exception/Failure hierarchy
│   │   ├── grpc/                # gRPC client and interceptors
│   │   ├── init/                # App initialization
│   │   ├── integrations/        # Platform integrations
│   │   ├── network/             # HTTP client, WebSocket, GraphQL
│   │   ├── observability/       # Logging, analytics, crash reporting
│   │   ├── router/              # go_router configuration
│   │   ├── security/            # Security utilities
│   │   ├── services/            # Platform services
│   │   ├── storage/             # Secure token storage
│   │   ├── theme/               # Material 3 theming
│   │   ├── utils/               # Result monad, extensions
│   │   └── core.dart            # Barrel file for all core exports
│   ├── features/                # Feature modules (Clean Architecture)
│   │   ├── auth/                # Authentication feature
│   │   │   ├── data/            # DTOs, DataSources, Repositories
│   │   │   ├── domain/          # Entities, UseCases, Interfaces
│   │   │   ├── presentation/    # Pages, Widgets, Providers
│   │   │   └── auth.dart        # Feature barrel file
│   │   ├── home/                # Home feature
│   │   ├── settings/            # Settings feature
│   │   └── features.dart        # Features barrel file
│   ├── shared/                  # Shared components
│   │   ├── providers/           # Global state providers
│   │   ├── widgets/             # Reusable UI components
│   │   └── shared.dart          # Barrel file
│   ├── main.dart                # Default entry point
│   ├── main_development.dart    # Development flavor
│   ├── main_staging.dart        # Staging flavor
│   └── main_production.dart     # Production flavor
├── test/
│   ├── architecture/            # Architecture validation tests
│   ├── golden/                  # Visual regression tests
│   ├── helpers/                 # Test utilities and generators
│   ├── integration/             # Integration tests
│   ├── property/                # Property-based tests (36+ files)
│   ├── smoke/                   # Smoke tests
│   └── unit/                    # Unit tests
├── integration_test/            # E2E tests with Patrol
├── docs/                        # Documentation
│   ├── adr/                     # Architecture Decision Records
│   └── ARCHITECTURE_REFINEMENT_REPORT.md
├── .github/workflows/           # CI/CD workflows
├── android/                     # Android platform
├── ios/                         # iOS platform
├── pubspec.yaml                 # Dependencies
├── analysis_options.yaml        # Linting rules
└── Makefile                     # Development commands
```

---

## Modules

### Core Modules (`lib/core/`)

#### Base Classes (`core/base/`)

Generic, type-safe abstractions for common patterns:

| Class | Description | Usage |
|-------|-------------|-------|
| `Result<T>` | Functional error handling monad | `Result.success(data)` / `Result.failure(error)` |
| `BaseRepository<T, ID>` | CRUD interface with pagination | Implement for each entity |
| `ApiRepository<T, D, ID>` | REST API repository with DTO mapping | Extends BaseRepository |
| `DriftRepository<T, D, C>` | SQLite repository with Drift | Local persistence |
| `CompositeRepository<T, ID>` | Cache → Local → Remote strategy | Multi-layer data access |
| `UseCase<Params, R>` | Single responsibility use case | Business logic encapsulation |
| `NoParamsUseCase<R>` | Use case without parameters | Simple operations |
| `StreamUseCase<Params, R>` | Reactive use case with streams | Real-time data |
| `CompositeUseCase` | Chain multiple use cases | Complex workflows |
| `CancellableUseCase` | Use case with cancellation support | Long-running operations |
| `BaseDto<E>` | DTO with entity conversion | `toEntity()` / `fromEntity()` |
| `PaginatedList<T>` | Paginated data container | Infinite scroll support |
| `PaginationNotifier<T>` | State management for pagination | Riverpod integration |

#### Network (`core/network/`)

HTTP, WebSocket, and GraphQL clients:

| Component | Description | Features |
|-----------|-------------|----------|
| `ApiClient` | Dio-based HTTP client | Interceptors, retry, timeout |
| `ResilientApiClient` | Fault-tolerant HTTP client | Circuit breaker, fallback |
| `CircuitBreaker` | Failure protection pattern | Open/closed/half-open states |
| `WebSocketClient<T>` | Type-safe WebSocket | Auto-reconnect, backoff |
| `GraphQLClient` | GraphQL operations | Queries, mutations, subscriptions |

**Interceptors:**

- `AuthInterceptor` - Token injection and refresh
- `LoggingInterceptor` - Request/response logging
- `RetryInterceptor` - Exponential backoff retry
- `CacheInterceptor` - Response caching

#### Cache (`core/cache/`)

Multi-level caching with TTL and LRU eviction:

| Component | Description | Storage |
|-----------|-------------|---------|
| `CacheDataSource<T>` | Generic cache interface | Abstract |
| `HiveCacheDataSource<T>` | Hive-based cache | Persistent |
| `MemoryCacheDataSource<T>` | In-memory LRU cache | Volatile |
| `CacheEntry<T>` | Cache item with metadata | TTL, timestamps |
| `CacheRepository<T, ID>` | Repository with caching | Composite pattern |

#### Errors (`core/errors/`)

Comprehensive error handling hierarchy:

```dart
// Exception types (infrastructure layer)
abstract class AppException implements Exception {
  String get message;
  String? get code;
}

class NetworkException extends AppException { }
class ServerException extends AppException { }
class CacheException extends AppException { }
class AuthException extends AppException { }
class ValidationException extends AppException { }

// Failure types (domain layer)
sealed class AppFailure {
  String get message;
}

class NetworkFailure extends AppFailure { }
class ServerFailure extends AppFailure { }
class CacheFailure extends AppFailure { }
class AuthFailure extends AppFailure { }
class ValidationFailure extends AppFailure { }
class NotFoundFailure extends AppFailure { }
class UnknownFailure extends AppFailure { }
```

#### Security (`core/security/`)

OWASP-compliant security utilities:

| Component | Description | Protection |
|-----------|-------------|------------|
| `InputSanitizer` | XSS/Injection prevention | HTML, SQL, script tags |
| `DeepLinkValidator` | URL validation | Scheme, host, path whitelist |
| `SecureRandom` | Cryptographic random | Tokens, IDs, salts |
| `CertificatePinningService` | SSL/TLS pinning | MITM protection |
| `SecurityUtils` | General security helpers | Hashing, encoding |

#### Observability (`core/observability/`)

Full-stack monitoring:

| Component | Description | Backend |
|-----------|-------------|---------|
| `AppLogger` | Structured logging | Console, file |
| `AnalyticsService` | Event tracking | Firebase, Mixpanel |
| `CrashReporter` | Error reporting | Sentry, Crashlytics |
| `PerformanceMonitor` | Performance metrics | Traces, spans |

#### Theme (`core/theme/`)

Material 3 theming with accessibility:

| Component | Description | Features |
|-----------|-------------|----------|
| `AppTheme` | Light/dark themes | Material 3, dynamic colors |
| `AppColors` | Color palette | Semantic colors |
| `AppTypography` | Text styles | Responsive scaling |
| `AccessibilityService` | A11y utilities | Contrast, font scaling |

#### gRPC (`core/grpc/`)

Protocol Buffers support:

| Component | Description | Features |
|-----------|-------------|----------|
| `GrpcClient` | gRPC channel manager | Connection pooling |
| `GrpcConfig` | Configuration | Timeouts, interceptors |
| `GrpcStatusMapper` | Error mapping | Status code → Failure |

---

### Features (`lib/features/`)

Each feature follows **Clean Architecture** with three layers:

```text
feature/
├── data/                    # Data layer
│   ├── data_sources/        # Remote and local data sources
│   ├── dtos/                # Data Transfer Objects
│   └── repositories/        # Repository implementations
├── domain/                  # Domain layer (pure Dart)
│   ├── entities/            # Business entities
│   ├── repositories/        # Repository interfaces
│   └── use_cases/           # Business logic
├── presentation/            # Presentation layer
│   ├── pages/               # Screen widgets
│   ├── widgets/             # Feature-specific widgets
│   └── providers/           # Riverpod providers
└── feature.dart             # Barrel file for exports
```

#### Auth Feature (`features/auth/`)

Complete authentication flow:

**Entities:**

- `User` - User domain entity
- `UserRole` - Role enum (admin, user, guest)
- `Permission` - Permission definitions

**DTOs:**

- `UserDto` - User serialization (Freezed + JSON)
- `AuthResponseDto` - Login response with tokens

**Use Cases:**

- `LoginUseCase` - Email/password authentication
- `LogoutUseCase` - Session termination
- `RefreshTokenUseCase` - Token refresh

**Providers:**

- `authProvider` - Authentication state (AsyncNotifier)
- `currentUserProvider` - Current user stream
- `isAuthenticatedProvider` - Auth status

---

### Shared (`lib/shared/`)

#### Providers (`shared/providers/`)

Global state management:

| Provider | Type | Description |
|----------|------|-------------|
| `themeProvider` | `StateNotifier<ThemeMode>` | Light/dark/system theme |
| `localeProvider` | `StateNotifier<Locale>` | App localization |
| `connectivityProvider` | `StreamProvider<bool>` | Network status |
| `directionalityProvider` | `Provider<TextDirection>` | RTL/LTR support |
| `paginationNotifierProvider` | `AsyncNotifierProvider` | Paginated lists |

#### Widgets (`shared/widgets/`)

Reusable UI components:

| Widget | Description | Features |
|--------|-------------|----------|
| `AccessibleButton` | A11y-compliant button | Semantics, focus |
| `AnimationWidgets` | Animated components | Fade, slide, scale |
| `ConnectivityIndicator` | Network status banner | Auto-hide |
| `ErrorBoundaryWidget` | Error catching wrapper | Fallback UI |
| `ErrorView` | Error display | Retry action |
| `InfiniteList<T>` | Paginated list | Load more, refresh |
| `InitErrorScreen` | Initialization error | Retry, details |
| `MainShell` | Bottom navigation shell | go_router integration |
| `PredictivePopScope` | Back gesture handling | iOS/Android |
| `ResponsiveBuilder` | Responsive layouts | Mobile/tablet/desktop |
| `SkeletonWidget` | Loading placeholders | Shimmer effect |

---

## Quick Start

### Prerequisites

| Requirement | Version |
|-------------|---------|
| Flutter SDK | 3.38+ |
| Dart SDK | 3.10+ |
| Android Studio / VS Code | Latest |
| Git | 2.x+ |
| Java (for Android) | 17+ |

### Installation

```bash
# Clone repository
git clone https://github.com/your-org/flutter_base_2025.git
cd flutter_base_2025

# Install dependencies
flutter pub get

# Copy environment file
cp .env.example .env.development

# Generate code (freezed, riverpod, drift)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run --flavor development -t lib/main_development.dart
```

### Make Commands

```bash
make help           # List all commands
make build          # Generate code
make watch          # Watch mode for code generation
make test           # Run all tests
make test-coverage  # Tests with coverage report
make test-property  # Property-based tests only
make analyze        # Static analysis
make format         # Format code
make lint           # Analyze + format check
make run-dev        # Run development flavor
make run-staging    # Run staging flavor
make run-prod       # Run production flavor
make apk-dev        # Build development APK
make apk-prod       # Build production APK
make web            # Build web release
make docker-build   # Build Docker image
make setup          # Full project setup
```

---

## Environment Configuration

### Environment Files

| File | Purpose | Git Tracked |
|------|---------|:-----------:|
| `.env.example` | Template with documentation | Yes |
| `.env.development` | Local development | No |
| `.env.staging` | Staging/QA environment | No |
| `.env.production` | Production environment | No |

### Variables

```bash
# API Configuration
API_BASE_URL=https://api.example.com/api/v1
APP_NAME=My App

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
ENABLE_PERFORMANCE_MONITORING=true
ENABLE_DEBUG_LOGGING=false

# Optional Services
SENTRY_DSN=https://xxx@sentry.io/xxx
```

### Flavors

| Flavor | Entry Point | Build Mode | Logging |
|--------|-------------|------------|---------|
| development | `main_development.dart` | Debug | Verbose |
| staging | `main_staging.dart` | Profile | Standard |
| production | `main_production.dart` | Release | Minimal |

---

## Testing

### Test Categories

| Category | Location | Purpose |
|----------|----------|---------|
| Property | `test/property/` | Mathematical properties (36 files) |
| Unit | `test/unit/` | Individual components |
| Widget | `test/widget/` | UI components |
| Golden | `test/golden/` | Visual regression |
| Integration | `integration_test/` | E2E with Patrol |
| Smoke | `test/smoke/` | Critical paths |

### Property-Based Tests

| Property | File | Validates |
|----------|------|-----------|
| Result Monad Laws | `result_test.dart` | Left/Right Identity, Associativity |
| DTO Round-Trip | `dto_test.dart` | JSON serialization consistency |
| Validation Composition | `validation_test.dart` | Error aggregation |
| Cache TTL/LRU | `cache_test.dart` | Expiration and eviction |
| Exception Mapping | `exception_mapping_test.dart` | Exhaustive mapping |
| WCAG Contrast | `accessibility_test.dart` | Ratio symmetry |
| Pagination State | `pagination_notifier_test.dart` | Error preservation |
| WebSocket Round-Trip | `websocket_test.dart` | Message serialization |
| Feature Flags | `feature_flags_test.dart` | Variant persistence |

### Running Tests

```bash
# All tests
flutter test

# Property-based tests
flutter test test/property/

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Integration tests (Patrol)
patrol test

# Golden tests
flutter test test/golden/ --update-goldens
```

---

## CI/CD

### Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| `ci.yml` | PR, Push | Analyze, test, build |
| `ci-matrix.yml` | PR to main | Multi-version/platform testing |
| `integration-tests.yml` | PR, Push | Patrol E2E tests |
| `security.yml` | PR, Push, Weekly | CodeQL, gitleaks, trivy |
| `code-review.yml` | PR | Automated code review |
| `pr-labeler.yml` | PR | Auto-labeling |
| `golden-tests.yml` | PR (widget changes) | Visual regression |
| `release.yml` | Tag v* | Multi-platform builds |
| `release-drafter.yml` | Push to main | Draft release notes |
| `stale.yml` | Daily | Manage stale issues/PRs |
| `docs.yml` | Push to main | Generate documentation |

### Required Secrets

| Secret | Required | Description |
|--------|:--------:|-------------|
| `CODECOV_TOKEN` | Optional | Coverage reports |
| `SLACK_WEBHOOK_URL` | Optional | Notifications |
| `ANDROID_KEYSTORE_BASE64` | Release | Android signing |
| `ANDROID_KEY_ALIAS` | Release | Keystore alias |
| `ANDROID_KEY_PASSWORD` | Release | Key password |
| `ANDROID_STORE_PASSWORD` | Release | Store password |
| `GITLEAKS_LICENSE` | Optional | Secrets scanning |

### Generating Keystore Secret

```bash
# Generate keystore
keytool -genkey -v -keystore release.keystore \
  -alias your-alias -keyalg RSA -keysize 2048 -validity 10000

# Encode to base64
base64 -i release.keystore | pbcopy  # macOS
base64 release.keystore | clip       # Windows
base64 release.keystore              # Linux
```

---

## Code Examples

### Result Monad

```dart
// Basic usage - handling success and failure
final result = await repository.getUser(id);
result.fold(
  (failure) => showError(failure.message),
  (user) => showUser(user),
);

// Chaining with flatMap (monadic composition)
final result = await repository.getUser(id)
  .flatMap((user) => repository.getProfile(user.id))
  .flatMap((profile) => repository.getSettings(profile.id));

// Combining multiple results
final combined = Result.zip(userResult, profileResult);

// Map transformation
final nameResult = userResult.map((user) => user.name);

// Get value with default
final user = result.getOrElse(() => User.empty());

// Get value or throw
final user = result.getOrThrow(); // throws if failure

// Check status
if (result.isSuccess) {
  print(result.valueOrNull);
}
```

### Repository Pattern

```dart
// Generic repository interface
abstract interface class BaseRepository<T, ID> {
  Future<Result<T>> getById(ID id);
  Future<Result<PaginatedList<T>>> getAll({int page, int pageSize});
  Future<Result<T>> create(T entity);
  Future<Result<T>> update(T entity);
  Future<Result<void>> delete(ID id);
  Stream<List<T>> watchAll();
}

// Composite repository with multi-layer caching
final repository = CompositeRepository<User, String>(
  remote: apiRepository,        // REST API
  local: driftRepository,       // SQLite
  cache: memoryCacheDataSource, // Memory LRU
  cacheTtl: Duration(minutes: 5),
);

// Usage - automatically checks cache → local → remote
final result = await repository.getById('user-123');
```

### Use Cases

```dart
// Define a use case
class GetUserUseCase implements UseCase<String, User> {
  GetUserUseCase(this._repository);
  final UserRepository _repository;

  @override
  Future<Result<User>> call(String userId) {
    return _repository.getById(userId);
  }
}

// Use case without parameters
class GetCurrentUserUseCase implements NoParamsUseCase<User> {
  GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<User>> call() {
    return _repository.getCurrentUser();
  }
}

// Stream use case for real-time data
class WatchUsersUseCase implements StreamUseCase<void, List<User>> {
  WatchUsersUseCase(this._repository);
  final UserRepository _repository;

  @override
  Stream<Result<List<User>>> call(void params) {
    return _repository.watchAll().map(Result.success);
  }
}

// Cancellable use case
class SearchUseCase extends CancellableUseCase<String, List<Product>> {
  @override
  Future<Result<List<Product>>> execute(
    String query,
    CancellationToken token,
  ) async {
    if (token.isCancelled) return Result.failure(CancelledFailure());
    return _repository.search(query);
  }
}
```

### Riverpod Providers

```dart
// AsyncNotifier for complex state
@riverpod
class Auth extends _$Auth {
  @override
  Future<User?> build() async {
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    if (token == null) return null;
    return ref.read(authRepositoryProvider).getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(loginUseCaseProvider)(
      LoginParams(email: email, password: password),
    );
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (user) => AsyncData(user),
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)();
    state = const AsyncData(null);
  }
}

// Simple provider
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authProvider).valueOrNull != null;
}

// Provider with dependencies
@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(
    remote: ref.read(userRemoteDataSourceProvider),
    local: ref.read(userLocalDataSourceProvider),
  );
}
```

### DTOs with Freezed

```dart
@freezed
class UserDto with _$UserDto implements BaseDto<User> {
  const factory UserDto({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    @Default(UserRole.user) UserRole role,
    required DateTime createdAt,
  }) = _UserDto;

  const UserDto._();

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  // Convert to domain entity
  @override
  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        role: role,
        createdAt: createdAt,
      );

  // Create from domain entity
  static UserDto fromEntity(User entity) => UserDto(
        id: entity.id,
        email: entity.email,
        name: entity.name,
        avatarUrl: entity.avatarUrl,
        role: entity.role,
        createdAt: entity.createdAt,
      );
}
```

### Validation

```dart
// Compose validators
final emailValidator = TypedValidators.compose<String>([
  TypedValidators.required(fieldName: 'email'),
  TypedValidators.email(),
  TypedValidators.minLength(fieldName: 'email', minLength: 5),
]);

final result = emailValidator.validate(email);
result.fold(
  (errors) => showErrors(errors),
  (_) => submitForm(),
);

// Form controller with validation
final formController = FormController({
  'email': emailValidator,
  'password': TypedValidators.compose([
    TypedValidators.required(fieldName: 'password'),
    TypedValidators.minLength(fieldName: 'password', minLength: 8),
  ]),
});

// Validate all fields
final isValid = formController.validateAll();
```

### Pagination

```dart
// Using InfiniteList widget
InfiniteList<Product>(
  items: products,
  hasMore: hasMore,
  isLoading: isLoading,
  onLoadMore: () => ref.read(productsProvider.notifier).loadMore(),
  itemBuilder: (context, product, index) => ProductCard(product: product),
  loadingBuilder: (context) => const SkeletonWidget(),
  emptyBuilder: (context) => const EmptyState(),
  errorBuilder: (context, error) => ErrorView(
    error: error,
    onRetry: () => ref.refresh(productsProvider),
  ),
);

// PaginationNotifier for state management
@riverpod
class Products extends _$Products with PaginationNotifier<Product> {
  @override
  Future<PaginatedList<Product>> fetchPage(int page, int pageSize) {
    return ref.read(productRepositoryProvider).getAll(
      page: page,
      pageSize: pageSize,
    );
  }
}
```

### Security

```dart
// Input sanitization
final sanitizer = ref.read(inputSanitizerProvider);
final safeInput = sanitizer.sanitize(userInput);
final safeHtml = sanitizer.sanitizeHtml(htmlContent);

// Deep link validation
final validator = ref.read(deepLinkValidatorProvider);
if (validator.isValidDeepLink(uri)) {
  handleDeepLink(uri);
}

// Secure random generation
final secureRandom = ref.read(secureRandomProvider);
final token = secureRandom.generateToken(32);
final uuid = secureRandom.generateUuid();
```

### Routing with go_router

```dart
// Route configuration
final router = GoRouter(
  initialLocation: '/',
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    
    if (!isAuthenticated && !isAuthRoute) {
      return '/auth/login';
    }
    if (isAuthenticated && isAuthRoute) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);
```

---

## Barrel Files (Simplified Imports)

The project uses barrel files for cleaner imports:

```dart
// Instead of multiple imports:
import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_base_2025/core/base/base_repository.dart';

// Use single barrel import:
import 'package:flutter_base_2025/core/core.dart';

// Feature imports:
import 'package:flutter_base_2025/features/auth/auth.dart';
import 'package:flutter_base_2025/features/features.dart';

// Shared imports:
import 'package:flutter_base_2025/shared/shared.dart';
```

---

## Dependencies

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | 3.0.3+ | State management |
| `riverpod_annotation` | 3.0.2+ | Code generation |
| `go_router` | 17.0.0+ | Navigation |
| `dio` | 5.7.0+ | HTTP client |
| `drift` | 2.29.0+ | SQLite ORM |
| `hive_flutter` | 1.1.0+ | NoSQL cache |
| `freezed_annotation` | 3.2.3+ | Immutable classes |
| `json_annotation` | 4.9.0+ | JSON serialization |
| `flutter_secure_storage` | 9.2.4+ | Secure storage |
| `connectivity_plus` | 6.1.5+ | Network status |
| `grpc` | 4.1.0+ | gRPC client |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | 2.4.15+ | Code generation |
| `freezed` | 3.2.3+ | Immutable classes |
| `json_serializable` | 6.11.2+ | JSON codegen |
| `riverpod_generator` | 3.0.2+ | Provider codegen |
| `drift_dev` | 2.29.0+ | Drift codegen |
| `mocktail` | 1.0.4+ | Mocking |
| `glados` | 0.7.0+ | Property testing |
| `patrol` | 3.20.0+ | E2E testing |

---

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture](docs/architecture.md) | System design and patterns |
| [Getting Started](docs/getting-started.md) | Setup guide |
| [Deployment](docs/deployment.md) | CI/CD and release |
| [Flavors Setup](docs/flavors-setup.md) | Environment configuration |
| [App Links](docs/app-links-setup.md) | Deep linking setup |
| [Architecture Refinement](docs/ARCHITECTURE_REFINEMENT_REPORT.md) | Structure analysis |

### Architecture Decision Records

| ADR | Title |
|-----|-------|
| [ADR-001](docs/adr/ADR-001-clean-architecture.md) | Clean Architecture |
| [ADR-002](docs/adr/ADR-002-riverpod-migration.md) | Riverpod 3.0 Migration |
| [ADR-003](docs/adr/ADR-003-api-first-frontend.md) | API-First Frontend |
| [ADR-007](docs/adr/ADR-007-cicd-github-actions.md) | CI/CD with GitHub Actions |
| [ADR-011](docs/adr/ADR-011-property-based-testing.md) | Property-Based Testing |
| [ADR-012](docs/adr/ADR-012-docker-deployment.md) | Docker Deployment |
| [ADR-013](docs/adr/ADR-013-environment-security.md) | Environment Security |

---

## Test Summary

| Category | Files | Tests | Coverage |
|----------|-------|-------|----------|
| Unit | 6 | 81 | Core logic |
| Property | 36+ | 533 | Mathematical properties |
| Integration | 1 | 14 | Layer integration |
| Architecture | 2 | 10 | Structure validation |
| Smoke | 1 | 12 | Critical paths |
| **Total** | **46+** | **650+** | **80%+** |

### Property-Based Test Coverage

| Domain | Properties Tested |
|--------|------------------|
| Result Monad | Left/Right Identity, Associativity, Functor laws |
| DTOs | Round-trip serialization, Entity mapping |
| Validation | Composition, Error aggregation |
| Cache | TTL expiration, LRU eviction |
| Pagination | hasMore calculation, State preservation |
| WebSocket | Message serialization, Reconnection backoff |
| Security | Input sanitization, Deep link validation |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention

```text
feat: add new feature
fix: bug fix
docs: documentation changes
style: formatting, missing semi colons
refactor: code restructuring
test: adding tests
chore: maintenance tasks
```

### Code Standards

| Rule | Value |
|------|-------|
| Max file size | 400 lines |
| Max function size | 50 lines |
| Max cyclomatic complexity | 10 |
| Max nesting depth | 3 levels |
| Test coverage | 80%+ |
| Property test iterations | 100+ per property |

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `user_repository.dart` |
| Classes | PascalCase | `UserRepository` |
| Variables | camelCase | `userName` |
| Constants | UPPER_SNAKE | `MAX_RETRIES` |
| Providers | camelCase + Provider | `userRepositoryProvider` |
| DTOs | PascalCase + Dto | `UserDto` |

---

## Troubleshooting

### Common Issues

**Build Runner Conflicts:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Drift Schema Changes:**

```bash
dart run build_runner build
# Then run migrations
```

**Provider Generation:**

```bash
# Ensure @riverpod annotation is correct
dart run build_runner watch --delete-conflicting-outputs
```

**iOS Pod Issues:**

```bash
cd ios && pod deintegrate && pod install && cd ..
```

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Acknowledgments

- [Flutter Team](https://flutter.dev) - Framework
- [Riverpod](https://riverpod.dev) - State Management
- [Very Good Ventures](https://verygood.ventures) - Architecture patterns
- [Reso Coder](https://resocoder.com) - Clean Architecture tutorials

---

<p align="center">
  <strong>Flutter Base 2025</strong><br/>
  <sub>Production-Ready • Clean Architecture • 650+ Tests • Type-Safe</sub><br/><br/>
  <sub>Built with Flutter 3.38+ | Dart 3.10+ | Riverpod 3.0+</sub>
</p>
