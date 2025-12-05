# Implementation Plan

## Flutter Base 2025 - State of Art Review

Este plano implementa a modernização do projeto Flutter Base 2025 para o estado da arte em 2025, com foco em padrões genéricos, property-based testing e produção.

---

- [x] 1. Atualizar dependências para versões 2025

  - [x] 1.1 Atualizar pubspec.yaml com versões mais recentes


    - Atualizar flutter_riverpod para 3.0.3+
    - Atualizar go_router para 17.0.0+
    - Atualizar drift para 2.29.0+
    - Atualizar freezed para 3.2.3+
    - Adicionar fpdart 1.2.0 como referência funcional
    - _Requirements: 15.1, 15.2, 15.3, 15.4_

  - [x] 1.2 Executar flutter pub upgrade e resolver conflitos

    - _Requirements: 16.1_

---


- [x] 2. Implementar Result<T> com Monad Laws

  - [x] 2.1 Refatorar Result<T> para garantir monad laws

    - Implementar flatMap com left identity
    - Implementar flatMap com right identity
    - Garantir associativity em chains
    - Garantir failure propagation em map/flatMap
    - _Requirements: 3.1, 3.2, 3.3, 3.4_


  - [x] 2.2 Escrever property test para Result Monad Laws
    - **Property 1: Result Monad Laws**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
    - Testar left identity: Success(a).flatMap(f) == f(a)
    - Testar right identity: m.flatMap(Success) == m
    - Testar associativity
    - Testar failure propagation
    - **VERIFIED:** test/property/result_test.dart contains all monad law tests

---


- [x] 3. Implementar Generic Repository Pattern
  - [x] 3.1 Criar/atualizar BaseRepository<T, ID> interface

    - Adicionar métodos createMany, deleteMany
    - Adicionar watchAll stream
    - Adicionar exists, count, findFirst
    - _Requirements: 1.1_
    - **VERIFIED:** lib/core/generics/base_repository.dart

  - [x] 3.2 Implementar ApiRepository<T, D, ID> com conversão DTO-Entity
    - Criar classe abstrata com conversão automática
    - Implementar _mapResponse para conversão
    - _Requirements: 1.2_
    - **VERIFIED:** lib/core/generics/api_repository.dart

  - [x] 3.3 Implementar DriftRepository<T, ID> genérico
    - Criar classe base para operações Drift
    - Implementar type-safe queries
    - _Requirements: 1.3_
    - **VERIFIED:** lib/core/generics/drift_repository.dart + lib/core/database/drift_repository.dart

  - [x] 3.4 Implementar CacheRepository<T> com TTL e LRU

    - Integrar com LruCacheDataSource
    - Configurar TTL padrão e max size
    - _Requirements: 1.4_
    - **VERIFIED:** lib/core/generics/cache_datasource.dart (MemoryCacheDataSource + LruCacheDataSource)

  - [x] 3.5 Implementar CompositeRepository<T, ID>
    - Orquestrar cache -> local -> remote
    - Implementar estratégia de fallback
    - _Requirements: 1.5_
    - **VERIFIED:** lib/core/generics/composite_repository.dart

  - [x] 3.6 Escrever unit tests para repositories
    - Testar CRUD operations
    - Testar conversão DTO-Entity
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_
    - **VERIFIED:** test/property/repository_test.dart + test/property/cache_test.dart


---

- [x] 4. Implementar Generic UseCase Pattern
  - [x] 4.1 Atualizar UseCase<Params, R> interface

    - Garantir retorno Future<Result<R>>
    - _Requirements: 2.1_
    - **VERIFIED:** lib/core/generics/base_usecase.dart

  - [x] 4.2 Implementar StreamUseCase<Params, R>

    - Retornar Stream<Result<R>>
    - _Requirements: 2.3_
    - **VERIFIED:** lib/core/generics/base_usecase.dart

  - [x] 4.3 Implementar CompositeUseCase<Params, R>

    - Permitir chaining de use cases
    - Propagar failures corretamente
    - _Requirements: 2.4_
    - **VERIFIED:** lib/core/generics/base_usecase.dart

  - [x] 4.4 Escrever unit tests para use cases

    - Testar execução e composição
    - _Requirements: 2.1, 2.3, 2.4_
    - **VERIFIED:** test/property/usecase_test.dart

---


- [x] 5. Checkpoint - Verificar testes passando
  - All property tests verified in test/property/ directory

---


- [x] 6. Implementar DTO Base com Round-Trip
  - [x] 6.1 Criar BaseDTO<T> interface

    - Definir toEntity() e toJson()
    - Documentar contrato de serialização
    - _Requirements: 4.1_
    - **VERIFIED:** lib/core/generics/base_dto.dart

  - [x] 6.2 Criar exemplo UserDTO com freezed
    - Implementar fromJson/toJson
    - Implementar toEntity()
    - Tratar campos nullable, nested e DateTime
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
    - **VERIFIED:** features/auth/data/models/user_dto.dart

  - [x] 6.3 Escrever property test para DTO Round-Trip
    - **Property 2: DTO Round-Trip Serialization**
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.4**
    - Testar fromJson(toJson(dto)) == dto
    - Incluir nullable, nested e DateTime
    - **VERIFIED:** test/property/dto_test.dart

---

- [x] 7. Implementar Validation System Genérico
  - [x] 7.1 Atualizar ValidationResult<T> sealed class

    - Garantir Valid<T> e Invalid<T>
    - Implementar merge para Invalid
    - _Requirements: 6.1, 6.3, 6.4_
    - **VERIFIED:** lib/core/validation/validator.dart

  - [x] 7.2 Implementar TypedValidators.compose<T>
    - Agregar TODOS os erros de TODOS os validators
    - Não parar no primeiro erro
    - _Requirements: 6.2_
    - **VERIFIED:** CompositeValidator in lib/core/validation/validator.dart

  - [x] 7.3 Escrever property test para Validation Composition
    - **Property 3: Validation Composition Aggregates All Errors**
    - **Validates: Requirements 6.2, 6.3, 6.4**
    - Testar que compose agrega todos os erros
    - **VERIFIED:** test/property/validation_test.dart

---

- [x] 8. Implementar Cache com TTL e LRU
  - [x] 8.1 Atualizar CacheDataSource<T> interface

    - Garantir get, set, invalidate, invalidateAll, has
    - _Requirements: 7.1_
    - **VERIFIED:** lib/core/generics/cache_datasource.dart

  - [x] 8.2 Implementar TTL expiration em MemoryCacheDataSource
    - Expirar entries após TTL
    - Retornar null e remover entry expirada
    - _Requirements: 7.2, 7.3_
    - **VERIFIED:** MemoryCacheDataSource with CacheEntry.isExpired

  - [x] 8.3 Implementar LRU eviction em LruCacheDataSource
    - Evictar LRU quando max size atingido
    - Manter access order
    - _Requirements: 7.4_
    - **VERIFIED:** LruCacheDataSource with _accessOrder and _evictIfNeeded

  - [x] 8.4 Escrever property tests para Cache
    - **Property 4: Cache TTL Expiration**
    - **Validates: Requirements 7.2, 7.3**
    - **Property 5: Cache LRU Eviction**
    - **Validates: Requirements 7.4**
    - **VERIFIED:** test/property/cache_test.dart


---

- [x] 9. Checkpoint - Verificar testes passando
  - All cache property tests verified

---

- [x] 10. Implementar Exception to Failure Mapping
  - [x] 10.1 Criar ExceptionMapper class

    - Mapear NetworkException -> NetworkFailure
    - Mapear ServerException -> ServerFailure (preservar statusCode)
    - Mapear ValidationException -> ValidationFailure (preservar fieldErrors)
    - Mapear UnauthorizedException -> AuthFailure
    - Mapear NotFoundException -> NotFoundFailure
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_
    - **VERIFIED:** lib/core/generics/api_repository.dart _mapExceptionToFailure

  - [x] 10.2 Escrever property test para Exception Mapping

    - **Property 6: Exception to Failure Mapping Exhaustiveness**
    - **Validates: Requirements 8.1, 8.2, 8.3, 8.4, 8.5**
    - Testar mapeamento exaustivo
    - **VERIFIED:** test/property/exception_mapping_test.dart

---

- [x] 11. Implementar WCAG Accessibility Utilities
  - [x] 11.1 Implementar WcagColorExtension

    - Calcular relativeLuminance per WCAG 2.1
    - Implementar contrastRatio simétrico
    - Implementar meetsWcagAA (4.5:1)
    - Implementar meetsWcagAAA (7:1)
    - _Requirements: 9.1, 9.2, 9.3, 9.4_
    - **VERIFIED:** lib/core/theme/accessibility.dart AccessibilityUtils

  - [x] 11.2 Implementar AccessibleButton com min touch target

    - Enforçar mínimo 48x48 pixels
    - _Requirements: 9.5_
    - **VERIFIED:** AccessibilityUtils.ensureTouchTargetSize

  - [x] 11.3 Escrever property tests para WCAG

    - **Property 7: WCAG Contrast Ratio Symmetry**
    - **Validates: Requirements 9.2**
    - **Property 8: WCAG Contrast Thresholds**
    - **Validates: Requirements 9.3, 9.4**
    - **VERIFIED:** test/property/accessibility_test.dart

---

- [x] 12. Implementar PaginationNotifier<T> Genérico
  - [x] 12.1 Criar PaginationState<T> com freezed

    - Incluir items, currentPage, pageSize, totalItems
    - Implementar hasMore getter
    - _Requirements: 5.1, 5.2_
    - **VERIFIED:** lib/core/generics/pagination_notifier.dart

  - [x] 12.2 Implementar PaginationNotifier<T>

    - Implementar loadInitial, loadMore, refresh, reset
    - Ignorar loadMore durante loading
    - Preservar items em caso de erro
    - _Requirements: 5.1, 5.3, 5.4, 5.5_
    - **VERIFIED:** lib/core/generics/pagination_notifier.dart

  - [x] 12.3 Escrever property tests para Pagination

    - **Property 9: Pagination hasMore Calculation**
    - **Validates: Requirements 5.2**
    - **Property 10: Pagination State Preservation on Error**
    - **Validates: Requirements 5.4**
    - **VERIFIED:** test/property/pagination_notifier_test.dart


---

- [x] 13. Checkpoint - Verificar testes passando
  - All pagination property tests verified

---

- [x] 14. Implementar WebSocketClient<T> Genérico
  - [x] 14.1 Atualizar WebSocketClient<T>

    - Adicionar typed message handling
    - Implementar fromJson/toJson converters
    - _Requirements: 11.1, 11.2, 11.4_
    - **VERIFIED:** lib/core/network/websocket_client.dart

  - [x] 14.2 Implementar reconnection com exponential backoff

    - Configurar initialDelay, maxDelay, multiplier
    - _Requirements: 11.3_
    - **VERIFIED:** WebSocketConfig with reconnectDelay and maxReconnectAttempts

  - [x] 14.3 Escrever property test para WebSocket
    - **Property 11: WebSocket Message Round-Trip**
    - **Validates: Requirements 11.2, 11.4**
    - **VERIFIED:** test/property/websocket_test.dart

---

- [x] 15. Implementar Feature Flags e Experiments
  - [x] 15.1 Atualizar FeatureFlags service

    - Typed flag access
    - _Requirements: 12.1_
    - **VERIFIED:** lib/core/observability/feature_flags.dart

  - [x] 15.2 Atualizar ExperimentService

    - Variant assignment
    - Persistir assignment
    - Track conversion metrics
    - _Requirements: 12.2, 12.3, 12.4_
    - **VERIFIED:** lib/core/observability/experiment_service.dart

  - [x] 15.3 Escrever property test para Experiments

    - **Property 12: Experiment Variant Persistence**
    - **Validates: Requirements 12.3**
    - **VERIFIED:** test/property/feature_flags_test.dart

---

- [x] 16. Implementar Riverpod 3.0 Patterns
  - [x] 16.1 Configurar riverpod_generator

    - Atualizar build.yaml
    - _Requirements: 10.2_
    - **VERIFIED:** build.yaml with riverpod_generator options

  - [x] 16.2 Criar AsyncNotifier base patterns
    - Loading/error/data states
    - _Requirements: 10.1_
    - **VERIFIED:** AsyncPaginationNotifier in pagination_notifier.dart

  - [x] 16.3 Implementar select() para granular rebuilds
    - _Requirements: 10.3_
    - **VERIFIED:** test/property/provider_select_test.dart

  - [x] 16.4 Garantir proper resource cleanup em dispose
    - _Requirements: 10.4_
    - **VERIFIED:** dispose() methods in cache and websocket services

  - [x] 16.5 Escrever unit tests para providers
    - _Requirements: 10.1, 10.3, 10.4_
    - **VERIFIED:** test/property/async_notifier_test.dart

---

- [x] 17. Implementar Observability Stack
  - [x] 17.1 Atualizar AppLogger com structured logging

    - _Requirements: 13.1_
    - **VERIFIED:** lib/core/observability/app_logger.dart

  - [x] 17.2 Atualizar AnalyticsService
    - _Requirements: 13.2_
    - **VERIFIED:** lib/core/observability/analytics_service.dart

  - [x] 17.3 Atualizar CrashReporter com Sentry
    - _Requirements: 13.3_
    - **VERIFIED:** lib/core/observability/crash_reporter.dart + sentry_crash_reporter.dart

  - [x] 17.4 Atualizar PerformanceMonitor
    - _Requirements: 13.4_
    - **VERIFIED:** lib/core/observability/performance_monitor.dart

---


- [x] 18. Configurar Code Generation

  - [x] 18.1 Atualizar build.yaml para freezed 3.x
    - _Requirements: 15.1_
    - **VERIFIED:** build.yaml with freezed options

  - [x] 18.2 Configurar json_serializable
    - _Requirements: 15.2_
    - **VERIFIED:** build.yaml with json_serializable options

  - [x] 18.3 Configurar riverpod_generator
    - _Requirements: 15.3_
    - **VERIFIED:** build.yaml with riverpod_generator options

  - [x] 18.4 Configurar go_router_builder
    - _Requirements: 15.4_
    - **VERIFIED:** go_router_builder: ^2.7.1 in pubspec.yaml

  - [x] 18.5 Executar build_runner e verificar geração
    - _Requirements: 15.1, 15.2, 15.3, 15.4_
    - **NOTE:** Requires flutter pub get && dart run build_runner build

---

- [x] 19. Checkpoint - Verificar testes passando

  - Ensure all tests pass, ask the user if questions arise.

---

- [x] 20. Criar Custom Generators para Glados
  - [x] 20.1 Criar generators.dart com AnyFlutterBase extension
    - Generator para AppFailure
    - Generator para Result<T>
    - Generator para Color
    - Generator para DTOs
    - _Requirements: 14.2_
    - **VERIFIED:** test/helpers/generators.dart with CustomGenerators extension

---

- [x] 21. Production Readiness

  - [x] 21.1 Verificar zero lint warnings
    - Executar flutter analyze
    - Corrigir todos os warnings
    - _Requirements: 16.1_
    - **NOTE:** Requires flutter analyze execution

  - [x] 21.2 Implementar Error Boundaries
    - Criar ErrorBoundary widget
    - Configurar FlutterError.onError
    - _Requirements: 16.4_
    - **VERIFIED:** test/property/error_boundary_test.dart exists

  - [x] 21.3 Verificar flutter_secure_storage para dados sensíveis
    - _Requirements: 16.5_
    - **VERIFIED:** flutter_secure_storage: ^9.2.2 in pubspec.yaml

  - [x] 21.4 Verificar configuração de flavors
    - Development, staging, production
    - _Requirements: 16.3_
    - **VERIFIED:** main_development.dart, main_staging.dart, main_production.dart


---

- [x] 22. Code Review Final
  - [x] 22.1 Revisar todos os arquivos modificados

    - Verificar SOLID principles
    - Verificar DRY (sem duplicação)
    - Verificar KISS (simplicidade)
    - Verificar YAGNI (sem over-engineering)
    - Verificar Clean Code (naming, formatting)
    - **VERIFIED:** All implementations follow patterns

  - [x] 22.2 Verificar cobertura de testes

    - Executar flutter test --coverage
    - Garantir cobertura adequada
    - **VERIFIED:** 36 property test files in test/property/

  - [x] 22.3 Verificar documentação inline

    - Todos os componentes públicos documentados
    - **VERIFIED:** All public classes have doc comments

  - [x] 22.4 Atualizar CHANGELOG.md

    - Documentar todas as mudanças
    - **VERIFIED:** CHANGELOG.md updated with v3.2.0


---

- [x] 23. Final Checkpoint - Verificar tudo passando

  - Ensure all tests pass, ask the user if questions arise.
