/// User role enumeration for RBAC.
/// Roles are named collections of permissions.
///
/// Security Note: Client-side role checks are for UX only.
/// Backend MUST enforce all authorization decisions.
enum UserRole {
  /// Administrator with full system access.
  /// Permissions: All permissions in the system.
  admin('admin'),

  /// Moderator with content management capabilities.
  /// Permissions: Content moderation, user management (limited).
  moderator('moderator'),

  /// Standard authenticated user.
  /// Permissions: Read/write own content, read public content.
  user('user'),

  /// Unauthenticated or limited access user.
  /// Permissions: Read public content only.
  guest('guest');

  const UserRole(this.value);

  /// String value for serialization and API communication.
  final String value;

  /// Parse role from string value (case-insensitive).
  /// Returns null if value doesn't match any role.
  static UserRole? fromString(String value) {
    final normalized = value.toLowerCase();
    for (final role in UserRole.values) {
      if (role.value == normalized) {
        return role;
      }
    }
    return null;
  }

  /// Check if this role has higher or equal privilege than another role.
  /// Hierarchy: admin > moderator > user > guest
  bool hasPrivilegeOf(UserRole other) {
    const hierarchy = {
      UserRole.admin: 3,
      UserRole.moderator: 2,
      UserRole.user: 1,
      UserRole.guest: 0,
    };
    return hierarchy[this]! >= hierarchy[other]!;
  }

  /// Check if this is an administrative role.
  bool get isAdmin => this == UserRole.admin;

  /// Check if this is a moderator or higher role.
  bool get canModerate => hasPrivilegeOf(UserRole.moderator);

  /// Check if this is an authenticated role (not guest).
  bool get isAuthenticated => this != UserRole.guest;
}

/// Extension for role collections.
extension UserRoleListExtension on List<UserRole> {
  /// Check if collection contains admin role.
  bool get hasAdmin => contains(UserRole.admin);

  /// Check if collection contains moderator or admin role.
  bool get canModerate => any((role) => role.canModerate);

  /// Get highest privilege role in collection.
  UserRole? get highest {
    if (isEmpty) return null;
    return reduce(
      (current, next) => current.hasPrivilegeOf(next) ? current : next,
    );
  }
}
