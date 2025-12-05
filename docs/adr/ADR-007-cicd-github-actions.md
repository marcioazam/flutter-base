# ADR-007: CI/CD com GitHub Actions State of Art

## Status

Accepted

## Context

O projeto necessita de uma infraestrutura de CI/CD robusta que:
- Automatize validações de código em cada PR
- Execute testes com cobertura mínima de 80%
- Realize análise de segurança (SAST)
- Automatize releases multi-plataforma
- Forneça feedback rápido aos desenvolvedores
- Gerencie dependências automaticamente
- Mantenha a qualidade do código através de code review automatizado

## Decision

Implementar CI/CD completo usando GitHub Actions com as seguintes características:

### Workflows Implementados

1. **CI Pipeline** (`ci.yml`)
   - Análise estática com `flutter analyze`
   - Verificação de formatação com `dart format`
   - Testes unitários com cobertura
   - Builds de verificação (Web, Android)

2. **Matrix Testing** (`ci-matrix.yml`)
   - Flutter stable e beta
   - Ubuntu, macOS, Windows
   - fail-fast: false para resultados parciais

3. **Security** (`security.yml`)
   - CodeQL para análise semântica
   - Gitleaks para detecção de secrets
   - Trivy para vulnerabilidades em dependências
   - SARIF reports para GitHub Security tab

4. **Code Review Bot** (`code-review.yml`)
   - Reviewdog para inline comments
   - PR size check (>500 lines warning)
   - Test coverage check para novos arquivos

5. **Release** (`release.yml`)
   - Builds multi-plataforma (Web, Android APK/AAB)
   - Signing com keystore de secrets
   - Upload automático para GitHub Releases
   - Docker image para GHCR

6. **Automações**
   - PR Labeler baseado em paths
   - Release Drafter para changelog
   - Stale bot para issues/PRs inativos
   - Dependabot para atualizações

### Estrutura de Arquivos

```
.github/
├── workflows/           # 10 workflows
├── actions/             # Composite actions reutilizáveis
├── ISSUE_TEMPLATE/      # Templates de issues
├── PULL_REQUEST_TEMPLATE.md
├── CODEOWNERS
├── dependabot.yml
├── labeler.yml
└── release-drafter.yml
```

### Caching Strategy

- Flutter SDK com hash do pubspec.lock
- Pub cache (~/.pub-cache)
- Gradle cache (~/.gradle)
- CocoaPods cache (iOS)

## Consequences

### Positive

- Feedback rápido em PRs (< 5 min para análise)
- Detecção precoce de vulnerabilidades
- Releases consistentes e reproduzíveis
- Redução de trabalho manual de review
- Histórico de releases bem documentado
- Dependências sempre atualizadas

### Negative

- Custo de GitHub Actions minutes
- Complexidade inicial de configuração
- Necessidade de manter secrets atualizados
- Curva de aprendizado para novos contribuidores

### Neutral

- Dependência do ecossistema GitHub
- Necessidade de monitorar workflows

## Alternatives Considered

1. **GitLab CI** - Rejeitado por já usar GitHub
2. **CircleCI** - Rejeitado por custo adicional
3. **Jenkins** - Rejeitado por overhead de manutenção
4. **Codemagic** - Considerado para builds iOS futuros

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
