// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRemoteDataSourceHash() =>
    r'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0';

/// Provider for AuthRemoteDataSource.
///
/// Copied from [authRemoteDataSource].
@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider =
    AutoDisposeProvider<AuthRemoteDataSource>.internal(
  authRemoteDataSource,
  name: r'authRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRemoteDataSourceRef = AutoDisposeProviderRef<AuthRemoteDataSource>;
String _$authRepositoryHash() => r'b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1';

/// Provider for AuthRepository.
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$authStateHash() => r'c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2';

/// Provider for auth state stream with cleanup.
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<AuthState>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateRef = AutoDisposeStreamProviderRef<AuthState>;
String _$isAuthenticatedHash() => r'd4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3';

/// Provider for checking if user is authenticated.
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeFutureProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsAuthenticatedRef = AutoDisposeFutureProviderRef<bool>;
String _$loginNotifierHash() => r'e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4';

/// Notifier for login operations with cleanup.
///
/// Copied from [LoginNotifier].
@ProviderFor(LoginNotifier)
final loginNotifierProvider =
    AutoDisposeAsyncNotifierProvider<LoginNotifier, void>.internal(
  LoginNotifier.new,
  name: r'loginNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loginNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoginNotifier = AutoDisposeAsyncNotifier<void>;
String _$logoutNotifierHash() => r'f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5';

/// Notifier for logout operations.
///
/// Copied from [LogoutNotifier].
@ProviderFor(LogoutNotifier)
final logoutNotifierProvider =
    AutoDisposeAsyncNotifierProvider<LogoutNotifier, void>.internal(
  LogoutNotifier.new,
  name: r'logoutNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$logoutNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LogoutNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
