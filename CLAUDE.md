# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter Base 2025 is a production-ready Flutter template implementing Clean Architecture. It's a **pure frontend** consuming REST APIs (backend in Python/PostgreSQL). The frontend handles UI/UX, state management, API consumption, token storage, and local caching.

**Key Principles:**
- Frontend consumes APIs, does NOT implement business logic (that's in the backend)
- Type-safe architecture with generic patterns (Repository, UseCase, Result monad)
- 100% code generation: Freezed (DTOs), Riverpod (providers), Drift (database), go_router (navigation)
- Property-based testing for mathematical invariants (36+ test suites)

## Development Commands

### Code Generation (REQUIRED after any code change to annotated files)
```bash
make build         # Generate code (freezed, riverpod, drift, go_router)
make watch         # Watch mode - auto-regenerate on save
```

**CRITICAL:** After modifying any file with `@freezed`, `@riverpod`, `@JsonSerializable`, drift tables, or go_router routes, you MUST run `make build`. Generated files have `.g.dart`, `.freezed.dart`, `.gr.dart` extensions.

### Testing
```bash
make test                # All tests
make test-coverage       # With coverage report (coverage/lcov.info)
make test-property       # Property-based tests only (36 files)
flutter test test/unit/  # Unit tests only
patrol test              # E2E integration tests (Patrol)
```

### Code Quality
```bash
make analyze       # Static analysis (strict: --fatal-infos)
make format        # Auto-format with dart format
make lint          # analyze + format check (CI-ready)
```

### Running the App
```bash
make run-dev       # Development flavor (verbose logging)
make run-staging   # Staging flavor
make run-prod      # Production flavor

# Or directly:
flutter run --flavor development -t lib/main_development.dart
```

### Building
```bash
make apk-dev       # Debug APK
make apk-prod      # Release APK (requires keystore)
make web           # Web release build
make docker-build  # Docker image for web deployment
```

### Running a Single Test
```bash
flutter test test/property/result_test.dart
flutter test test/unit/auth/login_usecase_test.dart --name "should return failure when credentials are invalid"
```

## Architecture

### Clean Architecture Layers

```
Presentation Layer (lib/features/*/presentation/)
  ├─ Pages: UI screens (HomePage, LoginPage)
  ├─ Widgets: Reusable components
  └─ Providers: Riverpod notifiers (@riverpod)
       ↓ depends on
Domain Layer (lib/features/*/domain/)
  ├─ Entities: Business models (User, Product)
  ├─ UseCases: Application logic (LoginUseCase, GetUserUseCase)
  └─ Repository Interfaces: Contracts (IAuthRepository)
       ↑ implemented by
Data Layer (lib/features/*/data/)
  ├─ DTOs: API models (@freezed + @JsonSerializable)
  ├─ DataSources: Remote (Dio), Local (Drift), Cache (in-memory)
  └─ Repositories: Implement domain interfaces
```

**Rules:**
- Presentation depends on Domain (NEVER on Data)
- Domain has ZERO dependencies (pure Dart, no Flutter)
- Data implements Domain interfaces

### Core Generic Patterns

All core patterns are in `lib/core/generics/`:

1. **Result<T>** (`lib/core/utils/result.dart`): Railway-oriented programming
   - `Success<T>(value)` or `Failure<T>(AppFailure)`
   - Monad laws validated by property tests
   - Methods: `fold`, `map`, `flatMap`, `zip`, `sequence`, `tryCatch`, `fromFuture`

2. **BaseRepository<T, ID>** (`lib/core/generics/base_repository.dart`): CRUD interface
   - Methods: `getById`, `getAll`, `create`, `update`, `delete`, `watchAll`
   - All return `Result<T>` or `Stream<T>`

3. **CompositeRepository<T, ID>** (`lib/core/generics/composite_repository.dart`): Data access strategy
   - Cache → Local (Drift) → Remote (API)
   - Auto-populates cache/local on remote fetch
   - TTL-based cache expiration

4. **ApiRepository<T, D, ID>** (`lib/core/generics/api_repository.dart`): DTO ↔ Entity conversion
   - Automatic DTO-to-Entity mapping
   - Exception-to-Failure conversion

5. **DriftRepository<T, ID>** (`lib/core/generics/drift_repository.dart`): Type-safe SQLite
   - Reactive queries with `watchAll()`
   - Transaction support

6. **BaseUseCase<Params, R>** (`lib/core/generics/base_usecase.dart`): Business logic encapsulation
   - Single `execute(Params)` method returning `Future<Result<R>>`
   - Example: `LoginUseCase(email, password) → Result<User>`

### Provider Architecture (Riverpod 3.0)

All providers use **code generation** with `@riverpod`:

```dart
// CORRECT:
@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  Future<Result<User>> build() async => // initial state
}

// Access: ref.watch(loginNotifierProvider)
```

**NEVER** manually create providers like `StateNotifierProvider`. Always use `@riverpod` annotation.

### Navigation (go_router 17.0)

Routes are defined in `lib/core/router/app_router.dart`:
- Route guards handle authentication checks
- ShellRoute provides persistent bottom navigation
- Use `context.go(RoutePaths.home)` or `context.pushNamed(RouteNames.profile)`

### Error Handling

**Hierarchy:**
1. **Exceptions** (`lib/core/errors/exceptions.dart`): Programming/infrastructure errors (throw, log, bubble)
2. **Failures** (`lib/core/errors/failures.dart`): Business/validation errors (return Result)

**Sealed classes for exhaustive matching:**
```dart
sealed class AppFailure {
  NetworkFailure, CacheFailure, ValidationFailure,
  UnauthorizedFailure, NotFoundFailure, ServerFailure,
  UnexpectedFailure
}
```

Use `Result.tryCatch()` to convert exceptions to failures:
```dart
return Result.tryCatch(
  () => jsonDecode(response),
  onError: (e, st) => ServerFailure(e.toString()),
);
```

## Code Generation Workflow

**EVERY time you modify these files, regenerate:**
- DTOs with `@freezed`: `user.dart` → generates `user.freezed.dart`, `user.g.dart`
- Providers with `@riverpod`: `auth_provider.dart` → generates `auth_provider.g.dart`
- Drift tables: `database.dart` → generates `database.g.dart`
- Routes with `@TypedGoRoute`: generates `.gr.dart`

**Command:** `make build` or `dart run build_runner build --delete-conflicting-outputs`

**Watch mode** (auto-regenerate on save): `make watch`

## Testing Strategy

### Property-Based Testing (Glados)

36 property test files validate mathematical properties:
- `test/property/result_test.dart`: Monad laws (identity, associativity)
- `test/property/dto_test.dart`: JSON serialization round-trip
- `test/property/cache_test.dart`: TTL expiration, LRU eviction
- `test/property/validation_test.dart`: Error aggregation composability

**Example:**
```dart
Glados<(String, String)>().test('DTO round-trip', (tuple) {
  final json = UserDTO(name: tuple.$1).toJson();
  final decoded = UserDTO.fromJson(json);
  expect(decoded.name, tuple.$1);
});
```

### Test Categories
- **Unit:** `test/unit/` - Individual components
- **Property:** `test/property/` - Invariants with 100+ iterations
- **Widget:** `test/widget/` - UI components
- **Golden:** `test/golden/` - Visual regression
- **Integration:** `integration_test/` - E2E with Patrol
- **Smoke:** `test/smoke/` - Critical user flows

### Test Coverage Requirements
- Core patterns: 100% (enforced by property tests)
- Business logic: 80%+
- UI: Widget tests for complex components

## Environment Configuration

**Files:**
- `.env.example`: Template (committed)
- `.env.development`, `.env.staging`, `.env.production`: Actual secrets (NEVER commit)

**Setup:**
```bash
cp .env.example .env.development
# Edit .env.development with real API_BASE_URL
```

**Flavors:** Each flavor loads different `.env`:
- `main_development.dart` → `.env.development`
- `main_staging.dart` → `.env.staging`
- `main_production.dart` → `.env.production`

**Access in code:**
```dart
import 'package:flutter_base_2025/core/config/app_config.dart';
final apiUrl = AppConfig.instance.apiBaseUrl;
```

## Common Patterns

### Creating a New Feature

1. **Create folder structure:**
```
lib/features/my_feature/
  ├─ data/
  │  ├─ datasources/my_feature_remote_datasource.dart
  │  ├─ dtos/my_feature_dto.dart  # @freezed
  │  └─ repositories/my_feature_repository_impl.dart
  ├─ domain/
  │  ├─ entities/my_feature.dart
  │  ├─ repositories/my_feature_repository.dart  # interface
  │  └─ usecases/get_my_feature_usecase.dart
  └─ presentation/
     ├─ pages/my_feature_page.dart
     ├─ providers/my_feature_provider.dart  # @riverpod
     └─ widgets/my_feature_widget.dart
```

2. **Define Entity (Domain):**
```dart
// lib/features/my_feature/domain/entities/my_feature.dart
class MyFeature {
  const MyFeature({required this.id, required this.name});
  final String id;
  final String name;
}
```

3. **Define DTO (Data) with Freezed:**
```dart
// lib/features/my_feature/data/dtos/my_feature_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'my_feature_dto.freezed.dart';
part 'my_feature_dto.g.dart';

@freezed
class MyFeatureDTO with _$MyFeatureDTO {
  const factory MyFeatureDTO({
    required String id,
    required String name,
  }) = _MyFeatureDTO;

  factory MyFeatureDTO.fromJson(Map<String, dynamic> json) =>
      _$MyFeatureDTOFromJson(json);

  // Convert to entity
  MyFeature toEntity() => MyFeature(id: id, name: name);
}
```

4. **Repository Interface (Domain):**
```dart
// lib/features/my_feature/domain/repositories/my_feature_repository.dart
abstract interface class MyFeatureRepository {
  Future<Result<MyFeature>> getById(String id);
}
```

5. **Repository Implementation (Data):**
```dart
// lib/features/my_feature/data/repositories/my_feature_repository_impl.dart
class MyFeatureRepositoryImpl implements MyFeatureRepository {
  const MyFeatureRepositoryImpl(this.remoteDataSource);
  final MyFeatureRemoteDataSource remoteDataSource;

  @override
  Future<Result<MyFeature>> getById(String id) async {
    return Result.fromFuture(
      () async {
        final dto = await remoteDataSource.getById(id);
        return dto.toEntity();
      },
      onError: (e, st) => ServerFailure(e.toString()),
    );
  }
}
```

6. **Provider (Presentation):**
```dart
// lib/features/my_feature/presentation/providers/my_feature_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'my_feature_provider.g.dart';

@riverpod
MyFeatureRepository myFeatureRepository(Ref ref) =>
    MyFeatureRepositoryImpl(ref.watch(myFeatureRemoteDataSourceProvider));

@riverpod
class MyFeatureNotifier extends _$MyFeatureNotifier {
  @override
  Future<Result<MyFeature>> build(String id) async {
    return ref.watch(myFeatureRepositoryProvider).getById(id);
  }
}
```

7. **Run code generation:**
```bash
make build
```

### Using Result Monad

**Basic usage:**
```dart
final result = await repository.getUser(id);
result.fold(
  (failure) => showError(failure.userMessage),
  (user) => showUser(user),
);
```

**Chaining operations:**
```dart
final result = await repository.getUser(id)
  .flatMap((user) => repository.getProfile(user.id))
  .map((profile) => profile.displayName);
```

**Combining multiple Results:**
```dart
final combined = Result.zip(userResult, profileResult);
combined.fold(
  (failure) => handleError(failure),
  (tuple) => {
    final (user, profile) = tuple;
    // Use both values
  },
);
```

**Converting exceptions:**
```dart
return Result.tryCatch(
  () => jsonDecode(response),
  onError: (e, st) => ServerFailure('JSON decode failed'),
);
```

### Validation

Use `CompositeValidator` from `lib/core/validation/`:
```dart
final validator = CompositeValidator<String>([
  RequiredValidator(fieldName: 'email'),
  EmailValidator(),
  MinLengthValidator(fieldName: 'email', minLength: 5),
]);

final result = validator.validate(email);
if (!result.isValid) {
  final errors = result.errorsFor('email');
  // Show errors
}
```

### Drift Database

Define tables in `lib/core/database/`:
```dart
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}
```

Use generated DAO:
```dart
@riverpod
UserDriftRepository userDriftRepository(Ref ref) =>
    UserDriftRepositoryImpl(ref.watch(databaseProvider));

// In repository:
@override
Future<Result<User>> getById(String id) async {
  final row = await db.select(db.users).where((u) => u.id.equals(id)).getSingleOrNull();
  return row != null ? Success(row.toEntity()) : Failure(NotFoundFailure('User not found'));
}
```

## Linting and Code Style

**Strict linting** configured in `analysis_options.yaml`:
- Cyclomatic complexity: max 10
- Function params: max 4 (use objects for more)
- Nesting: max 4 levels
- File size: prefer 200-400 lines, max 500
- Function size: prefer 10-50 lines, max 75

**Key rules:**
- Single quotes: `'text'` not `"text"`
- Trailing commas: Always (for better formatting)
- Final locals: Prefer `final` over `var`
- Type annotations: Required on public APIs
- Avoid dynamic: Use generics instead

**Naming conventions:**
- Files: `snake_case.dart`
- Classes/Types: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Booleans: `isLoading`, `hasData`, `canSubmit`
- Functions: verb-first (`getUser`, `setName`, `createOrder`)

## Important Project-Specific Rules

### 1. Code Generation is Mandatory
NEVER manually write `.g.dart`, `.freezed.dart`, `.gr.dart` files. Always use `make build`.

### 2. Use Generics, Don't Duplicate
Reuse `BaseRepository`, `BaseUseCase`, `CompositeRepository` instead of writing custom implementations.

### 3. Domain Layer is Pure Dart
NEVER import `package:flutter/*` in `lib/features/*/domain/`. Domain must be framework-agnostic.

### 4. Providers Use Code Generation
NEVER use manual providers (`Provider`, `StateNotifierProvider`). Always use `@riverpod` annotation.

### 5. Result, Not Exceptions
For business logic errors, return `Result<T>` with `Failure`. Only throw exceptions for programming errors.

### 6. DTOs vs Entities
- **DTOs** (`data/dtos/`): API models with `@freezed`, JSON serialization
- **Entities** (`domain/entities/`): Business models, no annotations
- Always convert: `DTO.toEntity()` and `Entity.toDTO()`

### 7. Environment Security
NEVER hardcode API keys, tokens, or secrets. Use `.env` files and `AppConfig`.

### 8. Testing is Non-Negotiable
- Property tests for core patterns (monad laws, serialization)
- Unit tests for business logic
- Integration tests for critical flows

## CI/CD

GitHub Actions workflows in `.github/workflows/`:
- `ci.yml`: Analyze, test, build on every PR/push
- `security.yml`: CodeQL, gitleaks, trivy scans
- `integration-tests.yml`: Patrol E2E tests
- `release.yml`: Multi-platform builds on tag push

**Required secrets** (production):
- `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `ANDROID_STORE_PASSWORD`

## Common Pitfalls

1. **Forgetting to run `make build`** after changing annotated files → compilation errors
2. **Importing Data layer in Presentation** → breaks Clean Architecture
3. **Using manual providers** instead of `@riverpod` → inconsistent state management
4. **Throwing exceptions for business errors** → use `Result<T>` instead
5. **Hardcoding secrets** → use `.env` and `AppConfig`
6. **Not using generics** → duplicated repository/usecase code
7. **Skipping property tests** → monad laws violations undetected

## Documentation

- Architecture: `docs/architecture.md`
- ADRs: `docs/adr/ADR-*.md` (13 decision records)
- Getting Started: `docs/getting-started.md`
- Deployment: `docs/deployment.md`

## Support

For issues with Flutter Base 2025 template, check:
1. README.md (comprehensive guide)
2. docs/getting-started.md (setup troubleshooting)
3. Property tests (examples of correct usage)
