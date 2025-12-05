# ADR-004: Social Authentication

## Status

Accepted

## Context

Modern mobile applications require social login capabilities to reduce friction during user onboarding. Users expect to sign in with their existing Google, Apple, or Facebook accounts rather than creating new credentials.

### Requirements

- Google Sign-In for Android and iOS
- Apple Sign-In (required for iOS App Store if other social logins are offered)
- Facebook Sign-In for broader social coverage
- Token exchange with backend for app JWT

### Options Considered

1. **Firebase Authentication** - Full-featured but adds Firebase dependency
2. **Individual SDKs** - google_sign_in, sign_in_with_apple, flutter_facebook_auth
3. **Auth0/Okta** - Enterprise solutions with additional cost

## Decision

Use individual social authentication SDKs (Option 2) with a unified `SocialAuthService` abstraction.

### Rationale

- **No vendor lock-in**: Each provider SDK is independent
- **Minimal dependencies**: Only add what's needed
- **Full control**: Direct access to provider features
- **Cost effective**: No additional service fees

## Implementation

```dart
abstract interface class SocialAuthService {
  Future<Result<SocialCredential>> signInWithGoogle();
  Future<Result<SocialCredential>> signInWithApple();
  Future<Result<SocialCredential>> signInWithFacebook();
  Future<void> signOut();
}
```

### Packages

- `google_sign_in: ^6.2.0`
- `sign_in_with_apple: ^6.1.0`
- `flutter_facebook_auth: ^7.0.0`

## Consequences

### Positive

- Clean abstraction layer for all social providers
- Easy to add new providers
- Backend receives standardized credential format
- No additional service costs

### Negative

- Must maintain configuration for each provider
- Different setup requirements per platform
- Token refresh handling varies by provider

### Neutral

- Requires backend endpoint for token exchange
- Each provider has different scopes and permissions

## References

- [Google Sign-In Documentation](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple Documentation](https://pub.dev/packages/sign_in_with_apple)
- [Facebook Auth Documentation](https://pub.dev/packages/flutter_facebook_auth)
