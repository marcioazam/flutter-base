# ADR-002: Riverpod 3.0 Migration

## Status
Accepted

## Context
Riverpod 3.0 introduz:
- AsyncNotifier para operações assíncronas
- Mutations para side-effects com UI feedback
- Code generation com @riverpod
- Melhor preservação de estado durante loading

## Decision
Migrar para Riverpod 3.0 usando:

1. **AsyncNotifier** em vez de StateNotifier para async
2. **@riverpod annotation** para code generation
3. **ref.onDispose()** para cleanup de recursos
4. **select()** para otimizar rebuilds

### Padrões Adotados

```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  Future<Data> build() async {
    ref.onDispose(() => cleanup());
    return fetchData();
  }
}
```

## Consequences

### Positive
- Menos boilerplate com code generation
- Melhor handling de estados async
- Type-safety melhorado
- Cleanup automático de recursos

### Negative
- Requer build_runner
- Breaking changes da versão anterior
- Documentação ainda em evolução

### Neutral
- Curva de aprendizado para novos padrões

## Alternatives Rejected

1. **Manter StateNotifier**: Deprecated, menos features
2. **BLoC**: Mais verboso, menos integrado
3. **Provider puro**: Menos features para async
