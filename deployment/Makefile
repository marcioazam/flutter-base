# =============================================================================
# Makefile - Docker Deployment Commands
# Flutter Base 2025
# =============================================================================

.PHONY: help build run prod stop logs shell health clean security lint push validate test

# Default target
help:
	@echo "Flutter Base 2025 - Docker Deployment"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Build & Run:"
	@echo "  build      Build Docker image"
	@echo "  run        Run containers (development)"
	@echo "  prod       Run containers (production with Traefik)"
	@echo "  push       Build and push to registry"
	@echo ""
	@echo "Management:"
	@echo "  stop       Stop all containers"
	@echo "  logs       View container logs"
	@echo "  shell      Open shell in container"
	@echo "  restart    Restart containers"
	@echo ""
	@echo "Quality:"
	@echo "  health     Check health endpoints"
	@echo "  security   Run security scan (Trivy)"
	@echo "  lint       Lint Dockerfile (Hadolint)"
	@echo ""
	@echo "Cleanup:"
	@echo "  clean      Remove containers and images"
	@echo "  prune      Docker system prune"
	@echo ""

# Variables
VERSION ?= $(shell grep 'version:' ../../pubspec.yaml | head -1 | cut -d' ' -f2 | tr -d ' ')
BUILD_DATE ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
IMAGE_NAME ?= flutter-base-2025
REGISTRY ?= ghcr.io
REGISTRY_OWNER ?= your-org

FULL_IMAGE = $(REGISTRY)/$(REGISTRY_OWNER)/$(IMAGE_NAME)

# =============================================================================
# Build Targets
# =============================================================================

build:
	@echo "Building Docker image v$(VERSION)..."
	docker compose -f docker/docker-compose.yml build \
		--build-arg BUILD_VERSION=$(VERSION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF)
	@echo "Build complete: $(IMAGE_NAME):$(VERSION)"

build-no-cache:
	@echo "Building Docker image (no cache)..."
	docker compose -f docker/docker-compose.yml build --no-cache \
		--build-arg BUILD_VERSION=$(VERSION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF)

push: build
	@echo "Tagging and pushing to $(FULL_IMAGE)..."
	docker tag $(IMAGE_NAME):$(VERSION) $(FULL_IMAGE):$(VERSION)
	docker tag $(IMAGE_NAME):$(VERSION) $(FULL_IMAGE):latest
	docker push $(FULL_IMAGE):$(VERSION)
	docker push $(FULL_IMAGE):latest

# =============================================================================
# Run Targets
# =============================================================================

run:
	@echo "Starting development environment..."
	docker compose -f docker/docker-compose.yml up -d
	@echo ""
	@echo "Application running at http://localhost:3000"
	@echo "Health check: http://localhost:3000/health"

prod:
	@echo "Starting production environment..."
	docker compose -f docker/docker-compose.yml --profile production up -d
	@echo ""
	@echo "Application running at http://localhost"

stop:
	@echo "Stopping containers..."
	docker compose -f docker/docker-compose.yml --profile production down

restart: stop run

logs:
	docker compose -f docker/docker-compose.yml logs -f

logs-tail:
	docker compose -f docker/docker-compose.yml logs -f --tail=100

shell:
	docker exec -it flutter-frontend /bin/sh

# =============================================================================
# Quality Targets
# =============================================================================

health:
	@echo "Checking health endpoints..."
	@echo ""
	@echo "=== /health ==="
	@curl -sf http://localhost:3000/health | python -m json.tool 2>/dev/null || echo "Failed"
	@echo ""
	@echo "=== /ready ==="
	@curl -sf http://localhost:3000/ready | python -m json.tool 2>/dev/null || echo "Failed"
	@echo ""
	@echo "=== /live ==="
	@curl -sf http://localhost:3000/live | python -m json.tool 2>/dev/null || echo "Failed"

security:
	@echo "Running Trivy security scan..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy:latest image --severity HIGH,CRITICAL $(IMAGE_NAME):$(VERSION)

security-full:
	@echo "Running full Trivy security scan..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy:latest image $(IMAGE_NAME):$(VERSION)

lint:
	@echo "Linting Dockerfile with Hadolint..."
	docker run --rm -i hadolint/hadolint < docker/Dockerfile

# =============================================================================
# Cleanup Targets
# =============================================================================

clean:
	@echo "Cleaning up containers and images..."
	docker compose -f docker/docker-compose.yml --profile production down -v --rmi local
	docker image prune -f

prune:
	@echo "Docker system prune..."
	docker system prune -f

# =============================================================================
# Info Targets
# =============================================================================

info:
	@echo "=== Build Info ==="
	@echo "Image:      $(IMAGE_NAME)"
	@echo "Version:    $(VERSION)"
	@echo "VCS Ref:    $(VCS_REF)"
	@echo "Build Date: $(BUILD_DATE)"
	@echo "Registry:   $(FULL_IMAGE)"
	@echo ""
	@echo "=== Docker Images ==="
	@docker images $(IMAGE_NAME) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

status:
	@echo "=== Container Status ==="
	docker compose -f docker/docker-compose.yml ps

# =============================================================================
# Validation Targets
# =============================================================================

validate:
	@echo "=== Pre-flight Validation ==="
	@echo "Checking Docker..."
	@docker --version || (echo "Docker not found" && exit 1)
	@echo "Checking Docker Compose..."
	@docker compose version || (echo "Docker Compose not found" && exit 1)
	@echo "Checking Dockerfile syntax..."
	@docker run --rm -i hadolint/hadolint < docker/Dockerfile || true
	@echo "Checking .env file..."
	@test -f docker/.env || (echo "Warning: docker/.env not found. Copy from .env.example" && exit 0)
	@echo ""
	@echo "Validation complete!"

test:
	@echo "Running Flutter tests before build..."
	cd ../.. && flutter test --reporter compact
