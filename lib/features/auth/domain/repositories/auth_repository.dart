import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_base_2025/features/auth/domain/entities/user.dart';

/// Authentication repository interface.
/// Defined in domain layer - no external dependencies.
abstract interface class AuthRepository {
  /// Login with email and password.
  Future<Result<User>> login(String email, String password);

  /// Login with OAuth provider.
  Future<Result<User>> loginWithOAuth(OAuthProvider provider);

  /// Register new user.
  Future<Result<User>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Logout current user.
  Future<Result<void>> logout();

  /// Get current authenticated user.
  Future<Result<User?>> getCurrentUser();

  /// Refresh authentication token.
  Future<Result<void>> refreshToken();

  /// Check if user is authenticated.
  Future<bool> isAuthenticated();

  /// Watch authentication state changes.
  Stream<AuthState> watchAuthState();
}

/// OAuth provider types.
enum OAuthProvider {
  google,
  apple,
}

/// Authentication state.
sealed class AuthState {
  const AuthState();
}

final class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.user);
  final User user;
}

final class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

final class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

final class AuthStateError extends AuthState {
  const AuthStateError(this.message);
  final String message;
}

/// Extension for checking auth state.
extension AuthStateExtension on AuthState {
  bool get isAuthenticated => this is AuthStateAuthenticated;
  bool get isLoading => this is AuthStateLoading;
  User? get user => switch (this) {
        AuthStateAuthenticated(user: final u) => u,
        _ => null,
      };
}
