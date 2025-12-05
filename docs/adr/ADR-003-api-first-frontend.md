# ADR-003: API-First Frontend

## Status
Accepted

## Context
O projeto é um frontend Flutter que consome uma API Python.
Precisamos definir claramente as responsabilidades.

## Decision
Flutter será um **frontend puro**:

### Flutter (Frontend) é responsável por:
- UI/UX e navegação
- State management (Riverpod)
- Consumo de API REST (Dio)
- Cache local simples (SharedPreferences)
- Token storage seguro
- Offline indicator (sem offline-first)

### API Python (Backend) é responsável por:
- Autenticação (JWT tokens)
- Autorização e permissões
- Lógica de negócio
- Persistência (PostgreSQL)
- Validações de dados
- Feature flags

### O que NÃO teremos no Flutter:
- Database local (drift/isar)
- Lógica de negócio complexa
- Firebase direto (via API)
- Sync offline-first

## Consequences

### Positive
- Frontend mais leve e simples
- Lógica centralizada no backend
- Mais fácil de manter
- Backend pode ser usado por outros clients

### Negative
- Dependência de conectividade
- Latência em operações
- Sem funcionalidade offline

### Neutral
- Cache simples para UX
- Tokens gerenciados localmente

## Alternatives Rejected

1. **Offline-first com Drift**: Complexidade desnecessária
2. **Firebase direto**: Vendor lock-in, duplicação de lógica
3. **GraphQL**: API já é REST, não justifica mudança
