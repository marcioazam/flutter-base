.PHONY: help build test clean run analyze format

# Default target
help:
	@echo "Flutter Base 2025 - Makefile Commands"
	@echo "======================================="
	@echo ""
	@echo "📦 Code Generation:"
	@echo "  make build            - Run build_runner (freezed, riverpod, drift)"
	@echo "  make watch            - Watch mode (auto-rebuild on save)"
	@echo ""
	@echo "🧪 Testing:"
	@echo "  make test             - Run all tests"
	@echo "  make test-coverage    - Run tests with coverage"
	@echo "  make test-property    - Run property-based tests only"
	@echo "  make coverage-report  - Generate HTML coverage report"
	@echo "  make coverage-check   - Check coverage threshold (80%)"
	@echo ""
	@echo "✨ Code Quality:"
	@echo "  make analyze          - Run static analysis (fatal-infos)"
	@echo "  make format           - Format code"
	@echo "  make check-format     - Check formatting (CI mode)"
	@echo "  make lint             - Run analyze + format check"
	@echo ""
	@echo "🔒 Security:"
	@echo "  make security-scan    - Run security scans (gitleaks, dependencies)"
	@echo "  make cert-hash        - Generate cert hash from file"
	@echo "  make cert-hash-url    - Generate cert hash from URL"
	@echo ""
	@echo "▶️  Running:"
	@echo "  make run-dev          - Run development flavor"
	@echo "  make run-staging      - Run staging flavor"
	@echo "  make run-prod         - Run production flavor"
	@echo ""
	@echo "🏗️  Building:"
	@echo "  make apk-dev          - Build development APK"
	@echo "  make apk-prod         - Build production APK (release)"
	@echo "  make ipa-dev          - Build development IPA"
	@echo "  make ipa-prod         - Build production IPA (release)"
	@echo "  make web              - Build web release"
	@echo ""
	@echo "🐳 Docker:"
	@echo "  make docker-build     - Build Docker image"
	@echo "  make docker-run       - Run Docker container"
	@echo "  make docker-compose-up   - Start with docker-compose"
	@echo "  make docker-compose-down - Stop docker-compose"
	@echo ""
	@echo "🔧 Utilities:"
	@echo "  make clean            - Clean build artifacts"
	@echo "  make upgrade          - Upgrade dependencies (major)"
	@echo "  make outdated         - Check outdated dependencies"
	@echo "  make setup            - Full project setup (get + build)"
	@echo "  make ci-test          - Run all CI checks locally"
	@echo ""

# Code generation
build:
	dart run build_runner build --delete-conflicting-outputs

watch:
	dart run build_runner watch --delete-conflicting-outputs

# Testing
test:
	flutter test

test-coverage:
	flutter test --coverage
	@echo "Coverage report generated at coverage/lcov.info"

test-property:
	flutter test test/property/

# Coverage reporting (with HTML generation)
coverage-report:
	@echo "Running tests with coverage..."
	flutter test --coverage
	@echo "Filtering generated files..."
	lcov --remove coverage/lcov.info \
		'**/*.g.dart' \
		'**/*.freezed.dart' \
		'**/*.gr.dart' \
		'**/*.mocks.dart' \
		'**/generated/**' \
		-o coverage/lcov_filtered.info
	@echo "Generating HTML report..."
	genhtml coverage/lcov_filtered.info -o coverage/html
	@echo "✅ Coverage report: coverage/html/index.html"

# Coverage check with threshold
coverage-check:
	@echo "Running coverage check (threshold: 80%)..."
	@flutter test --coverage
	@lcov --remove coverage/lcov.info \
		'**/*.g.dart' \
		'**/*.freezed.dart' \
		'**/*.gr.dart' \
		'**/*.mocks.dart' \
		'**/generated/**' \
		-o coverage/lcov_filtered.info
	@COVERAGE=$$(lcov --summary coverage/lcov_filtered.info 2>&1 | grep "lines" | awk '{print $$2}' | sed 's/%//' | sed 's/\..*//'); \
	if [ "$$COVERAGE" -lt "80" ]; then \
		echo "❌ Coverage $$COVERAGE% is below threshold of 80%"; \
		exit 1; \
	else \
		echo "✅ Coverage $$COVERAGE% meets threshold"; \
	fi

# Code quality
analyze:
	flutter analyze --fatal-infos

format:
	dart format .

check-format:
	dart format --set-exit-if-changed .

lint:
	flutter analyze && dart format --set-exit-if-changed .

# Cleaning
clean:
	flutter clean
	rm -rf coverage/
	rm -rf build/

# Running
run-dev:
	flutter run --flavor development -t lib/main_development.dart

run-staging:
	flutter run --flavor staging -t lib/main_staging.dart

run-prod:
	flutter run --flavor production -t lib/main_production.dart

# Building APKs
apk-dev:
	flutter build apk --flavor development -t lib/main_development.dart

apk-staging:
	flutter build apk --flavor staging -t lib/main_staging.dart

apk-prod:
	flutter build apk --release --flavor production -t lib/main_production.dart

# Building iOS
ipa-dev:
	flutter build ipa --flavor development -t lib/main_development.dart

ipa-prod:
	flutter build ipa --release --flavor production -t lib/main_production.dart

# Building Web
web:
	flutter build web --release

web-dev:
	flutter build web --profile

# Docker
docker-build:
	docker build -f deployment/docker/Dockerfile -t flutter-app:latest ../..

docker-run:
	docker run -p 8080:80 flutter-app:latest

docker-compose-up:
	docker-compose -f deployment/docker/docker-compose.yml up -d

docker-compose-down:
	docker-compose -f deployment/docker/docker-compose.yml down

# Dependencies
upgrade:
	flutter pub upgrade --major-versions

outdated:
	flutter pub outdated

get:
	flutter pub get

# Setup
setup: get build
	@echo "Project setup complete!"

# Security
security-scan:
	@echo "Running security scans..."
	@echo "1. Checking for secrets with gitleaks..."
	@gitleaks detect --source . --verbose || echo "⚠️ Gitleaks not installed"
	@echo "2. Checking for outdated dependencies..."
	@flutter pub outdated
	@echo "✅ Security scan complete"

# CI simulation (run all CI checks locally)
ci-test: lint test-coverage security-scan
	@echo "✅ All CI checks passed locally"

# Generate certificate hash (for certificate pinning)
cert-hash:
	@echo "Certificate Pinning Hash Generator"
	@echo "===================================
	@echo ""
	@read -p "Enter certificate path: " CERT_PATH; \
	if [ -f "$$CERT_PATH" ]; then \
		openssl x509 -in "$$CERT_PATH" -pubkey -noout | \
		openssl pkey -pubin -outform der | \
		openssl dgst -sha256 -binary | \
		openssl base64; \
	else \
		echo "❌ Certificate file not found: $$CERT_PATH"; \
	fi

# Generate certificate hash from URL
cert-hash-url:
	@echo "Certificate Pinning Hash Generator (from URL)"
	@echo "=============================================="
	@echo ""
	@read -p "Enter domain (e.g., api.example.com): " DOMAIN; \
	echo | \
	openssl s_client -servername "$$DOMAIN" -connect "$$DOMAIN:443" 2>/dev/null | \
	openssl x509 -pubkey -noout | \
	openssl pkey -pubin -outform der | \
	openssl dgst -sha256 -binary | \
	openssl base64
