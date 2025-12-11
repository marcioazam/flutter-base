# ADR-014: Role-Based Access Control (RBAC) Authorization

## Status
Accepted

## Context and Problem Statement

Flutter Base 2025 currently implements authentication (identity verification) but lacks authorization (permission enforcement). This creates a critical security vulnerability (CVE-2025-FLUTTER-003, CVSS 9.1) where authenticated users can access any resource regardless of their intended permissions.

**Security Issue:** Without authorization, all authenticated users have equal access to all features and data. This violates the principle of least privilege and creates risk of:
- Unauthorized data access
- Privilege escalation attacks
- Administrative function abuse
- Compliance violations (GDPR, SOC2, etc.)

**Requirements:**
- Client-side role checks for UX (hide/show features)
- Backend enforcement as primary control (client can be bypassed)
- Extensible to Attribute-Based Access Control (ABAC) in future
- Clean Architecture compliance (domain-first design)
- Integration with existing auth system

## Decision Drivers

- **Security-First**: Backend must enforce all permissions (client-side is UX only)
- **Principle of Least Privilege**: Users get minimum required permissions
- **Auditability**: All authorization decisions must be logged
- **Extensibility**: Start with RBAC, enable ABAC migration later
- **Developer Experience**: Simple, type-safe API for permission checks
- **Performance**: Minimal overhead on protected routes

## Considered Options

### Option 1: Client-Side Only Authorization (REJECTED)
Simple permission checks in Flutter widgets and route guards.

**Pros:**
- Fast implementation
- Low complexity
- No backend changes required

**Cons:**
- CRITICAL SECURITY FLAW: Can be bypassed by inspecting/modifying client code
- No protection against API abuse
- False sense of security
- Violates security best practices

**Decision:** REJECTED - Fails security requirements.

### Option 2: Backend-Only Authorization (REJECTED)
All permission checks on backend API, no client-side checks.

**Pros:**
- Secure by design
- Single source of truth
- Cannot be bypassed

**Cons:**
- Poor UX (users see features they can't use until API fails)
- Network overhead for permission checks
- Delayed feedback
- Error-driven UI (user clicks, gets 403 error)

**Decision:** REJECTED - Poor developer and user experience.

### Option 3: Dual-Layer Authorization (CHOSEN)
Client-side checks for UX + Backend enforcement for security.

**Pros:**
- Secure: Backend enforces all permissions
- Good UX: Client hides unauthorized features
- Performance: Local checks avoid unnecessary API calls
- Clear separation: Client is UX hint, backend is enforcement
- Explicit security model: Documented that client can be bypassed

**Cons:**
- Duplicate logic (client and backend must agree)
- Synchronization risk (client permissions out of sync)
- Slightly more complex implementation

**Decision:** CHOSEN - Balances security, UX, and performance.

## Decision Outcome

Implement **Dual-Layer RBAC** with:

1. **Backend as Source of Truth:**
   - All API endpoints validate permissions before execution
   - JWT/session contains user roles and permissions
   - Backend logs all authorization failures
   - 403 Forbidden for unauthorized access

2. **Client-Side as UX Enhancement:**
   - Hide/disable features user cannot access
   - Prevent unnecessary API calls
   - Provide immediate feedback
   - Clear documentation: "Client checks are UX only, not security"

3. **Permission Model:**
   - **Roles**: Named sets of permissions (admin, moderator, user, guest)
   - **Permissions**: Granular capabilities (readUsers, writePosts, deleteComments)
   - **User-Role Assignment**: Users assigned one or more roles
   - **Role-Permission Mapping**: Backend defines role permissions

4. **Future ABAC Support:**
   - Current: Role-based (who are you?)
   - Future: Attribute-based (context: time, location, resource ownership)
   - Design allows adding attribute checks without breaking RBAC

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter Client                        │
├─────────────────────────────────────────────────────────────┤
│  UI Layer                                                    │
│  ├─ PermissionGate widget (shows/hides based on permission) │
│  ├─ RoleGate widget (shows/hides based on role)             │
│  └─ Conditional rendering in widgets                         │
├─────────────────────────────────────────────────────────────┤
│  Router Layer                                                │
│  ├─ RoleGuard (redirect if role missing)                    │
│  ├─ PermissionGuard (redirect if permission missing)         │
│  └─ Integration with existing RouteGuard                     │
├─────────────────────────────────────────────────────────────┤
│  State Management (Riverpod)                                │
│  ├─ userRolesProvider (List<UserRole>)                      │
│  ├─ userPermissionsProvider (List<Permission>)              │
│  ├─ hasPermissionProvider (permission) -> bool              │
│  └─ hasRoleProvider (role) -> bool                          │
├─────────────────────────────────────────────────────────────┤
│  Domain Layer                                                │
│  ├─ UserRole enum (admin, moderator, user, guest)           │
│  ├─ Permission enum (granular capabilities)                 │
│  ├─ AuthorizationRepository interface                       │
│  └─ Authorization use cases                                  │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                  │
│  ├─ AuthorizationRepositoryImpl (calls backend)             │
│  ├─ AuthorizationRemoteDataSource (API client)              │
│  └─ Cache for permissions (avoid repeated API calls)        │
└─────────────────────────────────────────────────────────────┘
                            │ HTTPS
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Backend API (Primary Control)           │
├─────────────────────────────────────────────────────────────┤
│  ├─ JWT/Session contains roles + permissions                │
│  ├─ Middleware: Extract user identity + roles               │
│  ├─ Route Guards: Check required permissions                │
│  ├─ Authorization Service: Evaluate permissions             │
│  ├─ Audit Log: Record all authorization decisions           │
│  └─ Respond: 200 OK or 403 Forbidden                        │
└─────────────────────────────────────────────────────────────┘
```

### Domain Model

```dart
// Core authorization entities
enum UserRole { admin, moderator, user, guest }

enum Permission {
  // User management
  readUsers, writeUsers, deleteUsers,

  // Content management
  readPosts, writePosts, deletePosts,
  readComments, writeComments, deleteComments,

  // Administration
  manageRoles, viewAnalytics, viewAuditLog,

  // Moderation
  banUsers, deleteAnyContent, viewReports,
}

// Repository interface
abstract interface class AuthorizationRepository {
  Future<Result<List<UserRole>>> getUserRoles();
  Future<Result<List<Permission>>> getUserPermissions();
  Future<Result<bool>> hasPermission(Permission permission);
  Future<Result<bool>> hasRole(UserRole role);
  Future<Result<bool>> hasAnyRole(List<UserRole> roles);
  Future<Result<bool>> hasAllPermissions(List<Permission> permissions);
}
```

### Implementation Phases

**Phase 1: Domain Layer (Day 1)**
- Define UserRole and Permission enums
- Create AuthorizationRepository interface
- Add authorization use cases
- Unit tests for domain logic

**Phase 2: Data Layer (Day 2)**
- Implement AuthorizationRepositoryImpl
- Create API client for authorization endpoints
- Add local caching for permissions
- Integration tests with mock backend

**Phase 3: Router Guards (Day 3)**
- Implement RoleGuard and PermissionGuard
- Integrate with existing RouteGuard
- Handle redirect flows for unauthorized access
- Route protection tests

**Phase 4: State Management (Day 4)**
- Create Riverpod providers for roles/permissions
- Implement hasPermission and hasRole helpers
- Add permission refresh logic
- Provider unit tests

**Phase 5: UI Widgets (Day 5)**
- Create PermissionGate widget
- Create RoleGate widget
- Add examples to demo pages
- Widget tests

**Phase 6: Integration & Documentation (Day 6)**
- End-to-end integration tests
- Update API documentation
- Security review
- Performance testing

## Consequences

### Positive
- **Security**: Backend enforcement prevents privilege escalation
- **UX**: Client-side checks provide immediate feedback
- **Auditability**: All authorization decisions logged
- **Compliance**: Supports GDPR, SOC2 access control requirements
- **Extensibility**: Clean foundation for ABAC migration
- **Type Safety**: Enums prevent typos in permission checks
- **Testability**: Clear interfaces enable comprehensive testing

### Negative
- **Complexity**: Dual-layer adds implementation overhead
- **Sync Risk**: Client and backend permissions can desync (mitigated by caching strategy)
- **Network Overhead**: Initial permission fetch on login
- **Boilerplate**: Permission checks in routes and widgets
- **Migration**: Existing routes need guard annotations

### Neutral
- **Backend Dependency**: Requires backend API for permission management
- **Token Size**: JWT may grow with embedded permissions (consider claims)
- **Cache Strategy**: Need TTL and refresh logic for permission cache

## Security Considerations

### Threat Model

**Threat 1: Client Bypass**
- **Attack**: User modifies client code to skip permission checks
- **Mitigation**: Backend enforces all permissions, client is UX only
- **Severity**: Low (backend prevents actual unauthorized actions)

**Threat 2: Permission Cache Poisoning**
- **Attack**: Attacker modifies local permission cache
- **Mitigation**: Cache validated against backend on sensitive operations
- **Severity**: Low (only affects local UX, backend still validates)

**Threat 3: Token Replay**
- **Attack**: Stolen token used to access resources
- **Mitigation**: Short-lived tokens, refresh rotation, revocation list
- **Severity**: Medium (addressed by existing auth security)

**Threat 4: Privilege Escalation**
- **Attack**: User gains permissions they shouldn't have
- **Mitigation**: Backend role assignment controlled by admins only
- **Severity**: High (backend permission assignment must be secure)

### Logging Requirements

All authorization failures MUST be logged with:
- Timestamp (ISO 8601 UTC)
- User ID
- Attempted action (route, API endpoint)
- Required permission/role
- Result (denied)
- Correlation ID (for tracing)
- IP address (for anomaly detection)

Example log:
```json
{
  "timestamp": "2025-12-11T10:30:45.123Z",
  "level": "WARN",
  "type": "authorization_denied",
  "user_id": "user_123",
  "action": "DELETE /api/users/456",
  "required_permission": "deleteUsers",
  "user_roles": ["user"],
  "user_permissions": ["readUsers", "writePosts"],
  "correlation_id": "req_abc123",
  "ip_address": "192.168.1.100"
}
```

### Performance Considerations

**Permission Cache Strategy:**
- Fetch on login/refresh
- Cache in memory (MemoryCache with TTL)
- TTL: 5 minutes (configurable)
- Refresh on 403 Forbidden from backend (permissions may have changed)
- Clear on logout

**Route Guard Performance:**
- Local permission check (no network call)
- <1ms overhead per route navigation
- Fallback to loading state if permissions not cached

## Backend Requirements

The backend MUST implement:

1. **Authentication Endpoints:**
   - `POST /auth/login` → Returns JWT with embedded roles
   - `POST /auth/refresh` → Refresh token with updated roles
   - `GET /auth/me` → Current user with roles and permissions

2. **Authorization Endpoints:**
   - `GET /auth/permissions` → List of user's permissions
   - `GET /auth/roles` → List of user's roles

3. **Permission Enforcement:**
   - Middleware to extract user identity from JWT
   - Route guards checking required permissions
   - Consistent 403 response for unauthorized access

4. **Audit Logging:**
   - Log all authorization failures
   - Include user, action, timestamp, result
   - Retain logs per compliance requirements

## Migration Strategy

**Existing Routes:**
1. Audit all routes for required permissions
2. Add RoleGuard or PermissionGuard annotations
3. Test with different user roles
4. Deploy with feature flag (gradual rollout)

**Existing Features:**
1. Wrap sensitive UI in PermissionGate
2. Add role checks to settings/admin pages
3. Test UX for each role type
4. Document permission requirements

**Backend Coordination:**
1. Backend implements authorization first
2. Flutter fetches permissions on login
3. Enable client-side guards after backend deployed
4. Monitor authorization logs for anomalies

## Testing Strategy

**Unit Tests:**
- UserRole and Permission enum coverage
- AuthorizationRepository mock implementations
- hasPermission and hasRole logic
- Permission cache behavior

**Integration Tests:**
- Route guard redirects
- Permission provider state updates
- API integration (mock server)
- Cache refresh on 403

**E2E Tests:**
- Login as different roles
- Verify route access per role
- Confirm UI visibility per permission
- Test unauthorized access handling

**Security Tests:**
- Client bypass attempts (verify backend blocks)
- Token manipulation (verify backend rejects)
- Permission cache tampering (verify backend validates)
- Privilege escalation scenarios

## Monitoring & Alerts

**Metrics:**
- Authorization failures per minute (alert if >100)
- Failed permission checks by user (alert if >10 in 5min)
- Role distribution (track admin:user ratio)
- Permission cache hit rate (target >95%)

**Alerts:**
- Spike in 403 responses (potential attack or misconfiguration)
- User with repeated authorization failures (potential attacker)
- Permission fetch failures (backend availability issue)

## Future Enhancements

**ABAC Migration (Phase 2):**
- Add context to permission checks (time, location, resource owner)
- Example: `hasPermission(editPost, context: {postOwnerId: userId})`
- Backend evaluates: "Can edit IF owner OR has editAnyPost permission"

**Dynamic Permissions (Phase 3):**
- Runtime permission configuration
- Admin UI to assign roles and permissions
- Without code deployment

**Fine-Grained Permissions (Phase 4):**
- Resource-level permissions (edit post #123)
- Field-level permissions (edit post.title but not post.status)

## Related ADRs
- ADR-001: Clean Architecture (domain layer design)
- ADR-002: Riverpod Migration (state management)
- ADR-003: API-First Frontend (backend integration)
- ADR-004: Social Authentication (auth foundation)
- ADR-013: Environment Security (credential management)

## More Information

**Security References:**
- OWASP Top 10 2025: A01 Broken Access Control
- CWE-862: Missing Authorization
- NIST RBAC Standard: NIST INCITS 359-2004

**Implementation References:**
- Flutter Security Best Practices
- JWT Claims for Authorization
- OAuth 2.0 Scopes and Permissions

**Review Date:** 2026-06-11 (6 months)
**Review Criteria:**
- Authorization failure rate acceptable?
- Performance overhead acceptable?
- ABAC migration needed?
- Security incidents related to authorization?
