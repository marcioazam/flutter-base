# Deployment Guide

## Overview

Flutter Web gera arquivos estáticos (HTML/JS/CSS). Para deploy, use uma das opções abaixo.

## Opções de Deploy (Recomendadas)

### 1. Firebase Hosting (Recomendado)

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login e inicializar
firebase login
firebase init hosting

# Build e deploy
flutter build web --release
firebase deploy --only hosting
```

### 2. Vercel

```bash
# Instalar Vercel CLI
npm install -g vercel

# Build
flutter build web --release

# Deploy
cd build/web
vercel --prod
```

### 3. Netlify

```bash
# Build
flutter build web --release

# Arrastar build/web para Netlify Dashboard
# Ou usar netlify-cli
netlify deploy --prod --dir=build/web
```

### 4. AWS S3 + CloudFront

```bash
# Build
flutter build web --release

# Sync para S3
aws s3 sync build/web s3://your-bucket-name --delete

# Invalidar CloudFront cache
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"
```

### 5. Docker (para ambientes on-premise)

```bash
# Build image
docker build -f deployment/docker/Dockerfile -t flutter-app .

# Run
docker run -p 8080:80 flutter-app
```

## Build por Ambiente

```bash
# Development
flutter build web -t lib/main_development.dart

# Staging
flutter build web -t lib/main_staging.dart

# Production
flutter build web --release -t lib/main_production.dart
```

## CI/CD

O GitHub Actions já está configurado para:
1. Rodar testes
2. Build web
3. Upload artifacts

Para deploy automático, adicione o step de deploy no workflow.
