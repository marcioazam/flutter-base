# Implementation Plan

- [x] 1. Remover arquivos duplicados e órfãos


  - [x] 1.1 Remover dio_client.dart


    - Delete `lib/core/network/dio_client.dart`
    - Este arquivo duplica funcionalidade de api_client.dart
    - _Requirements: 1.1, 1.2_
  - [x] 1.2 Atualizar imports de dio_client para api_client


    - Update `lib/features/auth/data/datasources/auth_remote_datasource.dart`
    - Update `lib/features/auth/presentation/providers/auth_provider.dart`
    - _Requirements: 1.3, 3.3_
  - [x] 1.3 Remover pasta sync vazia


    - Delete `lib/core/sync/` folder
    - _Requirements: 4.2_
  - [x] 1.4 Remover BaseLocalDataSource de base_datasource.dart


    - Remove interface BaseLocalDataSource from `lib/core/generics/base_datasource.dart`
    - Keep only BaseRemoteDataSource
    - _Requirements: 4.1_

- [x] 2. Corrigir auth_provider.dart



  - [x] 2.1 Remover imports quebrados

    - Remove import of `secure_storage.dart` (não existe)
    - Remove import of `auth_local_datasource.dart` (não existe)
    - _Requirements: 2.1, 2.2_
  - [x] 2.2 Corrigir authRepositoryProvider

    - Update to use TokenStorage and ApiClient correctly
    - Remove dependency on AuthLocalDataSource
    - _Requirements: 3.1, 3.2_
  - [x] 2.3 Simplificar providers de auth

    - Remove unused providers
    - Ensure proper cleanup with ref.onDispose
    - _Requirements: 3.1_

- [x] 3. Corrigir auth_repository_impl.dart



  - [x] 3.1 Atualizar constructor

    - Remove ApiClient parameter (use datasource instead)
    - Keep TokenStorage and AuthRemoteDataSource
    - _Requirements: 3.2_
  - [x] 3.2 Corrigir método logout

    - Update to not require token parameter
    - _Requirements: 3.2_


- [x] 4. Corrigir auth_remote_datasource.dart

  - [x] 4.1 Atualizar import de ApiClient

    - Change from dio_client.dart to api_client.dart
    - _Requirements: 3.3_

  - [x] 4.2 Atualizar métodos para usar novo ApiClient

    - Update login, register, logout, getCurrentUser, refreshToken
    - Use typed methods with fromJson
    - _Requirements: 3.3_

- [x] 5. Checkpoint - Verificar compilação


  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Atualizar arquivos de teste




  - [x] 6.1 Corrigir mocks.dart

    - Remove import of `secure_storage.dart`
    - Remove import of `sync_queue.dart`
    - Remove import of `auth_local_datasource.dart`
    - Remove MockSecureStorage, MockSyncQueue, MockAuthLocalDataSource

    - _Requirements: 7.1, 2.3, 2.4_
  - [x] 6.2 Corrigir generators.dart

    - Remove import of `sync_queue.dart`
    - Remove SyncAction generator
    - _Requirements: 7.2, 2.4_

- [x] 7. Gerar arquivos de código


  - [x] 7.1 Executar build_runner


    - Run `dart run build_runner build --delete-conflicting-outputs`
    - Generate auth_provider.g.dart
    - Generate freezed and json_serializable files
    - _Requirements: 6.1, 6.2, 6.3_



- [x] 8. Checkpoint - Verificar testes


  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Property-based tests para auth flow


  - [x] 9.1 Write property test for unauthenticated redirect

    - **Property 1: Unauthenticated Redirect**
    - **Validates: Requirements 8.2**

  - [x] 9.2 Write property test for login token storage

    - **Property 2: Login Token Storage**

    - **Validates: Requirements 8.3**

  - [x] 9.3 Write property test for logout token clearing
    - **Property 3: Logout Token Clearing**
    - **Validates: Requirements 8.4**


- [x] 10. Final Checkpoint - Verificar tudo

  - Ensure all tests pass, ask the user if questions arise.
