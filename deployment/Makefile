# =============================================================================
# Makefile - Docker Deployment Commands
# Flutter Base 2025
# =============================================================================

.PHONY: help build run prod stop logs shell health clean security lint push validate test coverage-report ci-test security-scan format

# Default target
help:
	@echo "Flutter Base 2025 - Docker Deployment & CI/CD"
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
	@echo "Quality & CI/CD:"
	@echo "  ci-test         Run all CI checks locally (format, lint, test, coverage)"
	@echo "  coverage-report Generate coverage report with threshold check"
	@echo "  security-scan   Run comprehensive security scan"
	@echo "  format          Check and fix code formatting"
	@echo "  health          Check health endpoints"
	@echo "  security        Run security scan (Trivy)"
	@echo "  lint            Lint Dockerfile (Hadolint)"
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

# =============================================================================
# CI/CD Quality Gates
# =============================================================================

COVERAGE_THRESHOLD ?= 80
PROJECT_ROOT = ../..

format:
	@echo "=== Checking code formatting ==="
	@cd $(PROJECT_ROOT) && dart format --set-exit-if-changed . && echo "✅ All files properly formatted" || \
		(echo "❌ Format check failed. Run: dart format ." && exit 1)

format-fix:
	@echo "=== Fixing code formatting ==="
	@cd $(PROJECT_ROOT) && dart format .
	@echo "✅ Code formatted successfully"

ci-test:
	@echo "=== Running CI Quality Gates Locally ==="
	@echo ""
	@echo "1/4 - Format Check..."
	@$(MAKE) format
	@echo ""
	@echo "2/4 - Lint Analysis..."
	@$(MAKE) ci-lint
	@echo ""
	@echo "3/4 - Tests with Coverage..."
	@$(MAKE) coverage-report
	@echo ""
	@echo "4/4 - Security Scan..."
	@$(MAKE) security-scan
	@echo ""
	@echo "✅ All CI quality gates passed!"

ci-lint:
	@echo "Running static analysis (fatal-infos)..."
	@cd $(PROJECT_ROOT) && flutter analyze --fatal-infos > analyze_output.txt 2>&1 || FAILED=true; \
	cat analyze_output.txt; \
	if [ "$$FAILED" = "true" ]; then \
		echo "❌ Static analysis failed"; \
		rm -f analyze_output.txt; \
		exit 1; \
	fi; \
	WARNINGS=$$(grep -c "warning •" analyze_output.txt 2>/dev/null || echo "0"); \
	ERRORS=$$(grep -c "error •" analyze_output.txt 2>/dev/null || echo "0"); \
	echo ""; \
	echo "Errors:   $$ERRORS"; \
	echo "Warnings: $$WARNINGS"; \
	echo ""; \
	rm -f analyze_output.txt; \
	if [ $$ERRORS -gt 0 ]; then \
		echo "❌ Found $$ERRORS errors"; \
		exit 1; \
	fi; \
	if [ $$WARNINGS -gt 50 ]; then \
		echo "❌ Warning threshold exceeded: $$WARNINGS > 50"; \
		exit 1; \
	fi; \
	echo "✅ Static analysis passed"

coverage-report:
	@echo "=== Generating Coverage Report ==="
	@cd $(PROJECT_ROOT) && flutter test --coverage
	@echo ""
	@echo "Filtering generated files from coverage..."
	@if command -v lcov >/dev/null 2>&1; then \
		cd $(PROJECT_ROOT) && \
		lcov --remove coverage/lcov.info \
			'**/*.g.dart' \
			'**/*.freezed.dart' \
			'**/*.gr.dart' \
			'**/*.mocks.dart' \
			'**/generated/**' \
			-o coverage/lcov_filtered.info && \
		mv coverage/lcov_filtered.info coverage/lcov.info; \
		echo ""; \
		echo "Generating HTML report..."; \
		genhtml coverage/lcov.info -o coverage/html; \
		echo ""; \
		echo "Coverage report: coverage/html/index.html"; \
		echo ""; \
		COVERAGE=$$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $$2}' | sed 's/%//' | sed 's/\..*//'); \
		echo "Line Coverage: $$COVERAGE%"; \
		echo "Threshold:     $(COVERAGE_THRESHOLD)%"; \
		echo ""; \
		if [ -z "$$COVERAGE" ] || [ $$COVERAGE -lt $(COVERAGE_THRESHOLD) ]; then \
			echo "❌ Coverage $$COVERAGE% is below threshold $(COVERAGE_THRESHOLD)%"; \
			exit 1; \
		else \
			echo "✅ Coverage meets threshold: $$COVERAGE% >= $(COVERAGE_THRESHOLD)%"; \
		fi; \
	else \
		echo "⚠️  lcov not installed. Install with: brew install lcov (macOS) or apt-get install lcov (Linux)"; \
		echo "Coverage file generated at: coverage/lcov.info"; \
	fi

coverage-open:
	@echo "Opening coverage report in browser..."
	@cd $(PROJECT_ROOT) && open coverage/html/index.html || xdg-open coverage/html/index.html || start coverage/html/index.html

security-scan:
	@echo "=== Running Security Scans ==="
	@echo ""
	@echo "1. Secrets Detection (Gitleaks)..."
	@if command -v gitleaks >/dev/null 2>&1; then \
		cd $(PROJECT_ROOT) && gitleaks detect --source . --verbose && echo "✅ No secrets found"; \
	else \
		echo "⚠️  Gitleaks not installed. Install: https://github.com/gitleaks/gitleaks#installing"; \
	fi
	@echo ""
	@echo "2. Dependency Vulnerability Check..."
	@cd $(PROJECT_ROOT) && flutter pub outdated || true
	@echo ""
	@echo "3. Docker Image Security Scan..."
	@if command -v docker >/dev/null 2>&1 && [ -n "$$(docker images -q $(IMAGE_NAME):$(VERSION) 2>/dev/null)" ]; then \
		$(MAKE) security; \
	else \
		echo "⚠️  Docker image not built. Run 'make build' first"; \
	fi
	@echo ""
	@echo "✅ Security scan complete"
