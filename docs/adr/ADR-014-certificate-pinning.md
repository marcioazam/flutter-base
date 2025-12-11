# ADR-014: Production Certificate Pinning Implementation

## Status
Accepted

## Date
2025-12-11

## Context

During security audit, a critical vulnerability was identified:

**CVE-2025-FLUTTER-002** (CVSS 9.3): Certificate pinning disabled/commented out in `lib/core/security/security_utils.dart:18-31`.

### Security Impact

Without certificate pinning, the application is vulnerable to:

1. **Man-in-the-Middle (MITM) Attacks**: Attackers with compromised CAs can intercept traffic
2. **Rogue Certificate Authorities**: Compromise of any trusted CA affects all applications
3. **State-level Surveillance**: Governments can force CAs to issue certificates
4. **Corporate Proxies**: Enterprise SSL inspection can decrypt traffic

### Compliance Requirements

| Standard | Requirement | Status |
|----------|-------------|---------|
| OWASP MASVS | MSTG-NETWORK-4 | Required |
| PCI-DSS v4.0 | Req 4.2.1 | Required for payment apps |
| NIST SP 800-52 | TLS Configuration | Recommended |
| ISO 27001 | A.13.1.3 | Required |

### Risk Assessment

| Threat | Likelihood | Impact | Risk | CVSS |
|--------|-----------|--------|------|------|
| MITM Attack | High | Critical | Critical | 9.3 |
| Data Exfiltration | High | High | Critical | 8.5 |
| Credential Theft | High | Critical | Critical | 9.1 |
| API Key Exposure | Medium | High | High | 7.5 |

## Decision

Implement production-ready certificate pinning with the following architecture:

### 1. CertificatePinningService

Injectable service (not static) following clean architecture:

```dart
final certificatePinningServiceProvider = Provider<CertificatePinningService>((ref) {
  return CertificatePinningService(
    config: CertificatePinningConfig.fromEnvironment(),
    logger: ref.watch(loggerProvider),
  );
});
```

**Key Features:**
- Riverpod provider for dependency injection
- Testable and mockable
- Configurable via environment variables
- Comprehensive logging for monitoring

### 2. SHA-256 SPKI Pinning

Pin Subject Public Key Info (SPKI) instead of entire certificate:

**Advantages:**
- Survives certificate renewal (same key pair)
- Industry standard (HPKP, RFC 7469)
- Smaller pin size (32 bytes)
- Easier rotation

**Algorithm:**
```
1. Extract SubjectPublicKeyInfo from X.509 certificate
2. Encode SPKI in DER format
3. Compute SHA-256 hash
4. Base64 encode → "sha256/{base64Hash}"
```

### 3. Multiple Pins (Primary + Backup)

**Minimum 2 pins required** to enable graceful rotation:

```bash
# Primary (current production certificate)
CERT_PIN_PRIMARY=sha256/r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=

# Backup (next certificate or backup key)
CERT_PIN_BACKUP=sha256/YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=
```

**Rotation Strategy:**
1. Generate new key pair
2. Add new pin as CERT_PIN_BACKUP
3. Deploy application update
4. Activate new certificate on server
5. Move new pin to CERT_PIN_PRIMARY
6. Generate next backup pin

### 4. Fail-Closed Security Model

**Default behavior: Deny**

```dart
// Validation failure → Connection rejected
if (!matched) {
  logger.e('Certificate pin validation FAILED. Possible MITM attack!');
  return CertificateValidationResult(isValid: false, errorMessage: error);
}
```

**Security Principles:**
- Deny by default
- Log all failures (SIEM integration)
- No fallback to standard validation
- Explicit opt-out for development only

### 5. Certificate Expiration Warnings

Proactive monitoring to prevent outages:

```dart
final daysUntilExpiration = certificate.endValidity.difference(DateTime.now()).inDays;

if (daysUntilExpiration <= 30 && daysUntilExpiration > 0) {
  logger.w('Certificate expires in $daysUntilExpiration days. Plan rotation!');
}
```

**Warning Levels:**
- 30 days: Warning (plan rotation)
- 14 days: Alert (prepare rotation)
- 7 days: Critical (execute rotation)
- 0 days: Reject (expired)

### 6. Configuration Mechanism

**Environment Variables (Compile-time):**

```dart
const String.fromEnvironment('CERT_PIN_PRIMARY')
const bool.fromEnvironment('CERT_PIN_ENABLED', defaultValue: true)
```

**Benefits:**
- Type-safe
- Compile-time validation
- No runtime file reads
- Works with Flutter build variants

**Environment Files:**
```
.env.development  → CERT_PIN_ENABLED=false (development)
.env.staging      → CERT_PIN_ENABLED=true (test production pinning)
.env.production   → CERT_PIN_ENABLED=true (enforce)
```

### 7. Logging & Monitoring

**Security Events Logged:**
- Pin validation success/failure
- Matched pin (for rotation tracking)
- Certificate expiration warnings
- Configuration errors
- Timing information (for SLA monitoring)

**SIEM Integration:**
```dart
logger.e(
  'Certificate pin validation FAILED for $host:$port. '
  'Certificate hash: $hashString. '
  'This could indicate a MITM attack or certificate rotation.',
);
```

**Monitoring Metrics:**
- Pin validation failures (alert on >0)
- Expiration warnings (alert at 30/14/7 days)
- Configuration errors (alert immediately)

## Implementation Details

### File Structure

```
lib/core/security/
  ├── certificate_pinning_service.dart  (new)
  │   ├── CertificatePinningService
  │   ├── CertificatePinningConfig
  │   ├── CertificateValidationResult
  │   └── CertificatePinningException
  └── security_utils.dart                (updated)
      └── createPinnedHttpClient()       (deprecated)
```

### API Design

```dart
// 1. Configuration
final config = CertificatePinningConfig.fromEnvironment();
config.validate(); // Throws if invalid

// 2. Service instantiation
final service = CertificatePinningService(
  config: config,
  logger: logger,
);

// 3. Create HTTP client
final client = service.createHttpClient();

// 4. Validation (automatic via badCertificateCallback)
final result = service.validateCertificate(cert, host, port);
if (!result.isValid) {
  // Connection rejected
}
```

### Security Features

| Feature | Implementation | Standard |
|---------|---------------|----------|
| Pin Type | SHA-256 SPKI | RFC 7469 |
| Min Pins | 2 (primary + backup) | OWASP MASVS |
| Comparison | Constant-time | Timing attack prevention |
| Logging | All failures | SIEM integration |
| Expiration | 30-day warning | Proactive monitoring |
| Fail Mode | Closed (deny) | Secure by default |

### Migration Path

**Phase 1: Add Service (Non-breaking)**
- Create `CertificatePinningService`
- Keep legacy `createPinnedHttpClient()`
- Mark legacy as `@Deprecated`

**Phase 2: Update Consumers**
```dart
// Before
final client = createPinnedHttpClient(config);

// After
final service = ref.read(certificatePinningServiceProvider);
final client = service.createHttpClient();
```

**Phase 3: Remove Legacy (v4.0.0)**
- Delete `createPinnedHttpClient()`
- Delete `CertificatePinConfig`

## How to Obtain Certificate Hashes

See `docs/security/CERTIFICATE_PINNING.md` for detailed instructions.

**Quick reference:**

```bash
# Method 1: OpenSSL (recommended)
openssl s_client -servername api.example.com -connect api.example.com:443 \
  < /dev/null 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary \
  | openssl base64

# Method 2: Retrieve Certificate
echo | openssl s_client -servername api.example.com -connect api.example.com:443 2>&1 \
  | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
  > cert.pem

# Extract and hash public key
openssl x509 -in cert.pem -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary \
  | openssl base64
```

**Output format:** `sha256/{base64Hash}`

## Consequences

### Positive

1. **MITM Prevention**: Blocks attacks even if CA is compromised
2. **Compliance**: Meets OWASP MASVS MSTG-NETWORK-4
3. **Monitoring**: All failures logged for threat detection
4. **Rotation**: Graceful certificate rotation with backup pins
5. **Testability**: Injectable service, easy to mock
6. **Type Safety**: Compile-time configuration validation

### Negative

1. **Operational Complexity**: Requires certificate rotation planning
2. **Outage Risk**: Expired pins cause complete failure (mitigated by warnings)
3. **Initial Setup**: Must obtain and configure pins for each environment
4. **Build Variants**: Requires separate .env files per environment

### Neutral

1. **Development Friction**: Can disable pinning via `CERT_PIN_ENABLED=false`
2. **Performance**: Negligible overhead (single hash computation per connection)

### Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Forgot to rotate | Medium | High | 30-day expiration warnings |
| Pin mismatch | Low | Critical | Staging environment testing |
| Lost backup pin | Low | High | Document in secure vault |
| Development blocked | Medium | Low | `CERT_PIN_ENABLED=false` |

## Testing Strategy

### Unit Tests

```dart
test('validates certificate against pinned hash', () {
  final service = CertificatePinningService(config: config, logger: logger);
  final result = service.validateCertificate(cert, 'api.example.com', 443);
  expect(result.isValid, true);
});

test('rejects certificate with wrong hash', () {
  final result = service.validateCertificate(wrongCert, host, port);
  expect(result.isValid, false);
  expect(result.errorMessage, contains('FAILED'));
});

test('warns on expiring certificate', () {
  // Mock certificate expiring in 15 days
  verify(() => logger.w(any(that: contains('expiration warning'))));
});
```

### Integration Tests

1. **Staging Environment**: Test with real pinned certificates
2. **Negative Tests**: Test with self-signed certificate (should fail)
3. **Rotation Simulation**: Update pins and verify graceful transition
4. **Expiration Tests**: Test warning system with near-expiry certificates

### Property-Based Tests

```dart
propertyTest('constant-time comparison is timing-safe', (gen) {
  final a = gen.listOf(gen.byte, length: 32);
  final b = gen.listOf(gen.byte, length: 32);
  // Verify execution time is constant regardless of input
});
```

## Compliance Mapping

### OWASP MASVS

| ID | Requirement | Implementation |
|----|-------------|----------------|
| MSTG-NETWORK-4 | Certificate pinning | CertificatePinningService |
| MSTG-NETWORK-1 | TLS encryption | Enforced by HttpClient |
| MSTG-STORAGE-2 | No hardcoded secrets | Environment variables |
| MSTG-RESILIENCE-1 | Tampering detection | Pin validation |

### OWASP Top 10 2025

| ID | Threat | Mitigation |
|----|--------|------------|
| A02 | Security Misconfiguration | Fail-closed by default |
| A04 | Cryptographic Failures | SHA-256, constant-time compare |
| A09 | Logging Failures | Comprehensive security logging |

### PCI-DSS v4.0

| Requirement | Control | Evidence |
|-------------|---------|----------|
| 4.2.1 | TLS configuration | Certificate pinning |
| 10.2.4 | Security event logging | Pin validation logs |
| 11.3.1 | Penetration testing | Integration tests |

## References

- [RFC 7469: Public Key Pinning Extension for HTTP](https://tools.ietf.org/html/rfc7469)
- [OWASP MASVS](https://github.com/OWASP/owasp-masvs)
- [OWASP Certificate Pinning Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Pinning_Cheat_Sheet.html)
- [Android Network Security Configuration](https://developer.android.com/training/articles/security-config)
- [iOS App Transport Security](https://developer.apple.com/documentation/security/preventing_insecure_network_connections)
- [Flutter Dio Certificate Pinning](https://pub.dev/packages/dio#certificate-pinning)

## Maintenance

### Quarterly Review

- [ ] Verify pins match production certificates
- [ ] Check expiration dates (30+ days remaining)
- [ ] Review failure logs for anomalies
- [ ] Test rotation procedure in staging
- [ ] Update documentation if needed

### Certificate Rotation Checklist

1. [ ] Generate new key pair
2. [ ] Obtain new certificate
3. [ ] Extract SPKI hash (OpenSSL)
4. [ ] Update `CERT_PIN_BACKUP` in all environments
5. [ ] Deploy application update
6. [ ] Wait 7 days (user update buffer)
7. [ ] Activate new certificate on server
8. [ ] Monitor logs for failures
9. [ ] Update `CERT_PIN_PRIMARY`
10. [ ] Generate next backup pin

### Incident Response

**Pin Validation Failures:**
1. Check SIEM for failure patterns
2. Verify certificate hasn't changed unexpectedly
3. If legitimate rotation: Emergency pin update
4. If MITM attack: Incident response protocol

**Certificate Expiration:**
1. Emergency rotation (< 7 days)
2. Notify users to update app
3. Monitor adoption rate
4. Consider grace period for old pins
