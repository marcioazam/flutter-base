/// Granular permission enumeration for RBAC.
/// Permissions represent specific capabilities in the system.
///
/// Security Note: Client-side permission checks are for UX only.
/// Backend MUST enforce all authorization decisions.
///
/// Design: Permissions are organized by domain (users, posts, comments, etc.)
/// to facilitate future ABAC migration and permission management.
enum Permission {
  // ==================== User Management ====================
  /// Read user profiles and lists.
  readUsers('read:users'),

  /// Create and update user profiles.
  writeUsers('write:users'),

  /// Delete user accounts.
  deleteUsers('delete:users'),

  /// Ban or suspend users.
  banUsers('ban:users'),

  // ==================== Post Management ====================
  /// Read posts (public and own).
  readPosts('read:posts'),

  /// Create and edit own posts.
  writePosts('write:posts'),

  /// Delete own posts.
  deletePosts('delete:posts'),

  /// Delete any user's posts (moderation).
  deleteAnyPost('delete:posts:any'),

  // ==================== Comment Management ====================
  /// Read comments.
  readComments('read:comments'),

  /// Create and edit own comments.
  writeComments('write:comments'),

  /// Delete own comments.
  deleteComments('delete:comments'),

  /// Delete any user's comments (moderation).
  deleteAnyComment('delete:comments:any'),

  // ==================== Role & Permission Management ====================
  /// Assign and revoke user roles.
  manageRoles('manage:roles'),

  /// View and modify system permissions.
  managePermissions('manage:permissions'),

  // ==================== Analytics & Monitoring ====================
  /// View analytics dashboards.
  viewAnalytics('view:analytics'),

  /// View audit logs and security events.
  viewAuditLog('view:audit_log'),

  /// Export data and reports.
  exportData('export:data'),

  // ==================== Content Moderation ====================
  /// View user reports and flags.
  viewReports('view:reports'),

  /// Process moderation queue.
  processReports('process:reports'),

  /// Access moderation tools.
  moderateContent('moderate:content'),

  // ==================== System Administration ====================
  /// Manage system configuration.
  manageConfig('manage:config'),

  /// View system health and metrics.
  viewSystemHealth('view:system_health'),

  /// Execute administrative commands.
  executeAdminCommands('execute:admin_commands');

  const Permission(this.value);

  /// String value for serialization and API communication.
  /// Format: "action:resource" or "action:resource:scope"
  final String value;

  /// Parse permission from string value (case-sensitive).
  /// Returns null if value doesn't match any permission.
  static Permission? fromString(String value) {
    for (final permission in Permission.values) {
      if (permission.value == value) {
        return permission;
      }
    }
    return null;
  }

  /// Get the action part of the permission (before first colon).
  String get action {
    final parts = value.split(':');
    return parts.isNotEmpty ? parts[0] : '';
  }

  /// Get the resource part of the permission (between first and second colon).
  String get resource {
    final parts = value.split(':');
    return parts.length > 1 ? parts[1] : '';
  }

  /// Get the scope part of the permission (after second colon, if exists).
  String? get scope {
    final parts = value.split(':');
    return parts.length > 2 ? parts[2] : null;
  }

  /// Check if this is a read-only permission.
  bool get isReadOnly => action == 'read' || action == 'view';

  /// Check if this is a write permission.
  bool get isWrite => action == 'write' || action == 'create';

  /// Check if this is a delete permission.
  bool get isDelete => action == 'delete';

  /// Check if this is an administrative permission.
  bool get isAdmin =>
      action == 'manage' ||
      action == 'execute' ||
      resource == 'config' ||
      resource == 'roles' ||
      resource == 'permissions';
}

/// Extension for permission collections.
extension PermissionListExtension on List<Permission> {
  /// Check if collection contains any administrative permission.
  bool get hasAdminPermission => any((p) => p.isAdmin);

  /// Check if collection contains any delete permission.
  bool get canDelete => any((p) => p.isDelete);

  /// Check if collection contains any write permission.
  bool get canWrite => any((p) => p.isWrite);

  /// Get all permissions for a specific resource.
  List<Permission> forResource(String resource) =>
      where((p) => p.resource == resource).toList();

  /// Get all permissions with a specific action.
  List<Permission> withAction(String action) =>
      where((p) => p.action == action).toList();

  /// Check if has permission to perform action on resource.
  bool canPerform(String action, String resource) =>
      any((p) => p.action == action && p.resource == resource);
}

/// Default role-permission mappings.
/// These are reference mappings; actual permissions should come from backend.
abstract final class RolePermissions {
  /// Permissions for guest role (unauthenticated).
  static const guest = <Permission>[
    Permission.readPosts,
    Permission.readComments,
  ];

  /// Permissions for standard user role.
  static const user = <Permission>[
    Permission.readPosts,
    Permission.writePosts,
    Permission.deletePosts,
    Permission.readComments,
    Permission.writeComments,
    Permission.deleteComments,
    Permission.readUsers,
  ];

  /// Permissions for moderator role.
  static const moderator = <Permission>[
    ...user,
    Permission.deleteAnyPost,
    Permission.deleteAnyComment,
    Permission.banUsers,
    Permission.viewReports,
    Permission.processReports,
    Permission.moderateContent,
  ];

  /// Permissions for admin role.
  static const admin = Permission.values;

  /// Get permissions for a specific role.
  /// Returns empty list for unknown roles.
  static List<Permission> forRole(String role) => switch (role.toLowerCase()) {
    'admin' => admin,
    'moderator' => moderator,
    'user' => user,
    'guest' => guest,
    _ => <Permission>[],
  };
}
