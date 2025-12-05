# Requirements Document

## Introduction

Este documento especifica os requisitos para o polimento final do Flutter Base 2025, elevando-o ao estado da arte absoluto baseado nas últimas atualizações de Flutter 3.38 e Dart 3.10 (Dezembro 2025). O projeto já possui uma base sólida com Clean Architecture, Riverpod 3.0, go_router, e property-based testing. Este documento foca em gaps identificados através de pesquisa extensiva das tendências mais recentes.

### Análise do Estado Atual (Dezembro 2025)

**Pontos Fortes Existentes:**
- Flutter 3.27+ / Dart 3.6+ (precisa atualizar para 3.38/3.10)
- Riverpod 3.0 com code generation
- go_router 14.x com deep linking
- Dio 5.x com interceptors completos
- freezed 2.5+ para DTOs imutáveis
- Clean Architecture com Generic Patterns (BaseRepository<T,ID>, ApiRepository<T,D,ID>)
- Result type com sealed classes (Success/Failure)
- Property-based testing com Glados
- Material 3 theme system
- Responsive layouts
- Integrações: Biometric, GraphQL, WebSocket, Maps, Payments, Social Auth

### Gaps Identificados (Pesquisa Dezembro 2025)

1. **Dart 3.10 Dot Shorthands**: Nova sintaxe `.start` ao invés de `MainAxisAlignment.start`
2. **Flutter 3.38 Widget Previewer**: Suporte a Preview annotations
3. **Android 16KB Page Size**: Configuração NDK r28 para Android 15+
4. **Predictive Back Gesture**: Habilitado por default no Android
5. **Patrol Testing**: Framework de testes E2E mais robusto que integration_test
6. **DCM (Dart Code Metrics)**: Análise de qualidade de código avançada
7. **Drift/Isar**: Local database type-safe (alternativa a SQLite raw)
8. **Macros Dart**: Preparação para macros (experimental)
9. **AI Toolkit Integration**: Preparação para Flutter GenUI SDK
10. **Impeller Vulkan/OpenGL**: Otimizações específicas de backend

## Glossary

- **FlutterBaseApp**: Sistema de template Flutter sendo polido
- **Dot Shorthands**: Recurso Dart 3.10 para omitir nomes de classe/enum quando inferíveis
- **Widget Previewer**: Ferramenta Flutter 3.38 para preview de widgets no IDE
- **Predictive Back**: Gesto de voltar preditivo do Android 15+
- **Patrol**: Framework de testes E2E para Flutter com suporte nativo
- **DCM**: Dart Code Metrics - ferramenta de análise de qualidade
- **Drift**: Biblioteca de persistência local type-safe para Flutter
- **Impeller**: Rendering engine moderno do Flutter (substitui Skia)

## Requirements

### Requirement 1: Flutter 3.38 / Dart 3.10 Upgrade

**User Story:** As a developer, I want the project to use Flutter 3.38 and Dart 3.10, so that I can leverage the latest features and performance improvements.

#### Acceptance Criteria

1. WHEN pubspec.yaml is configured THEN FlutterBaseApp SHALL specify `sdk: '>=3.10.0 <4.0.0'` and `flutter: '>=3.38.0'`
2. WHEN code uses enums THEN FlutterBaseApp SHALL use dot shorthands where type is inferrable (e.g., `.start` instead of `MainAxisAlignment.start`)
3. WHEN Android is built THEN FlutterBaseApp SHALL use NDK r28 for 16KB page size compatibility
4. WHEN Java is configured THEN FlutterBaseApp SHALL require Java 17 minimum for Gradle 8.14 compatibility

### Requirement 2: Dot Shorthands Adoption

**User Story:** As a developer, I want the codebase to use Dart 3.10 dot shorthands, so that code is more concise and readable.

#### Acceptance Criteria

1. WHEN enum values are assigned THEN FlutterBaseApp SHALL use `.value` syntax where type is inferrable
2. WHEN named constructors are used THEN FlutterBaseApp SHALL use `.constructorName()` syntax where type is inferrable
3. WHEN EdgeInsets is used THEN FlutterBaseApp SHALL use `.all()`, `.symmetric()` syntax
4. WHEN MainAxisAlignment is used THEN FlutterBaseApp SHALL use `.start`, `.center`, `.end` syntax

### Requirement 3: Widget Previewer Support

**User Story:** As a developer, I want Widget Previewer annotations, so that I can preview widgets directly in the IDE.

#### Acceptance Criteria

1. WHEN shared widgets are created THEN FlutterBaseApp SHALL include `@Preview` annotations for IDE preview
2. WHEN preview is defined THEN FlutterBaseApp SHALL specify width, height, and theme parameters
3. WHEN multiple previews are needed THEN FlutterBaseApp SHALL use `@MultiPreview` for variations
4. WHEN preview groups are needed THEN FlutterBaseApp SHALL use `group` parameter for organization

### Requirement 4: Predictive Back Gesture

**User Story:** As a user, I want predictive back gesture support on Android, so that navigation feels native and modern.

#### Acceptance Criteria

1. WHEN Android manifest is configured THEN FlutterBaseApp SHALL enable `android:enableOnBackInvokedCallback="true"`
2. WHEN back gesture is triggered THEN FlutterBaseApp SHALL show preview of previous screen
3. WHEN PopScope is used THEN FlutterBaseApp SHALL use `canPop` and `onPopInvokedWithResult` callbacks
4. WHEN custom back handling is needed THEN FlutterBaseApp SHALL integrate with go_router's back handling

### Requirement 5: Patrol E2E Testing Framework

**User Story:** As a QA engineer, I want Patrol testing framework, so that I can write more reliable E2E tests with native automation.

#### Acceptance Criteria

1. WHEN E2E tests are written THEN FlutterBaseApp SHALL use Patrol package for native UI automation
2. WHEN native dialogs appear THEN FlutterBaseApp SHALL handle permission dialogs via Patrol's native automation
3. WHEN tests are run THEN FlutterBaseApp SHALL support hot-restart for faster iteration
4. WHEN custom finders are needed THEN FlutterBaseApp SHALL use Patrol's `$` syntax for cleaner tests

### Requirement 6: DCM Code Quality Integration

**User Story:** As a tech lead, I want DCM (Dart Code Metrics) integration, so that code quality is automatically enforced.

#### Acceptance Criteria

1. WHEN code is analyzed THEN FlutterBaseApp SHALL run DCM with cyclomatic complexity threshold of 10
2. WHEN functions are analyzed THEN FlutterBaseApp SHALL enforce maximum lines of 50
3. WHEN classes are analyzed THEN FlutterBaseApp SHALL enforce maximum lines of 300
4. WHEN CI runs THEN FlutterBaseApp SHALL fail build on DCM violations
5. WHEN unused code exists THEN FlutterBaseApp SHALL detect via DCM unused code analysis

### Requirement 7: Local Database with Drift

**User Story:** As a developer, I want type-safe local database with Drift, so that I can persist data with compile-time safety.

#### Acceptance Criteria

1. WHEN local persistence is needed THEN FlutterBaseApp SHALL use Drift package for SQLite abstraction
2. WHEN tables are defined THEN FlutterBaseApp SHALL use Drift's type-safe table definitions
3. WHEN queries are written THEN FlutterBaseApp SHALL use Drift's type-safe query builder
4. WHEN migrations are needed THEN FlutterBaseApp SHALL use Drift's migration system
5. WHEN data is watched THEN FlutterBaseApp SHALL use Drift's reactive streams

### Requirement 8: Enhanced Generic Repository with Drift

**User Story:** As a developer, I want generic repository pattern integrated with Drift, so that I can reduce boilerplate for local data access.

#### Acceptance Criteria

1. WHEN local repository is created THEN FlutterBaseApp SHALL provide `DriftRepository<T, ID>` generic class
2. WHEN CRUD operations are performed THEN FlutterBaseApp SHALL return `Result<T>` for error handling
3. WHEN data changes THEN FlutterBaseApp SHALL expose `Stream<List<T>>` for reactive updates
4. WHEN offline sync is needed THEN FlutterBaseApp SHALL provide `SyncRepository<T, ID>` with conflict resolution

### Requirement 9: Impeller Backend Optimization

**User Story:** As a developer, I want Impeller rendering optimizations, so that the app has consistent 60/120 FPS performance.

#### Acceptance Criteria

1. WHEN Android builds THEN FlutterBaseApp SHALL enable Impeller via gradle configuration
2. WHEN iOS builds THEN FlutterBaseApp SHALL use Impeller by default (Flutter 3.38)
3. WHEN performance issues occur THEN FlutterBaseApp SHALL provide Skia fallback flag
4. WHEN Vulkan is available THEN FlutterBaseApp SHALL prefer Vulkan backend over OpenGL ES

### Requirement 10: AI Toolkit Preparation

**User Story:** As a developer, I want the project prepared for AI integration, so that I can easily add AI features when needed.

#### Acceptance Criteria

1. WHEN AI service is needed THEN FlutterBaseApp SHALL provide `AIService` interface abstraction
2. WHEN Gemini is used THEN FlutterBaseApp SHALL support google_generative_ai package integration
3. WHEN AI responses are received THEN FlutterBaseApp SHALL handle streaming responses
4. WHEN AI errors occur THEN FlutterBaseApp SHALL map to AppFailure hierarchy

### Requirement 11: Enhanced Accessibility Testing

**User Story:** As a QA engineer, I want comprehensive accessibility testing, so that the app meets WCAG 2.2 standards.

#### Acceptance Criteria

1. WHEN widget tests run THEN FlutterBaseApp SHALL verify `meetsGuideline(androidTapTargetGuideline)`
2. WHEN widget tests run THEN FlutterBaseApp SHALL verify `meetsGuideline(textContrastGuideline)`
3. WHEN semantics are tested THEN FlutterBaseApp SHALL verify all buttons have semantic labels
4. WHEN focus is tested THEN FlutterBaseApp SHALL verify logical focus order
5. WHEN reduced motion is enabled THEN FlutterBaseApp SHALL respect `MediaQuery.disableAnimations`

### Requirement 12: Performance Profiling Automation

**User Story:** As a developer, I want automated performance profiling, so that I can catch performance regressions early.

#### Acceptance Criteria

1. WHEN app starts THEN FlutterBaseApp SHALL measure and log cold start time in milliseconds
2. WHEN navigation occurs THEN FlutterBaseApp SHALL measure frame build time
3. WHEN API calls complete THEN FlutterBaseApp SHALL log response time with endpoint name
4. WHEN memory exceeds threshold THEN FlutterBaseApp SHALL trigger cache cleanup
5. WHEN CI runs THEN FlutterBaseApp SHALL generate performance report

### Requirement 13: Code Generation Optimization

**User Story:** As a developer, I want optimized code generation, so that build times are faster.

#### Acceptance Criteria

1. WHEN build_runner runs THEN FlutterBaseApp SHALL use `build.yaml` with optimized settings
2. WHEN freezed generates code THEN FlutterBaseApp SHALL use `@Freezed(copyWith: true, equal: true)` selectively
3. WHEN riverpod generates code THEN FlutterBaseApp SHALL use `@Riverpod(keepAlive: true)` for long-lived providers
4. WHEN JSON serialization is needed THEN FlutterBaseApp SHALL use `@JsonSerializable(explicitToJson: true)`

### Requirement 14: Error Boundary Widget

**User Story:** As a developer, I want error boundary widgets, so that errors in one part of the UI don't crash the entire app.

#### Acceptance Criteria

1. WHEN widget error occurs THEN FlutterBaseApp SHALL catch via ErrorWidget.builder
2. WHEN error is caught THEN FlutterBaseApp SHALL display user-friendly error UI
3. WHEN error is caught THEN FlutterBaseApp SHALL report to crash reporter
4. WHEN retry is possible THEN FlutterBaseApp SHALL provide retry button in error UI

### Requirement 15: Semantic Versioning Automation

**User Story:** As a developer, I want automated semantic versioning, so that releases are consistent and traceable.

#### Acceptance Criteria

1. WHEN version is bumped THEN FlutterBaseApp SHALL follow semver (MAJOR.MINOR.PATCH+BUILD)
2. WHEN CHANGELOG is updated THEN FlutterBaseApp SHALL follow Keep a Changelog format
3. WHEN release is created THEN FlutterBaseApp SHALL generate release notes from commits
4. WHEN breaking changes exist THEN FlutterBaseApp SHALL increment MAJOR version

</content>
</invoke>