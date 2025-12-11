# =============================================================================
# Flutter Web Frontend - Production Multi-stage Build
# State of Art 2025 - Security Hardened
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build Flutter Web Application
# -----------------------------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:3.27.0 AS builder

# Build arguments for versioning
ARG BUILD_VERSION=0.0.0
ARG BUILD_NUMBER=0
ARG BUILD_DATE
ARG VCS_REF

WORKDIR /app

# Copy dependency files first for layer caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies (cached layer)
RUN flutter pub get

# Copy source code
COPY . .

# Build optimized web release with tree-shaking
# Note: --pwa-strategy was deprecated in Flutter 3.16+, PWA is configured via web/manifest.json
RUN flutter build web \
    --release \
    --dart-define=BUILD_VERSION=${BUILD_VERSION} \
    --dart-define=BUILD_NUMBER=${BUILD_NUMBER} \
    --web-renderer=canvaskit

# -----------------------------------------------------------------------------
# Stage 2: Production Runtime with Nginx (Security Hardened)
# -----------------------------------------------------------------------------
# Using nginx:stable-alpine for latest security patches
# Check for updates: https://hub.docker.com/_/nginx
FROM nginx:1.27.3-alpine AS production

# Re-declare build arguments for this stage
ARG BUILD_VERSION=0.0.0
ARG BUILD_DATE=unknown
ARG VCS_REF=unknown

# OCI Labels for container metadata
LABEL org.opencontainers.image.title="Flutter Base 2025" \
      org.opencontainers.image.description="Flutter Web Application - Production Build" \
      org.opencontainers.image.version="${BUILD_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.vendor="Flutter Base 2025" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/example/flutter-base-2025"

# Install security updates and required packages
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        curl \
        tzdata && \
    rm -rf /var/cache/apk/*

# Create non-root user for security
RUN addgroup -g 1001 -S nginx-app && \
    adduser -u 1001 -S nginx-app -G nginx-app

# Copy nginx configuration
COPY deployment/docker/nginx.conf /etc/nginx/nginx.conf

# Copy built web application
COPY --from=builder /app/build/web /usr/share/nginx/html

# Create required directories and set permissions
RUN mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp && \
    chown -R nginx-app:nginx-app /usr/share/nginx/html && \
    chown -R nginx-app:nginx-app /var/cache/nginx && \
    chown -R nginx-app:nginx-app /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /etc/nginx

# Remove default nginx configs
RUN rm -rf /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/*.conf

# Security: Remove unnecessary files
RUN rm -rf /usr/share/nginx/html/*.map 2>/dev/null || true

# Switch to non-root user
USER nginx-app

# Health check with proper timeout
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose non-privileged port
EXPOSE 8080

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
