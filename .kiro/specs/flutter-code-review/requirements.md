# Requirements Document

## Introduction

Este documento especifica os requisitos para o code review e correção do projeto Flutter Base 2025. O objetivo é identificar e corrigir código órfão, remover lógica de backend, integrar componentes desconectados e preparar o projeto para produção como um frontend puro consumindo API Python.

## Glossary

- **FlutterBaseApp**: Aplicação Flutter frontend que consome API Python backend
- **Código Órfão**: Código que existe mas não está integrado ao fluxo principal da aplicação
- **DTO**: Data Transfer Object - objeto para transferência de dados entre camadas
- **Provider**: Componente Riverpod para gerenciamento de estado
- **Datasource**: Fonte de dados (remota ou local)

## Requirements

### Requirement 1: Remover Arquivos Duplicados

**User Story:** As a developer, I want to have a single source of truth for API client configuration, so that I can avoid confusion and maintenance issues.

#### Acceptance Criteria

1. WHEN the project is analyzed THEN FlutterBaseApp SHALL have only one ApiClient implementation
2. WHEN dio_client.dart and api_client.dart are compared THEN FlutterBaseApp SHALL keep api_client.dart (versão completa com error handling)
3. WHEN dio_client.dart is removed THEN FlutterBaseApp SHALL update all imports to use api_client.dart

### Requirement 2: Criar Arquivos Faltantes

**User Story:** As a developer, I want all imported files to exist, so that the project compiles without errors.

#### Acceptance Criteria

1. WHEN auth_provider.dart imports secure_storage.dart THEN FlutterBaseApp SHALL create secure_storage.dart or update import to token_storage.dart
2. WHEN auth_provider.dart imports auth_local_datasource.dart THEN FlutterBaseApp SHALL remove this import (frontend não precisa de cache local)
3. WHEN mocks.dart imports sync_queue.dart THEN FlutterBaseApp SHALL remove this import and related mocks
4. WHEN generators.dart imports sync_queue.dart THEN FlutterBaseApp SHALL remove this import and related generators

### Requirement 3: Corrigir Integrações do Auth

**User Story:** As a developer, I want the authentication flow to be properly integrated, so that login/logout works correctly.

#### Acceptance Criteria

1. WHEN auth_provider.dart is analyzed THEN FlutterBaseApp SHALL use AuthRepositoryImpl with correct dependencies
2. WHEN AuthRepositoryImpl is instantiated THEN FlutterBaseApp SHALL inject TokenStorage and ApiClient correctly
3. WHEN auth_remote_datasource.dart uses ApiClient THEN FlutterBaseApp SHALL use the complete ApiClient from api_client.dart

### Requirement 4: Remover Lógica de Backend

**User Story:** As a developer, I want the frontend to be pure, so that all business logic and data persistence is handled by the Python API.

#### Acceptance Criteria

1. WHEN base_datasource.dart defines BaseLocalDataSource THEN FlutterBaseApp SHALL remove this interface (cache é responsabilidade do backend)
2. WHEN sync folder exists THEN FlutterBaseApp SHALL remove the empty sync folder
3. WHEN SyncQueue is referenced THEN FlutterBaseApp SHALL remove all references
4. WHEN local cache logic exists THEN FlutterBaseApp SHALL remove it (exceto token storage)

### Requirement 5: Limpar Código Órfão

**User Story:** As a developer, I want all code to be connected to the main flow, so that there is no dead code in the project.

#### Acceptance Criteria

1. WHEN base_repository.dart is not used THEN FlutterBaseApp SHALL evaluate if it should be removed or integrated
2. WHEN base_usecase.dart is not used THEN FlutterBaseApp SHALL evaluate if it should be removed or integrated
3. WHEN code is not reachable from main.dart THEN FlutterBaseApp SHALL remove or integrate it

### Requirement 6: Gerar Arquivos de Código

**User Story:** As a developer, I want all generated files to exist, so that the project compiles correctly.

#### Acceptance Criteria

1. WHEN auth_provider.dart has part directive THEN FlutterBaseApp SHALL ensure auth_provider.g.dart is generated
2. WHEN freezed classes exist THEN FlutterBaseApp SHALL ensure .freezed.dart files are generated
3. WHEN json_serializable classes exist THEN FlutterBaseApp SHALL ensure .g.dart files are generated

### Requirement 7: Atualizar Testes

**User Story:** As a developer, I want tests to compile and run, so that I can verify the application works correctly.

#### Acceptance Criteria

1. WHEN mocks.dart imports non-existent files THEN FlutterBaseApp SHALL update imports to existing files
2. WHEN generators.dart references non-existent types THEN FlutterBaseApp SHALL remove or update references
3. WHEN tests reference removed code THEN FlutterBaseApp SHALL update tests accordingly

### Requirement 8: Validar Fluxo Principal

**User Story:** As a developer, I want the main application flow to work end-to-end, so that users can login, navigate, and logout.

#### Acceptance Criteria

1. WHEN app starts THEN FlutterBaseApp SHALL initialize config, router, and providers correctly
2. WHEN user is not authenticated THEN FlutterBaseApp SHALL redirect to login page
3. WHEN user logs in THEN FlutterBaseApp SHALL store tokens and navigate to home
4. WHEN user logs out THEN FlutterBaseApp SHALL clear tokens and redirect to login
