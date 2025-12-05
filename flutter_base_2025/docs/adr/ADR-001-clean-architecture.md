# ADR-001: Clean Architecture

## Status
Accepted

## Context
Precisamos de uma arquitetura que:
- Separe responsabilidades claramente
- Facilite testes
- Permita mudanças no backend sem afetar UI
- Seja escalável para times

## Decision
Adotar Clean Architecture com 3 camadas:

1. **Presentation**: UI, Widgets, Providers (Riverpod)
2. **Domain**: Entities, UseCases, Repository Interfaces
3. **Data**: DTOs, DataSources, Repository Implementations

### Regras de Dependência
- Presentation → Domain
- Data → Domain
- Domain não depende de nada externo

## Consequences

### Positive
- Testabilidade: Domain pode ser testado isoladamente
- Flexibilidade: Trocar backend não afeta Domain
- Clareza: Cada camada tem responsabilidade definida

### Negative
- Mais código boilerplate
- Curva de aprendizado inicial
- Pode ser overkill para features simples

### Neutral
- Requer disciplina para manter separação
- Code generation (freezed) ajuda com boilerplate

## Alternatives Rejected

1. **MVC tradicional**: Menos separação, difícil testar
2. **BLoC puro**: Mais verboso, menos flexível que Riverpod
3. **GetX**: Menos type-safe, padrões questionáveis
