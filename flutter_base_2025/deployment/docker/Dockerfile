# Flutter Web Frontend - Multi-stage build
# Stage 1: Build
FROM ghcr.io/cirruslabs/flutter:3.27.0 AS builder

WORKDIR /app

# Copy pubspec files first for caching
COPY pubspec.* ./
RUN flutter pub get

# Copy source code
COPY . .

# Build web release
RUN flutter build web --release

# Stage 2: Runtime with nginx
FROM nginx:alpine

# Copy nginx config
COPY deployment/docker/nginx.conf /etc/nginx/nginx.conf

# Copy built web app
COPY --from=builder /app/build/web /usr/share/nginx/html

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
