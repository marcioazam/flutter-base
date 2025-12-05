import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

export '../../domain/repositories/auth_repository.dart' show AuthState;

/// Provider for AuthRemoteDataSource.
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(ref.watch(apiClientProvider));
}

/// Provider for AuthRepository.
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
}

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
Future<bool> isAuthenticated(Ref ref) async {
  return ref.watch(authRepositoryProvider).isAuthenticated();
}

/// Notifier for login operations with cleanup.
@riverpod
class LoginNotifier extends _$LoginNotifier {
  Timer? _debounceTimer;

  @override
  Future<void> build() async {}

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
