import 'dart:async';

import '../../../../core/errors/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository consuming Python API.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  final _authStateController = StreamController<AuthState>.broadcast();

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage {
    _initAuthState();
  }

  Future<void> _initAuthState() async {
    final hasTokens = await _tokenStorage.hasTokens();
    if (hasTokens) {
      final result = await getCurrentUser();
      result.fold(
        (_) => _authStateController.add(const AuthStateUnauthenticated()),
        (user) => user != null
            ? _authStateController.add(AuthStateAuthenticated(user))
            : _authStateController.add(const AuthStateUnauthenticated()),
      );
    } else {
      _authStateController.add(const AuthStateUnauthenticated());
    }
  }

  @override
  Future<Result<User>> login(String email, String password) async {
    _authStateController.add(const AuthStateLoading());

    try {
      final response = await _remoteDataSource.login(email, password);

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      final user = response.user.toEntity();
      _authStateController.add(AuthStateAuthenticated(user));

      return Success(user);
    } on Exception catch (e) {
      _authStateController.add(const AuthStateUnauthenticated());
      return Failure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<User>> loginWithOAuth(OAuthProvider provider) async {
    _authStateController.add(const AuthStateLoading());

    try {
      // OAuth token would come from platform SDK (Google, Apple)
      const oauthToken = 'oauth_token_from_sdk';

      final response = await _remoteDataSource.loginWithOAuth(
        provider.name,
        oauthToken,
      );

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      final user = response.user.toEntity();
      _authStateController.add(AuthStateAuthenticated(user));

      return Success(user);
    } on Exception catch (e) {
      _authStateController.add(const AuthStateUnauthenticated());
      return Failure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _authStateController.add(const AuthStateLoading());

    try {
      final response = await _remoteDataSource.register(email, password, name);

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      final user = response.user.toEntity();
      _authStateController.add(AuthStateAuthenticated(user));

      return Success(user);
    } on Exception catch (e) {
      _authStateController.add(const AuthStateUnauthenticated());
      return Failure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore remote logout errors
    }

    await _tokenStorage.clearTokens();
    _authStateController.add(const AuthStateUnauthenticated());

    return const Success(null);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final userDto = await _remoteDataSource.getCurrentUser();
      return Success(userDto.toEntity());
    } on Exception catch (e) {
      return Failure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return const Failure(AuthFailure('No refresh token available'));
      }

      final response = await _remoteDataSource.refreshToken(refreshToken);
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      return const Success(null);
    } on Exception catch (e) {
      return Failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() => _tokenStorage.hasTokens();

  @override
  Stream<AuthState> watchAuthState() => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
}
