# ADR-013: Environment Variables Security

## Status
Accepted

## Date
2025-12-05

## Context

Durante code review, foram identificadas vulnerabilidades críticas de segurança relacionadas ao gerenciamento de variáveis de ambiente:

1. **Arquivos `.env.*` não estavam no `.gitignore`** - risco de vazamento de secrets
2. **`.env` estava listado em `assets` no `pubspec.yaml`** - expõe secrets no bundle do app
3. **Falta de documentação de segurança** nos arquivos de configuração

### Riscos Identificados

| Risco | Severidade | CVSS |
|-------|------------|------|
| Vazamento de API keys em repositório | Crítico | 9.1 |
| Secrets expostos no bundle do app | Alto | 7.5 |
| Falta de rotação de credenciais | Médio | 5.0 |

## Decision

### 1. Gitignore Atualizado

Adicionar todos os arquivos de ambiente ao `.gitignore`:

```gitignore
# Environment files - SECURITY CRITICAL
.env
.env.local
.env.development
.env.staging
.env.production
.env*.local
!.env.example
```

### 2. Remoção de .env dos Assets

O arquivo `.env` NÃO deve ser incluído nos assets do Flutter:

```yaml
# INCORRETO - expõe secrets
assets:
  - .env

# CORRETO - carregar via flutter_dotenv do root
# NOTE: .env files are loaded via flutter_dotenv from root
```

### 3. Carregamento Seguro

Usar `flutter_dotenv` para carregar variáveis em runtime:

```dart
// main.dart
await dotenv.load(fileName: '.env.${flavor}');
```

### 4. CI/CD Secrets

Para produção, usar secrets do CI/CD:
- GitHub Actions: `secrets.API_KEY`
- Variáveis de ambiente do runner
- Vault/Secret Manager para produção

## Consequences

### Positivas
- Secrets não vazam para repositório
- Bundle do app não contém credenciais
- Conformidade com OWASP Top 10 (A02:2021)
- Facilita rotação de credenciais

### Negativas
- Desenvolvedores precisam criar `.env` local manualmente
- CI/CD precisa configurar secrets separadamente

### Neutras
- `.env.example` serve como template documentado

## Alternatives Rejected

| Alternativa | Motivo da Rejeição |
|-------------|-------------------|
| Criptografar .env no repo | Complexidade desnecessária, key management |
| Usar apenas variáveis de ambiente | Difícil para desenvolvimento local |
| Hardcode com obfuscação | Falsa sensação de segurança |

## Compliance

- OWASP Top 10 2021: A02 Cryptographic Failures
- CWE-798: Use of Hard-coded Credentials
- CWE-312: Cleartext Storage of Sensitive Information

## References

- [Flutter dotenv](https://pub.dev/packages/flutter_dotenv)
- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [GitHub Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
