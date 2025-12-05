# Deployment Guide - Flutter Base 2025

## Overview

Configurações de deployment production-ready para a aplicação Flutter Web.

## Estrutura

```
deployment/
├── docker/
│   ├── Dockerfile           # Multi-stage build (security hardened)
│   ├── docker-compose.yml   # Orquestração local + Traefik
│   ├── nginx.conf           # Nginx com security headers
│   ├── .dockerignore        # Exclusões de build
│   └── .env.example         # Template de variáveis
├── scripts/
│   └── build.sh             # Script de build para CI/CD
├── Makefile                 # Comandos úteis
└── README.md
```

## Opções de Deploy

Para Flutter Web frontend-only, recomendamos (em ordem de simplicidade):

| Opção | Custo | Complexidade | Melhor para |
|-------|-------|--------------|-------------|
| **Vercel** | Grátis | Mínima | Deploy rápido, preview PRs |
| **Firebase Hosting** | Grátis | Baixa | Integração Firebase |
| **AWS S3 + CloudFront** | ~$1/mês | Baixa | CDN global, produção |
| **Docker + VPS** | ~$5/mês | Média | Controle total |

## Quick Start

### Desenvolvimento Local (Docker)

```bash
cd deployment

# Copiar variáveis de ambiente
cp docker/.env.example docker/.env

# Build e run
make build
make run

# Verificar
make health
```

Acesse: http://localhost:3000

### Produção (Docker + Traefik)

```bash
# Configurar domínio e email no .env
vim docker/.env

# Iniciar com profile production (inclui HTTPS)
make prod
```

### Deploy Vercel (Recomendado)

```bash
# Instalar Vercel CLI
npm i -g vercel

# Build Flutter Web
flutter build web --release

# Deploy
cd build/web
vercel --prod
```

### Deploy Firebase Hosting

```bash
# Instalar Firebase CLI
npm i -g firebase-tools

# Login e init
firebase login
firebase init hosting

# Build e deploy
flutter build web --release
firebase deploy --only hosting
```

## Comandos Disponíveis

| Comando | Descrição |
|---------|-----------|
| `make build` | Build da imagem Docker |
| `make run` | Inicia ambiente de desenvolvimento |
| `make prod` | Inicia com Traefik (HTTPS) |
| `make stop` | Para todos os containers |
| `make logs` | Visualiza logs |
| `make health` | Verifica endpoints de saúde |
| `make security` | Scan de segurança (Trivy) |
| `make lint` | Lint do Dockerfile (Hadolint) |
| `make clean` | Remove containers e imagens |

## Health Endpoints

| Endpoint | Propósito | Uso |
|----------|-----------|-----|
| `/health` | Status geral | Docker healthcheck |
| `/ready` | Pronto para tráfego | Load balancer |
| `/live` | Aplicação viva | Monitoramento |

## Segurança

### Dockerfile
- Multi-stage build (imagem final ~50MB)
- Usuário non-root (UID 1001)
- Versões de imagem pinadas

### Nginx
- Security headers (OWASP)
- CSP configurado para Flutter Web
- Rate limiting (10 req/s)
- Server version oculta

### Docker Compose
- `no-new-privileges: true`
- `read_only: true` filesystem
- Resource limits (CPU/Memory)

## Variáveis de Ambiente

| Variável | Default | Descrição |
|----------|---------|-----------|
| `BUILD_VERSION` | pubspec.yaml | Versão da aplicação |
| `FRONTEND_PORT` | 3000 | Porta do host |
| `ENVIRONMENT` | development | Ambiente |
| `DOMAIN` | localhost | Domínio (Traefik) |
| `ACME_EMAIL` | - | Email Let's Encrypt |

## CI/CD

O workflow `release.yml` já está configurado para:
1. Build da imagem Docker
2. Push para GHCR
3. Scan de segurança com Trivy

## Troubleshooting

### Container não inicia
```bash
docker compose -f docker/docker-compose.yml logs frontend
```

### Health check falha
```bash
docker exec flutter-frontend curl -f http://localhost:8080/health
```

## Referências

- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Vercel Flutter](https://vercel.com/guides/deploying-flutter-web-with-vercel)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
