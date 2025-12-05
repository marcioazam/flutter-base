# Flutter Base 2025 - State of Art

Production-ready Flutter template with Clean Architecture, Riverpod 3.0, and modern best practices.

**Version 3.1.0** - Final Polish Edition with Flutter 3.38 / Dart 3.10 support.

## What's New in 3.2.0 (State of Art)

### Core Enhancements
- **PaginationNotifier<T>** - Generic infinite scroll with Riverpod
- **CacheDataSource<T>** - TTL-based caching with LRU eviction
- **ValidationResult<T>** - Type-safe form validation with composition
- **ExperimentService** - A/B testing with variant assignment

### New Services
- **CameraService** - Photo/video capture with QR/barcode scanning
- **PermissionService** - Unified permission handling with rationale
- **DeviceInfoService** - Device, app, and screen information
- **RemoteConfigService** - Remote configuration with type-safe getters
- **RateReviewService** - In-app review with configurable triggers

### Feature Flags
- **User Segmentation** - Target by userId, deviceType, appVersion
- **Targeting Rules** - Flexible rule-based flag evaluation

### Theming
- **Dynamic Colors** - Android 12+ wallpaper-based themes
- **High Contrast** - WCAG-compliant high contrast themes
- **Animated Transitions** - Smooth theme switching

### Animations
- **LottieWidget** - Lottie animation wrapper with controls
- **CustomPageRoute** - Configurable page transitions
- **StaggeredListView** - Animated list with stagger effects

### Connectivity
- **Sync on Restore** - Automatic sync when connectivity returns
- **Connection Type** - WiFi, mobile, ethernet detection

### CI/CD
- **Slack Notifications** - Build failure alerts
- **Email Notifications** - Configurable email alerts

## What's New in 3.1.0

- **Flutter 3.38 / Dart 3.10** - Latest stable with dot shorthands support
- **Drift Database** - Type-safe SQLite with reactive streams
- **AI Service** - Prepared interface for Gemini/OpenAI integration
- **Error Boundary** - Graceful error handling with retry
- **Predictive Back** - Android 15+ gesture support
- **Memory Monitor** - Threshold-based cache cleanup
- **Widget Previewer** - IDE preview annotations ready
- **Patrol E2E** - Native UI automation testing

## Overview

**Este projeto é um Frontend Flutter puro.** Não contém backend, banco de dados, ou regras de negócio. Toda a lógica de negócio e persistência de dados é responsabilidade da API backend (Python).

```
Flutter (Frontend) ──HTTP/REST──> Python API (Backend)
     │                                    │
     │ • UI/UX                           │ • Business Logic
     │ • State Management                │ • Data Persistence
     │ • Navigation                      │ • Authentication
     │ • Token Storage (local)           │ • Authorization
     │ • API Consumption                 │ • Database
     │                                    │
```

### Princípios do Frontend Puro

- **Sem banco de dados local** - Apenas token storage para autenticação
- **Sem regras de negócio** - Validações e lógica ficam no backend
- **Sem cache local** - Dados sempre vêm da API
- **Sem sincronização offline** - Requer conexão com backend
- **API-First** - Todas as operações passam pela API REST

## Features

### Core
- **Flutter 3.38+ / Dart 3.10+** - Latest stable with dot shorthands
- **Clean Architecture** - Domain, Data, Presentation layers
- **Riverpod 3.0** - AsyncNotifier, Mutations, Code Generation
- **go_router 14.x** - Type-safe navigation with deep links
- **Dio 5.x** - HTTP client with interceptors
- **Generic Patterns** - Repository<T>, UseCase<P,R>, Result<T>
- **Extension Types** - Zero-cost type wrappers (UserId, Email, ApiPath)
- **Enhanced Result** - andThen, tap, zip, sequence combinators
- **Drift Database** - Type-safe SQLite with reactive streams
- **Error Boundary** - Graceful error handling with retry UI
- **Memory Monitor** - Threshold-based cache cleanup

### Integrations (v3.2)
- **AI Service** - Gemini/OpenAI ready interface
- **Biometric Auth** - Fingerprint/Face ID with fallback
- **GraphQL** - Ferry client with type-safe queries
- **WebSocket** - Real-time with auto-reconnect
- **Maps** - Google Maps/Mapbox abstraction
- **Payments** - Stripe with Apple/Google Pay
- **Social Login** - Google, Apple, Facebook
- **Push Notifications** - Firebase Messaging
- **Local Notifications** - Scheduled and recurring
- **Camera/Scanner** - Photo, video, QR/barcode scanning
- **Remote Config** - Firebase Remote Config abstraction
- **A/B Testing** - Experiment service with analytics
- **Rate & Review** - In-app review with triggers

### UX Patterns
- **Material 3** - Modern UI with dynamic colors
- **Skeleton Loading** - Shimmer placeholders
- **Infinite Scroll** - Auto-load pagination with PaginationNotifier
- **Responsive Layout** - Mobile/Tablet/Desktop breakpoints
- **Dark Mode** - System, light, dark with persistence
- **High Contrast** - WCAG-compliant accessibility theme
- **Animated Transitions** - Smooth page and theme transitions
- **Staggered Lists** - Animated list item entrance

### Android 15+ Support
- **Predictive Back Gesture** - Native back animation
- **16KB Page Size** - NDK r28 compatibility
- **Java 17** - Gradle 8.14 support

### Security (OWASP)
- **Certificate Pinning** - SSL/TLS validation
- **Input Sanitization** - XSS/Injection prevention
- **Secure Clipboard** - Auto-clear sensitive data

### Observability
- **Sentry Integration** - Crash reporting
- **Performance Monitor** - Cold start, navigation, API timing
- **Memory Monitor** - Threshold-based cleanup
- **Property-Based Tests** - Glados with 100 iterations
- **Patrol E2E Tests** - Native UI automation
- **CI/CD** - GitHub Actions for test, build, deploy

## Quick Start

```bash
# 1. Clone and install dependencies
flutter pub get

# 2. Copy environment file
cp .env.example .env.development

# 3. Generate code (freezed, riverpod, etc.)
make build

# 4. Run development
make run
```

## Environment Setup

The project uses environment-specific configuration files:

| File | Purpose |
|------|---------|
| `.env.development` | Local development settings |
| `.env.staging` | Staging/QA environment |
| `.env.production` | Production settings |
| `.env.example` | Template with all required keys |

### Required Environment Variables

```bash
# API Configuration (required)
API_BASE_URL=https://api.example.com/api/v1
APP_NAME=My App

# Feature Flags (optional)
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
```

### Environment Validation

The app validates environment configuration on startup:
- Missing required keys throw `ConfigValidationError`
- Invalid URL formats are rejected
- Production builds hide detailed error messages

## Project Structure

```
lib/
├── core/               # Infrastructure
│   ├── config/         # App configuration
│   ├── errors/         # Failures
│   ├── generics/       # Base classes
│   ├── network/        # API, GraphQL, WebSocket clients
│   ├── observability/  # Logging, crash reporting, performance
│   ├── security/       # Input sanitization, certificate pinning
│   └── utils/          # Result, validators, extension types
├── integrations/       # External services
│   ├── auth/           # Biometric, social auth
│   ├── files/          # Upload/download
│   ├── maps/           # Google Maps, location
│   ├── media/          # Image, video services
│   ├── notifications/  # Push, local notifications
│   └── payments/       # Stripe integration
├── features/           # Feature modules
│   └── auth/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/             # Shared widgets
│   ├── providers/      # Theme, connectivity, locale
│   └── widgets/        # Skeleton, infinite list, responsive
└── l10n/               # Translations
```

## Commands

```bash
make help          # List all commands
make build         # Generate code
make test          # Run tests
make test-coverage # Tests with coverage
make analyze       # Static analysis
make format        # Format code
make apk-prod      # Build production APK
make docker-build  # Build Docker image
```

## Architecture

### Layers

| Layer | Contains | Depends On |
|-------|----------|------------|
| Presentation | Pages, Widgets, Providers | Domain |
| Domain | Entities, UseCases, Interfaces | Nothing |
| Data | DTOs, DataSources, Repositories | Domain |

### Key Patterns

```dart
// Result<T> for error handling
final result = await repository.getUser(id);
result.fold(
  (failure) => showError(failure),
  (user) => showUser(user),
);

// AsyncNotifier for state
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build() => fetchUser();
}
```

## O que este projeto NÃO faz

| Responsabilidade | Este Projeto | Backend API |
|------------------|--------------|-------------|
| Banco de dados | ❌ | ✅ |
| Regras de negócio | ❌ | ✅ |
| Autenticação/Autorização | ❌ | ✅ |
| Cache de dados | ❌ | ✅ |
| Sincronização offline | ❌ | ✅ |
| Validação de dados | ❌ | ✅ |
| Token storage | ✅ | - |
| UI/UX | ✅ | - |
| Consumo de API | ✅ | - |

## Documentation

- [Architecture](docs/architecture.md)
- [Getting Started](docs/getting-started.md)
- [Deployment](docs/deployment.md)
- [ADRs](docs/adr/)
  - [ADR-001: Clean Architecture](docs/adr/ADR-001-clean-architecture.md)
  - [ADR-002: Riverpod Migration](docs/adr/ADR-002-riverpod-migration.md)
  - [ADR-003: API-First Frontend](docs/adr/ADR-003-api-first-frontend.md)
  - [ADR-004: Social Authentication](docs/adr/ADR-004-social-authentication.md)
  - [ADR-005: Payment Integration](docs/adr/ADR-005-payment-integration.md)
  - [ADR-006: Real-time Communication](docs/adr/ADR-006-realtime-communication.md)

## Integration Setup

Most integrations are commented out in `pubspec.yaml`. Uncomment as needed:

```yaml
# Biometric Auth
local_auth: ^2.3.0

# Payments
flutter_stripe: ^10.0.0

# Social Auth
google_sign_in: ^6.2.0
sign_in_with_apple: ^6.1.0

# Push Notifications
firebase_messaging: ^15.0.0
```

See individual ADRs for detailed setup instructions.

## License

MIT
