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
  <a href="#quick-start">Quick Start</a> |
  <a href="#testing">Testing</a> |
  <a href="#cicd">CI/CD</a> |
  <a href="#documentation">Docs</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Riverpod-3.0+-00D1B2" alt="Riverpod"/>
  <img src="https://img.shields.io/badge/Coverage-80%25+-brightgreen" alt="Coverage"/>
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License"/>
  <img src="https://img.shields.io/badge/Version-3.4.0-blue" alt="Version"/>
</p>

---

## Overview

Flutter Base 2025 is a production-ready template implementing Clean Architecture with modern best practices. Designed as a pure frontend consuming REST APIs, it provides a solid foundation for scalable, maintainable, and testable mobile applications.

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

```
flutter_base_2025/
├── lib/
│   ├── core/                    # Core infrastructure
│   │   ├── config/              # App configuration
│   │   ├── constants/           # Application constants
│   │   ├── database/            # Drift database setup
│   │   ├── errors/              # Exception/Failure hierarchy
│   │   ├── generics/            # Generic patterns (Repository, UseCase)
│   │   ├── init/                # App initialization
│   │   ├── network/             # API client, interceptors
│   │   ├── observability/       # Logging, analytics, crash reporting
│   │   ├── router/              # go_router configuration
│   │   ├── security/            # Input sanitization
│   │   ├── storage/             # Secure token storage
│   │   ├── theme/               # Material 3 theming
│   │   ├── utils/               # Result monad, extensions
│   │   └── validation/          # Validators
│   ├── features/                # Feature modules
│   │   └── auth/                # Authentication feature
│   │       ├── data/            # DTOs, DataSources, Repositories
│   │       ├── domain/          # Entities, UseCases, Interfaces
│   │       └── presentation/    # Pages, Widgets, Providers
│   ├── integrations/            # Third-party integrations
│   │   ├── auth/                # Biometric, Social auth
│   │   ├── files/               # File upload/download
│   │   ├── maps/                # Google Maps
│   │   ├── media/               # Camera, QR scanning
│   │   ├── notifications/       # Push/Local notifications
│   │   └── payments/            # Stripe integration
│   ├── l10n/                    # Localization (ARB files)
│   ├── shared/                  # Shared providers and widgets
│   ├── main.dart                # App entry point
│   ├── main_development.dart    # Development flavor
│   ├── main_staging.dart        # Staging flavor
│   └── main_production.dart     # Production flavor
├── test/                        # Unit and widget tests
│   ├── helpers/                 # Test utilities
│   ├── property/                # Property-based tests (36 files)
│   ├── unit/                    # Unit tests
│   ├── golden/                  # Golden/snapshot tests
│   └── smoke/                   # Smoke tests
├── integration_test/            # E2E tests with Patrol
│   ├── app_test.dart            # Main test file
│   ├── keys.dart                # Widget keys
│   └── test_config.dart         # Test configuration
├── docs/                        # Documentation
│   ├── adr/                     # Architecture Decision Records
│   ├── architecture.md          # System architecture
│   ├── getting-started.md       # Setup guide
│   └── deployment.md            # CI/CD documentation
├── deployment/                  # Deployment configuration
│   ├── docker/                  # Dockerfile, nginx.conf
│   └── scripts/                 # Build scripts
├── .github/                     # GitHub configuration
│   ├── workflows/               # CI/CD workflows
│   ├── actions/                 # Custom actions
│   └── ISSUE_TEMPLATE/          # Issue templates
├── android/                     # Android platform
├── ios/                         # iOS platform
├── pubspec.yaml                 # Dependencies
├── analysis_options.yaml        # Linting rules
├── build.yaml                   # Build runner config
└── Makefile                     # Development commands
```

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
// Basic usage
final result = await repository.getUser(id);
result.fold(
  (failure) => showError(failure.message),
  (user) => showUser(user),
);

// Chaining with flatMap
final result = await repository.getUser(id)
  .flatMap((user) => repository.getProfile(user.id))
  .flatMap((profile) => repository.getSettings(profile.id));

// Combining results
final combined = Result.zip(userResult, profileResult);
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

// Composite repository usage
final repository = CompositeRepository<User, String>(
  remote: apiRepository,
  local: driftRepository,
  cache: memoryCacheDataSource,
  cacheTtl: Duration(minutes: 5),
);
```

### Validation

```dart
final validator = CompositeValidator<String>([
  RequiredValidator(fieldName: 'email'),
  EmailValidator(),
  MinLengthValidator(fieldName: 'email', minLength: 5),
]);

final result = validator.validate(email);
if (!result.isValid) {
  print(result.errorsFor('email'));
}
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture](docs/architecture.md) | System design and patterns |
| [Getting Started](docs/getting-started.md) | Setup guide |
| [Deployment](docs/deployment.md) | CI/CD and release |
| [Flavors Setup](docs/flavors-setup.md) | Environment configuration |
| [App Links](docs/app-links-setup.md) | Deep linking setup |

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

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards

| Rule | Value |
|------|-------|
| Max file size | 400 lines |
| Max function size | 50 lines |
| Max complexity | 10 |
| Test coverage | 80%+ |
| Property test coverage | 100% for core |

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with Flutter 3.38+ | Dart 3.10+ | Clean Architecture</sub>
</p>
