import 'dart:async';

import 'package:flutter_base_2025/core/network/api_client.dart';
import 'package:flutter_base_2025/core/storage/token_storage.dart';
import 'package:flutter_base_2025/features/auth/data/data_sources/auth_remote_datasource.dart';
import 'package:flutter_base_2025/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_base_2025/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export '../../domain/repositories/auth_repository.dart' show AuthState, AuthStateAuthenticated, AuthStateError, AuthStateExtension, AuthStateLoading, AuthStateUnauthenticated;

part 'auth_provider.g.dart';

/// Provider for AuthRemoteDataSource.
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) => AuthRemoteDataSourceImpl(ref.watch(apiClientProvider));

/// Provider for AuthRepository.
@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );

/// Provider for auth state stream with cleanup.
@riverpod
Stream<AuthState> authState(Ref ref) {
  final controller = StreamController<AuthState>();
  final subscription = ref.watch(authRepositoryProvider).watchAuthState().listen(
    controller.add,
    onError: controller.addError,
  );

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
}

/// Provider for checking if user is authenticated.
@riverpod
Future<bool> isAuthenticated(Ref ref) async => ref.watch(authRepositoryProvider).isAuthenticated();

/// Notifier for login operations with cleanup.
@riverpod
class LoginNotifier extends _$LoginNotifier {
  Timer? _debounceTimer;

  @override
  Future<void> build() async {
    // Cleanup timer on dispose
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).login(email, password);
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .loginWithOAuth(OAuthProvider.google);
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> loginWithApple() async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .loginWithOAuth(OAuthProvider.apple);
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  /// Debounced login for form validation.
  void loginDebounced(String email, String password) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      login(email, password);
    });
  }
}

/// Notifier for logout operations.
@riverpod
class LogoutNotifier extends _$LogoutNotifier {
  @override
  Future<void> build() async {}

  Future<void> logout() async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).logout();
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
