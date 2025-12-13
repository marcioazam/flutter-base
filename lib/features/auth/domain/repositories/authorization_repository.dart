import 'package:flutter_base_2025/core/utils/result.dart';
import 'package:flutter_base_2025/features/auth/domain/entities/permission.dart';
import 'package:flutter_base_2025/features/auth/domain/entities/user_role.dart';
import 'package:meta/meta.dart';

/// Authorization repository interface.
/// Defines operations for role and permission management.
///
/// Security Note: This is a client-side repository for UX purposes.
/// All authorization decisions MUST be enforced by the backend API.
/// Client-side checks can be bypassed; never trust client authorization alone.
///
/// Implementation Strategy:
/// - Fetch roles and permissions from backend on login/refresh
/// - Cache locally for performance (avoid network calls on every check)
/// - Refresh cache on 403 responses (permissions may have changed)
/// - Clear cache on logout
abstract interface class AuthorizationRepository {
  /// Get all roles assigned to the current user.
  ///
  /// Returns:
  /// - Success with list of roles (may be empty for unauthenticated users)
  /// - Failure if unable to fetch roles (network error, auth failure, etc.)
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepo.getUserRoles();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (roles) => print('User roles: $roles'),
  /// );
  /// ```
  Future<Result<List<UserRole>>> getUserRoles();

  /// Get all permissions granted to the current user.
  ///
  /// Permissions are typically computed from roles but may include
  /// user-specific grants or revocations (for fine-grained control).
  ///
  /// Returns:
  /// - Success with list of permissions (may be empty)
  /// - Failure if unable to fetch permissions
  ///
  /// Example:
  /// ```dart
  /// final result = await authRepo.getUserPermissions();
  /// result.fold(
  ///   (failure) => print('Error: $failure'),
  ///   (permissions) => print('User can: $permissions'),
  /// );
  /// ```
  Future<Result<List<Permission>>> getUserPermissions();

  /// Check if user has a specific permission.
  ///
  /// This is a convenience method that:
  /// 1. Fetches user permissions (from cache if available)
  /// 2. Checks if the requested permission is in the list
  ///
  /// Parameters:
  /// - [permission]: The permission to check
  ///
  /// Returns:
  /// - Success(true) if user has the permission
  /// - Success(false) if user does not have the permission
  /// - Failure if unable to determine (network error, etc.)
  ///
  /// Example:
  /// ```dart
  /// final canDelete = await authRepo.hasPermission(Permission.deleteUsers);
  /// if (canDelete.valueOrNull == true) {
  ///   // Show delete button
  /// }
  /// ```
  Future<Result<bool>> hasPermission(Permission permission);

  /// Check if user has a specific role.
  ///
  /// Parameters:
  /// - [role]: The role to check
  ///
  /// Returns:
  /// - Success(true) if user has the role
  /// - Success(false) if user does not have the role
  /// - Failure if unable to determine
  ///
  /// Example:
  /// ```dart
  /// final isAdmin = await authRepo.hasRole(UserRole.admin);
  /// if (isAdmin.valueOrNull == true) {
  ///   // Show admin panel
  /// }
  /// ```
  Future<Result<bool>> hasRole(UserRole role);

  /// Check if user has ANY of the specified roles.
  ///
  /// Useful for "admin OR moderator" type checks.
  ///
  /// Parameters:
  /// - [roles]: List of acceptable roles (OR operation)
  ///
  /// Returns:
  /// - Success(true) if user has at least one of the roles
  /// - Success(false) if user has none of the roles
  /// - Failure if unable to determine
  ///
  /// Example:
  /// ```dart
  /// final canModerate = await authRepo.hasAnyRole([
  ///   UserRole.admin,
  ///   UserRole.moderator,
  /// ]);
  /// ```
  Future<Result<bool>> hasAnyRole(List<UserRole> roles);

  /// Check if user has ALL of the specified roles.
  ///
  /// Useful for compound role requirements.
  ///
  /// Parameters:
  /// - [roles]: List of required roles (AND operation)
  ///
  /// Returns:
  /// - Success(true) if user has all of the roles
  /// - Success(false) if user is missing any role
  /// - Failure if unable to determine
  Future<Result<bool>> hasAllRoles(List<UserRole> roles);

  /// Check if user has ALL of the specified permissions.
  ///
  /// Useful for operations requiring multiple permissions.
  ///
  /// Parameters:
  /// - [permissions]: List of required permissions (AND operation)
  ///
  /// Returns:
  /// - Success(true) if user has all permissions
  /// - Success(false) if user is missing any permission
  /// - Failure if unable to determine
  ///
  /// Example:
  /// ```dart
  /// final canPublish = await authRepo.hasAllPermissions([
  ///   Permission.writePosts,
  ///   Permission.moderateContent,
  /// ]);
  /// ```
  Future<Result<bool>> hasAllPermissions(List<Permission> permissions);

  /// Check if user has ANY of the specified permissions.
  ///
  /// Parameters:
  /// - [permissions]: List of acceptable permissions (OR operation)
  ///
  /// Returns:
  /// - Success(true) if user has at least one permission
  /// - Success(false) if user has none of the permissions
  /// - Failure if unable to determine
  Future<Result<bool>> hasAnyPermission(List<Permission> permissions);

  /// Refresh cached roles and permissions from backend.
  ///
  /// Should be called:
  /// - After receiving 403 Forbidden (permissions may have changed)
  /// - Periodically (e.g., every 5 minutes) for long-lived sessions
  /// - After role assignment changes (if app supports runtime role changes)
  ///
  /// Returns:
  /// - Success(void) if refresh succeeded
  /// - Failure if unable to refresh
  Future<Result<void>> refreshPermissions();

  /// Clear all cached authorization data.
  ///
  /// Should be called:
  /// - On logout
  /// - On user switch
  /// - On authorization failure (security measure)
  ///
  /// Returns:
  /// - Success(void) always (clearing cache cannot fail)
  Future<Result<void>> clearCache();

  /// Watch authorization state changes.
  ///
  /// Emits events when:
  /// - User roles change
  /// - User permissions change
  /// - Cache is refreshed
  ///
  /// Useful for reactive UI updates when authorization changes.
  Stream<AuthorizationState> watchAuthorizationState();
}

/// Authorization state for reactive updates.
sealed class AuthorizationState {
  const AuthorizationState();
}

/// Authorization data loaded and available.
@immutable
final class AuthorizationLoaded extends AuthorizationState {
  const AuthorizationLoaded({required this.roles, required this.permissions});

  final List<UserRole> roles;
  final List<Permission> permissions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizationLoaded &&
          runtimeType == other.runtimeType &&
          roles == other.roles &&
          permissions == other.permissions;

  @override
  int get hashCode => roles.hashCode ^ permissions.hashCode;
}

/// Authorization data is being loaded.
final class AuthorizationLoading extends AuthorizationState {
  const AuthorizationLoading();
}

/// Authorization data failed to load.
@immutable
final class AuthorizationError extends AuthorizationState {
  const AuthorizationError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizationError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Authorization cache cleared (e.g., on logout).
final class AuthorizationCleared extends AuthorizationState {
  const AuthorizationCleared();
}

/// Extension for checking authorization state.
extension AuthorizationStateExtension on AuthorizationState {
  bool get isLoaded => this is AuthorizationLoaded;
  bool get isLoading => this is AuthorizationLoading;
  bool get hasError => this is AuthorizationError;

  List<UserRole>? get roles => switch (this) {
    AuthorizationLoaded(roles: final r) => r,
    _ => null,
  };

  List<Permission>? get permissions => switch (this) {
    AuthorizationLoaded(permissions: final p) => p,
    _ => null,
  };
}
