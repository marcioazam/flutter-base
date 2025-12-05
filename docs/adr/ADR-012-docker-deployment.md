# ADR-012: Docker Deployment State of Art

## Status

Accepted

## Context

O projeto necessita de uma configuração de deployment Docker que:
- Seja segura para produção (OWASP, CWE compliance)
- Suporte Kubernetes e Docker Compose
- Tenha performance otimizada para Flutter Web
- Forneça health checks para orquestração
- Siga as melhores práticas de 2025

## Decision

Implementar deployment Docker com as seguintes características:

### Dockerfile - Multi-stage Build

1. **Stage 1: Builder**
   - Base: `ghcr.io/cirruslabs/flutter:3.27.0` (versão pinada)
   - Build otimizado com CanvasKit renderer
   - Tree-shaking habilitado

2. **Stage 2: Production**
   - Base: `nginx:1.27-alpine` (versão pinada)
   - Usuário non-root (UID 1001)
   - OCI labels para rastreabilidade
   - Health check configurado

### Nginx Configuration

**Security Headers (OWASP Compliance):**
- `X-Frame-Options: DENY`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Content-Security-Policy` (adaptado para Flutter Web)
- `Permissions-Policy` (desabilita APIs sensíveis)
- `Cross-Origin-*-Policy` headers

**Performance:**
- Gzip compression (level 6)
- Cache imutável para assets hasheados (1 ano)
- No-cache para HTML/JSON (atualizações SPA)
- Rate limiting (10 req/s geral, 30 req/s API)

**Health Endpoints:**
- `/health` - Status básico (Docker healthcheck)
- `/ready` - Kubernetes readinessProbe
- `/live` - Kubernetes livenessProbe

### Docker Compose

**Security:**
- `security_opt: no-new-privileges`
- `read_only: true` filesystem
- Resource limits (CPU/Memory)
- Network isolation

**Logging:**
- JSON driver com rotação
- Max 10MB por arquivo, 3 arquivos

**Profiles:**
- Default: apenas frontend
- Production: inclui Traefik reverse proxy com Let's Encrypt

### Deployment Options

Para Flutter Web frontend-only, Kubernetes é desnecessário. Opções recomendadas:
- **Vercel/Netlify** - Deploy simples, preview PRs automático
- **Firebase Hosting** - Integração com Firebase
- **AWS S3 + CloudFront** - CDN global, baixo custo
- **Docker + VPS** - Controle total (configuração incluída)

## Consequences

### Positive

- Imagem final ~50MB (minimal attack surface)
- Execução non-root (CVE mitigation)
- Headers de segurança A+ no securityheaders.com
- Compatível com Kubernetes (probes configurados)
- Cache otimizado para performance
- Suporte a HTTPS automático (Traefik/cert-manager)

### Negative

- CSP requer `unsafe-eval` para Flutter CanvasKit
- Complexidade adicional de configuração
- Necessidade de tmpfs para nginx cache

### Neutral

- Porta 8080 (non-privileged) ao invés de 80
- Traefik opcional para TLS termination

## Alternatives Considered

1. **Distroless** - Rejeitado por falta de shell para debugging
2. **Caddy** - Rejeitado por menor adoção em produção
3. **nginx:alpine sem hardening** - Rejeitado por vulnerabilidades

## Security Checklist

- [x] Non-root user execution
- [x] Pinned base image versions
- [x] Security headers (OWASP)
- [x] Rate limiting
- [x] Read-only filesystem
- [x] No new privileges
- [x] Resource limits
- [x] Hidden server version
- [x] Blocked sensitive files

## References

- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [OWASP Secure Headers](https://owasp.org/www-project-secure-headers/)
- [Nginx Security Hardening](https://nginx.org/en/docs/http/ngx_http_core_module.html)
- [Flutter Web CSP Requirements](https://docs.flutter.dev/platform-integration/web/web-content-security-policy)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/overview/)
