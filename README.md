<p align="center">
  <img src="logo.png" alt="Flutter Base" width="200"/>
</p>

<h1 align="center">Flutter Base</h1>

<p align="center">
  <strong>State of Art Flutter Template for Production-Ready Applications</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#modules">Modules</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#documentation">Documentation</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Riverpod-3.0+-00D1B2" alt="Riverpod"/>
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License"/>
  <img src="https://img.shields.io/badge/Version-3.4.0-blue" alt="Version"/>
</p>

---

## Overview

**Flutter Base ** is a production-ready Flutter template implementing Clean Architecture with modern best practices for . Designed as a pure frontend consuming REST APIs, it provides a solid foundation for building scalable, maintainable, and testable mobile applications.

```
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter Base  (Frontend)                  │
├─────────────────────────────────────────────────────────────────┤
│  • UI/UX Components          • State Management (Riverpod 3.0)  │
│  • Navigation (go_router)    • API Consumption (Dio 5.x)        │
│  • Token Storage             • Observability Stack              │
│  • Generic Patterns          • Property-Based Testing           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/REST
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Python API (Backend)                          │
├─────────────────────────────────────────────────────────────────┤
│  • Business Logic            • Data Persistence                 │
│  • Authentication            • Authorization                    │
│  • Database                  • Validation                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Features

### Core Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.38+ | UI Framework |
| Dart | 3.10+ | Language with dot shorthands |
| Riverpod | 3.0.3+ | State Management |
| go_router | 17.0.0+ | Navigation |
| Dio | 5.7.0+ | HTTP Client |
| Drift | 2.29.0+ | Local Database |
| Freezed | 3.2.3+ | Code Generation |

### Generic Patterns (100% Type-Safe)

- **Result<T>** - Monad with full laws (left identity, right identity, associativity)
- **BaseRepository<T, ID>** - CRUD operations with pagination
- **ApiRepository<T, D, ID>** - DTO-Entity conversion
- **DriftRepository<T, ID>** - Type-safe SQLite operations
- **CacheDataSource<T>** - TTL + LRU eviction
- **CompositeRepository<T, ID>** - Cache → Local → Remote strategy
- **UseCase<Params, R>** - Business logic encapsulation
- **CompositeUseCase** - Use case chaining
- **PaginationNotifier<T>** - Infinite scroll with state preservation

### Property-Based Testing

36 test files with Glados library (100+ iterations per property):

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

---

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Pages     │  │   Widgets   │  │   Providers (Riverpod)  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                        DOMAIN LAYER                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Entities   │  │  Use Cases  │  │  Repository Interfaces  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                         DATA LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │    DTOs     │  │ DataSources │  │  Repository Impls       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Dependencies

| Layer | Contains | Depends On |
|-------|----------|------------|
| **Presentation** | Pages, Widgets, Providers | Domain |
| **Domain** | Entities, UseCases, Interfaces | Nothing (Pure Dart) |
| **Data** | DTOs, DataSources, Repositories | Domain |

### Data Flow

```
User Action → Provider → UseCase → Repository → DataSource → API
     ↑                                                        │
     └────────────────── Result<T> ───────────────────────────┘
```

---

## Modules

### Core Infrastructure (`lib/core/`)

```
core/
├── config/           # App configuration and environment
│   └── app_config.dart
├── constants/        # Application constants
│   └── app_constants.dart
├── database/         # Drift database setup
│   ├── app_database.dart
│   ├── drift_repository.dart
│   └── sync_repository.dart
├── errors/           # Error handling
│   ├── exceptions.dart    # AppException hierarchy
│   └── failures.dart      # AppFailure hierarchy
├── generics/         # Generic patterns (Type-Safe)
│   ├── base_repository.dart      # BaseRepository<T, ID>
│   ├── api_repository.dart       # ApiRepository<T, D, ID>
│   ├── drift_repository.dart     # DriftRepository<T, ID>
│   ├── cache_datasource.dart     # CacheDataSource<T> + LRU
│   ├── cache_repository.dart     # CacheRepository<T>
│   ├── composite_repository.dart # CompositeRepository<T, ID>
│   ├── base_usecase.dart         # UseCase<Params, R>
│   ├── base_dto.dart             # BaseDTO<T>
│   ├── paginated_list.dart       # PaginatedList<T>
│   └── pagination_notifier.dart  # PaginationNotifier<T>
├── init/             # App initialization
│   └── app_initializer.dart
├── network/          # Network layer
│   ├── api_client.dart           # Dio HTTP client
│   ├── graphql_client.dart       # GraphQL support
│   ├── websocket_client.dart     # WebSocket with reconnect
│   ├── network_error_handler.dart
│   └── interceptors/
├── observability/    # Monitoring and analytics
│   ├── app_logger.dart           # Structured logging
│   ├── analytics_service.dart    # Event tracking
│   ├── crash_reporter.dart       # Error reporting
│   ├── performance_monitor.dart  # Performance metrics
│   ├── feature_flags.dart        # Feature toggles
│   └── experiment_service.dart   # A/B testing
├── router/           # Navigation
│   ├── app_router.dart           # go_router setup
│   └── route_guards.dart         # Auth guards
├── security/         # Security utilities
│   └── security_utils.dart       # Input sanitization
├── storage/          # Local storage
│   └── token_storage.dart        # Secure token storage
├── theme/            # Theming
│   ├── app_theme.dart            # Material 3 theme
│   ├── app_colors.dart           # Color palette
│   ├── app_typography.dart       # Text styles
│   └── accessibility.dart        # WCAG utilities
├── utils/            # Utilities
│   ├── result.dart               # Result<T> monad
│   ├── validation.dart           # Validation utilities
│   ├── validators.dart           # Common validators
│   ├── extension_types.dart      # UserId, Email, etc.
│   └── mutation.dart             # Mutation pattern
└── validation/       # Validation system
    └── validator.dart            # CompositeValidator<T>
```

### Features (`lib/features/`)

```
features/
└── auth/
    ├── data/
    │   ├── datasources/
    │   │   └── auth_remote_datasource.dart
    │   ├── models/
    │   │   └── user_dto.dart
    │   └── repositories/
    │       └── auth_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── user.dart
    │   ├── repositories/
    │   │   └── auth_repository.dart
    │   └── usecases/
    │       ├── login_usecase.dart
    │       └── logout_usecase.dart
    └── presentation/
        ├── pages/
        │   ├── login_page.dart
        │   └── register_page.dart
        ├── providers/
        │   └── auth_provider.dart
        └── widgets/
            └── login_form.dart
```

### Integrations (`lib/integrations/`)

```
integrations/
├── auth/             # Authentication
│   ├── biometric_service.dart    # Fingerprint/Face ID
│   └── social_auth_service.dart  # Google, Apple, Facebook
├── files/            # File operations
│   └── file_service.dart         # Upload/download
├── maps/             # Maps and location
│   └── maps_service.dart         # Google Maps abstraction
├── media/            # Media handling
│   └── camera_service.dart       # Photo, video, QR scanning
├── notifications/    # Notifications
│   ├── push_notification_service.dart
│   └── local_notification_service.dart
└── payments/         # Payments
    └── stripe_service.dart       # Stripe integration
```

### Shared (`lib/shared/`)

```
shared/
├── providers/        # Global providers
│   ├── theme_provider.dart
│   ├── connectivity_provider.dart
│   ├── locale_provider.dart
│   └── pagination_notifier.dart
└── widgets/          # Reusable widgets
    ├── skeleton_loading.dart
    ├── infinite_list.dart
    ├── responsive_layout.dart
    ├── error_boundary.dart
    └── accessible_button.dart
```

---

## Quick Start

### Prerequisites

- Flutter SDK 3.38+
- Dart SDK 3.10+
- Android Studio / VS Code
- Git

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-org/flutter_base_.git
cd flutter_base_

# 2. Install dependencies
flutter pub get

# 3. Copy environment file
cp .env.example .env.development

# 4. Generate code (freezed, riverpod, drift)
dart run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run --flavor development
```

### Available Commands

```bash
make help           # List all commands
make build          # Generate code
make test           # Run all tests
make test-coverage  # Tests with coverage report
make analyze        # Static analysis
make format         # Format code
make apk-dev        # Build development APK
make apk-prod       # Build production APK
make docker-build   # Build Docker image
```

---

## Environment Configuration

### Environment Files

| File | Purpose |
|------|---------|
| `.env.development` | Local development |
| `.env.staging` | Staging/QA |
| `.env.production` | Production |
| `.env.example` | Template |

### Required Variables

```bash
# API Configuration
API_BASE_URL=https://api.example.com/api/v1
APP_NAME=My App

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
ENABLE_PERFORMANCE_MONITORING=true

# Optional: Sentry DSN
SENTRY_DSN=https://xxx@sentry.io/xxx
```

### Flavors

| Flavor | Entry Point | Description |
|--------|-------------|-------------|
| development | `main_development.dart` | Debug mode, verbose logging |
| staging | `main_staging.dart` | QA testing |
| production | `main_production.dart` | Release mode, minimal logging |

---

## Testing

### Test Structure

```
test/
├── helpers/          # Test utilities
│   └── generators.dart    # Glados custom generators
├── property/         # Property-based tests (36 files)
│   ├── result_test.dart
│   ├── dto_test.dart
│   ├── validation_test.dart
│   ├── cache_test.dart
│   └── ...
├── unit/             # Unit tests
├── integration/      # Integration tests
├── golden/           # Golden tests
└── smoke/            # Smoke tests
```

### Running Tests

```bash
# All tests
flutter test

# Property-based tests only
flutter test test/property/

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Custom Generators (Glados)

```dart
extension CustomGenerators on Any {
  Arbitrary<User> get user => combine4(
    any.nonEmptyLetters,
    any.email,
    any.nonEmptyLetters,
    any.dateTime,
    (id, email, name, createdAt) => User(...),
  );
  
  Arbitrary<Result<T>> result<T>(Arbitrary<T> valueGen) => ...;
  Arbitrary<AppFailure> get appFailure => ...;
}
```

---

## Code Examples

### Result<T> Monad

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
combined.fold(
  (failure) => handleError(failure),
  ((user, profile)) => showData(user, profile),
);
```

### Repository Pattern

```dart
// Generic repository
abstract interface class BaseRepository<T, ID> {
  Future<Result<T>> getById(ID id);
  Future<Result<PaginatedList<T>>> getAll({int page, int pageSize});
  Future<Result<T>> create(T entity);
  Future<Result<T>> update(T entity);
  Future<Result<void>> delete(ID id);
  Stream<List<T>> watchAll();
}

// Composite repository (cache → local → remote)
final repository = CompositeRepository<User, String>(
  remote: apiRepository,
  local: driftRepository,
  cache: memoryCacheDataSource,
  cacheTtl: Duration(minutes: 5),
);
```

### Pagination

```dart
// PaginationNotifier
abstract class UserListNotifier extends PaginationNotifier<User> {
  @override
  Future<Result<PaginatedList<User>>> fetchPage(int page, int pageSize) {
    return repository.getAll(page: page, pageSize: pageSize);
  }
}

// Usage in widget
ref.watch(userListProvider).when(
  data: (state) => ListView.builder(
    itemCount: state.items.length,
    itemBuilder: (_, i) => UserTile(state.items[i]),
  ),
  loading: () => SkeletonLoading(),
  error: (e, _) => ErrorWidget(e),
);
```

### Validation

```dart
// Composable validators
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

## Security

### OWASP Compliance

- **Certificate Pinning** - SSL/TLS validation
- **Input Sanitization** - XSS/Injection prevention
- **Secure Storage** - flutter_secure_storage for tokens
- **No Hardcoded Secrets** - Environment variables only

### Security Headers (API)

```dart
// Recommended backend headers
CSP: default-src 'self'; script-src 'nonce-xxx'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000
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

### Architecture Decision Records (ADRs)

| ADR | Title |
|-----|-------|
| [ADR-001](docs/adr/ADR-001-clean-architecture.md) | Clean Architecture |
| [ADR-002](docs/adr/ADR-002-riverpod-migration.md) | Riverpod 3.0 Migration |
| [ADR-003](docs/adr/ADR-003-api-first-frontend.md) | API-First Frontend |
| [ADR-004](docs/adr/ADR-004-social-authentication.md) | Social Authentication |
| [ADR-005](docs/adr/ADR-005-payment-integration.md) | Payment Integration |
| [ADR-006](docs/adr/ADR-006-realtime-communication.md) | Real-time Communication |

---

## What This Project Does NOT Do

| Responsibility | This Project | Backend API |
|----------------|:------------:|:-----------:|
| Database | ❌ | ✅ |
| Business Logic | ❌ | ✅ |
| Authentication | ❌ | ✅ |
| Authorization | ❌ | ✅ |
| Data Validation | ❌ | ✅ |
| Offline Sync | ❌ | ✅ |
| Token Storage | ✅ | - |
| UI/UX | ✅ | - |
| API Consumption | ✅ | - |
| State Management | ✅ | - |

---

## CI/CD Configuration

### Required GitHub Secrets

Configure these secrets in your repository settings (`Settings > Secrets and variables > Actions`):

| Secret | Required | Description |
|--------|:--------:|-------------|
| `CODECOV_TOKEN` | Optional | Codecov upload token for coverage reports |
| `SLACK_WEBHOOK_URL` | Optional | Slack webhook for notifications |
| `ANDROID_KEYSTORE_BASE64` | Release | Base64-encoded Android release keystore |
| `ANDROID_KEY_ALIAS` | Release | Android keystore key alias |
| `ANDROID_KEY_PASSWORD` | Release | Android key password |
| `ANDROID_STORE_PASSWORD` | Release | Android keystore password |
| `GITLEAKS_LICENSE` | Optional | Gitleaks license for secrets scanning |

### Generating Android Keystore Secret

```bash
# Generate keystore (if not exists)
keytool -genkey -v -keystore release.keystore -alias your-alias -keyalg RSA -keysize 2048 -validity 10000

# Encode to base64
base64 -i release.keystore | pbcopy  # macOS
base64 release.keystore | clip       # Windows
base64 release.keystore              # Linux (copy output)
```

### CI/CD Workflows

| Workflow | Trigger | Description |
|----------|---------|-------------|
| `ci.yml` | PR, Push | Analyze, test, build |
| `ci-matrix.yml` | PR to main | Multi-version/platform testing |
| `security.yml` | PR, Push, Weekly | CodeQL, gitleaks, trivy |
| `code-review.yml` | PR | Automated code review |
| `pr-labeler.yml` | PR | Auto-labeling |
| `release.yml` | Tag v* | Multi-platform release builds |
| `release-drafter.yml` | Push to main | Draft release notes |
| `stale.yml` | Daily | Manage stale issues/PRs |
| `golden-tests.yml` | PR (widget changes) | Visual regression testing |
| `docs.yml` | Push to main, Release | Generate and deploy docs |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Max file size: 400 lines
- Max function size: 50 lines
- Max complexity: 10
- 100% property test coverage for core modules

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ for the Flutter community
</p>
