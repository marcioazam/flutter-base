# ADR-009: Feature Flags and A/B Testing

## Status
Accepted

## Context
O projeto precisava de um sistema de feature flags com segmentação de usuários e suporte a A/B testing para experimentação controlada.

## Decision

### 1. Feature Flags com Segmentação
Implementar feature flags com suporte a targeting rules.

```dart
class UserSegment {
  final String? userId;
  final String? deviceType;
  final String? appVersion;
  final String? platform;
  final Map<String, dynamic> customAttributes;
}

class TargetingRule {
  final String attribute;
  final TargetingOperator operator;
  final dynamic value;
  
  bool evaluate(Map<String, dynamic> context);
}
```

Operadores suportados:
- equals, notEquals
- contains, startsWith, endsWith
- greaterThan, lessThan
- inList, notInList
- versionGreaterThan, versionLessThan

### 2. ExperimentService para A/B Testing
Implementar serviço de experimentos com variant assignment persistente.

```dart
abstract interface class ExperimentService {
  void registerExperiment<T>(Experiment<T> experiment);
  Variant<T>? getVariant<T>(String experimentId);
  void forceVariant(String experimentId, String variantName);
  Future<void> trackExperimentEvent(String experimentId, String eventName);
}
```

Características:
- Assignment persistente via SharedPreferences
- Weighted random assignment
- Integração com analytics
- Force variant para QA

## Consequences

### Positive
- Rollout gradual de features
- Experimentação controlada
- Métricas por variante
- Segmentação flexível

### Negative
- Complexidade adicional
- Necessidade de cleanup de experimentos antigos
- Possível inconsistência se não gerenciado

### Neutral
- Requer backend para flags remotos em produção
- Local implementation suficiente para desenvolvimento

## Alternatives Considered

1. **Firebase Remote Config** - Considerado, mas abstração permite múltiplos backends
2. **LaunchDarkly** - Muito caro para projetos menores
3. **Sem feature flags** - Rejeitado por falta de controle de rollout
