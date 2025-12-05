# Implementation Plan

## Nota: Polimento Final do Flutter Base 2025

Este plano atualiza o projeto para Flutter 3.38 / Dart 3.10 e adiciona funcionalidades avançadas.
Foco em: Upgrade de plataforma, Drift database, AI preparation, e melhorias de qualidade.

## 1. Platform Upgrade

- [x] 1.1 Atualizar pubspec.yaml para Flutter 3.38 / Dart 3.10
  - Update SDK constraint to `>=3.10.0 <4.0.0`
  - Update Flutter constraint to `>=3.38.0`
  - Update all dependencies to latest compatible versions
  - _Requirements: 1.1_

- [x] 1.2 Configurar Android para 16KB page size
  - Update `android/app/build.gradle` with NDK r28
  - Ensure Java 17 compatibility
  - _Requirements: 1.3, 1.4_

- [x] 1.3 Habilitar Predictive Back Gesture
  - Add `android:enableOnBackInvokedCallback="true"` to AndroidManifest.xml
  - _Requirements: 4.1_

## 2. Drift Database Setup

- [x] 2.1 Adicionar Drift ao pubspec.yaml
  - Add drift, drift_dev, sqlite3_flutter_libs packages
  - Configure build.yaml for Drift code generation
  - _Requirements: 7.1_

- [x] 2.2 Criar AppDatabase base
  - Create `lib/core/database/app_database.dart`
  - Implement BaseTableMixin with common columns
  - Configure migrations
  - _Requirements: 7.2, 7.4_

- [x] 2.3 Criar DriftRepository<T, ID> genérico
  - Create `lib/core/database/drift_repository.dart`
  - Implement CRUD operations returning Result<T>
  - Implement watchAll() stream
  - _Requirements: 8.1, 8.2, 8.3_

- [x] 2.4 Write property test for Repository CRUD Result Type
  - **Property 3: Repository CRUD Result Type**
  - **Validates: Requirements 8.2**

- [x] 2.5 Write property test for Drift Reactive Stream
  - **Property 2: Drift Reactive Stream Emission**
  - **Validates: Requirements 7.5, 8.3**

- [x] 2.6 Criar SyncRepository com conflict resolution
  - Create `lib/core/database/sync_repository.dart`
  - Implement sync() with conflict resolution strategies
  - _Requirements: 8.4_

- [x] 2.7 Write property test for Sync Conflict Resolution
  - **Property 4: Sync Conflict Resolution**
  - **Validates: Requirements 8.4**

## 3. Checkpoint - Database Layer
  - Ensure all tests pass, ask the user if questions arise.

## 4. AI Service Preparation

- [x] 4.1 Criar AIService interface
  - Create `lib/integrations/ai/ai_service.dart`
  - Define generateText, generateTextStream, generateStructured methods
  - _Requirements: 10.1_

- [x] 4.2 Implementar GeminiAIService
  - Add google_generative_ai package (commented, optional)
  - Implement AIService interface
  - Map AI errors to AppFailure hierarchy
  - _Requirements: 10.2, 10.3, 10.4_

- [x] 4.3 Write property test for AI Error Mapping
  - **Property 5: AI Error Mapping**
  - **Validates: Requirements 10.4**

## 5. Error Boundary Widget

- [x] 5.1 Criar ErrorBoundary widget
  - Create `lib/shared/widgets/error_boundary_widget.dart`
  - Implement error catching via FlutterError.onError
  - Implement retry functionality
  - _Requirements: 14.1, 14.2, 14.4_

- [x] 5.2 Criar DefaultErrorWidget
  - Implement user-friendly error UI
  - Add retry button
  - _Requirements: 14.2, 14.4_

- [x] 5.3 Integrar com CrashReporter
  - Call crash reporter on error
  - _Requirements: 14.3_

- [x] 5.4 Write property test for Error Boundary Recovery
  - **Property 9: Error Boundary Recovery**
  - **Validates: Requirements 14.1, 14.2, 14.4**

## 6. PopScope Enhancement

- [x] 6.1 Criar PredictivePopScope widget
  - Create enhanced PopScope with onPopInvokedWithResult
  - Support async confirmation dialogs
  - _Requirements: 4.3_

- [x] 6.2 Write property test for PopScope Navigation Control
  - **Property 1: PopScope Navigation Control**
  - **Validates: Requirements 4.3**

## 7. Checkpoint - Core Widgets
  - Ensure all tests pass, ask the user if questions arise.

## 8. Accessibility Enhancements

- [x] 8.1 Criar AccessibilityTestUtils
  - Create `test/helpers/accessibility_utils.dart`
  - Implement allButtonsHaveLabels checker
  - Implement respectsReducedMotion checker
  - _Requirements: 11.3, 11.5_

- [x] 8.2 Write property test for Semantic Labels
  - **Property 6: Semantic Labels on Interactive Elements**
  - **Validates: Requirements 11.3**

- [x] 8.3 Write property test for Reduced Motion
  - **Property 7: Reduced Motion Respect**
  - **Validates: Requirements 11.5**

## 9. Performance Monitoring

- [x] 9.1 Aprimorar PerformanceMonitor com memory threshold
  - Add memory threshold checking
  - Add cache cleanup callback
  - _Requirements: 12.4_

- [x] 9.2 Write property test for Memory Threshold Cleanup
  - **Property 8: Memory Threshold Cache Cleanup**
  - **Validates: Requirements 12.4**

## 10. Code Quality Setup

- [x] 10.1 Configurar DCM (Dart Code Metrics)
  - Add dart_code_metrics to dev_dependencies
  - Create `analysis_options.yaml` with DCM rules
  - Set complexity threshold to 10
  - _Requirements: 6.1, 6.2, 6.3_

- [x] 10.2 Configurar Patrol para E2E tests
  - Add patrol, patrol_cli to dev_dependencies
  - Create patrol configuration
  - _Requirements: 5.1, 5.2, 5.3_

- [x] 10.3 Criar exemplo de E2E test com Patrol
  - Create example E2E test demonstrating native automation
  - _Requirements: 5.1, 5.2, 5.3_

## 11. Widget Previewer Support

- [x] 11.1 Adicionar Preview annotations
  - Add @Preview annotations to shared widgets
  - Configure width, height, theme parameters
  - _Requirements: 3.1, 3.2_

- [x] 11.2 Criar MultiPreview examples
  - Add @MultiPreview for widget variations
  - Use group parameter for organization
  - _Requirements: 3.3, 3.4_

## 12. Dot Shorthands Migration

- [x] 12.1 Migrar código para dot shorthands
  - Update MainAxisAlignment usages to .start, .center, etc.
  - Update CrossAxisAlignment usages
  - Update EdgeInsets usages to .all(), .symmetric()
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

## 13. Code Generation Optimization

- [x] 13.1 Otimizar build.yaml
  - Configure optimized settings for build_runner
  - Enable parallel builds where possible
  - _Requirements: 13.1_

- [x] 13.2 Revisar annotations freezed/riverpod
  - Use selective copyWith and equal
  - Use keepAlive for long-lived providers
  - _Requirements: 13.2, 13.3_

## 14. Documentation Update

- [x] 14.1 Atualizar README.md
  - Document Flutter 3.38 / Dart 3.10 requirements
  - Document new features (Drift, AI, Error Boundary)
  - Update setup instructions
  - _Requirements: 15.1_

- [x] 14.2 Atualizar CHANGELOG.md
  - Follow Keep a Changelog format
  - Document all changes in this release
  - _Requirements: 15.2_

- [x] 14.3 Criar ADR para Drift migration
  - Document decision to use Drift for local persistence
  - _Requirements: 7.1_

## 15. Final Checkpoint
  - Ensure all tests pass, ask the user if questions arise.
