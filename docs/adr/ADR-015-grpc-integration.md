# ADR-015: gRPC Client Integration

## Status
Accepted

## Context
The project documentation referenced gRPC support, but no implementation existed. We needed to add gRPC client infrastructure to enable communication with gRPC-based microservices while maintaining consistency with existing patterns (Result monad, error handling, Riverpod providers).

## Decision
We will implement gRPC client infrastructure using the official `grpc-dart` package with the following components:

1. **GrpcClient**: Centralized channel management
   - Single channel per host/port configuration
   - TLS/SSL support enabled by default in production
   - Automatic cleanup on dispose

2. **GrpcAuthInterceptor**: Authentication handling
   - Reads tokens from existing TokenStorage
   - Attaches Bearer token to gRPC metadata
   - Supports token caching for synchronous interceptor access

3. **GrpcStatusMapper**: Error mapping
   - Converts all gRPC status codes to AppFailure subtypes
   - Maintains consistency with existing error handling patterns
   - Enables exhaustive pattern matching on failures

4. **GrpcConfig**: Configuration management
   - Environment-based configuration (dev/staging/prod)
   - Configurable timeout, retries, and TLS settings

## Consequences

### Positive
- Consistent error handling with REST API layer
- Reuses existing TokenStorage for authentication
- Type-safe gRPC client stubs via protoc code generation
- Proper resource cleanup via Riverpod lifecycle

### Negative
- Requires protoc toolchain for code generation
- gRPC interceptors are synchronous, requiring token pre-caching
- Additional complexity in build process for proto files

### Neutral
- Proto files stored in `lib/core/grpc/protos/`
- Generated stubs follow standard grpc-dart patterns

## Alternatives Considered

1. **Direct channel usage**: Rejected due to lack of centralized management
2. **Custom RPC implementation**: Rejected due to maintenance burden
3. **REST-only architecture**: Rejected as gRPC was a documented requirement

## References
- grpc-dart: https://pub.dev/packages/grpc
- Protocol Buffers: https://protobuf.dev/
