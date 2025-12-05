# ADR-008: Generic Patterns Enhancement

## Status
Accepted

## Context
O projeto precisava de padrões genéricos mais robustos para reduzir boilerplate e garantir type-safety em operações comuns como paginação, cache e validação.

## Decision

### 1. PaginationNotifier<T>
Implementar um notifier genérico para infinite scroll com Riverpod.

```dart
abstract class PaginationNotifier<T> extends Notifier<PaginationState<T>> {
  Future<Result<PaginatedList<T>>> fetchPage(int page, int pageSize);
  Future<void> loadInitial();
  Future<void> loadMore();
  Future<void> refresh();
  void reset();
}
```

### 2. CacheDataSource<T>
Implementar cache genérico com TTL e eviction automático.

```dart
abstract interface class CacheDataSource<T> {
  Future<T?> get(String key);
  Future<void> set(String key, T value, {Duration? ttl});
  Future<void> invalidate(String key);
  Future<void> invalidateAll();
}
```

Implementações:
- `MemoryCacheDataSource<T>` - Cache em memória simples
- `LruCacheDataSource<T>` - Cache com LRU eviction

### 3. ValidationResult<T>
Implementar validação type-safe com sealed classes.

```dart
sealed class ValidationResult<T> {
  bool get isValid;
  bool get isInvalid;
}

final class Valid<T> extends ValidationResult<T> { ... }
final class Invalid<T> extends ValidationResult<T> { ... }
```

## Consequences

### Positive
- Redução significativa de boilerplate
- Type-safety em tempo de compilação
- Padrões consistentes em todo o projeto
- Facilidade de testes com property-based testing

### Negative
- Curva de aprendizado para novos desenvolvedores
- Overhead de abstração em casos simples

### Neutral
- Requer Dart 3.0+ para sealed classes
- Integração com Riverpod 3.0

## Alternatives Considered

1. **Usar pacotes externos** - Rejeitado por falta de controle e customização
2. **Implementação ad-hoc** - Rejeitado por inconsistência e duplicação
3. **Code generation** - Considerado para futuro, mas complexidade atual não justifica
