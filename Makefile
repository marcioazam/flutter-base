.PHONY: help build test clean run analyze format

# Default target
help:
	@echo "Available targets:"
	@echo "  make build         - Run build_runner"
	@echo "  make watch         - Watch for changes and rebuild"
	@echo "  make test          - Run all tests"
	@echo "  make test-coverage - Run tests with coverage"
	@echo "  make analyze       - Run dart analyze"
	@echo "  make format        - Format code"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make run-dev       - Run development flavor"
	@echo "  make run-staging   - Run staging flavor"
	@echo "  make run-prod      - Run production flavor"
	@echo "  make apk-dev       - Build development APK"
	@echo "  make apk-prod      - Build production APK"
	@echo "  make web           - Build web release"
	@echo "  make docker-build  - Build Docker image"
	@echo "  make docker-run    - Run Docker container"

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
