# Build Flavors Setup Guide

## Overview

Este documento descreve como configurar os build flavors para Android e iOS.

## Android Configuration

### 1. Adicionar ao `android/app/build.gradle`:

```groovy
android {
    // ... existing config ...

    flavorDimensions "environment"
    
    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "App Dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "App Staging"
        }
        production {
            dimension "environment"
            resValue "string", "app_name", "App"
        }
    }
}
```

### 2. Comandos de Build:

```bash
# Development
flutter run --flavor development -t lib/main_development.dart
flutter build apk --flavor development -t lib/main_development.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart
flutter build apk --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor production -t lib/main_production.dart
flutter build apk --release --flavor production -t lib/main_production.dart
```

## iOS Configuration

### 1. Criar Schemes no Xcode:

1. Abrir `ios/Runner.xcworkspace` no Xcode
2. Product → Scheme → Manage Schemes
3. Duplicar "Runner" scheme 3 vezes:
   - `development`
   - `staging`
   - `production`

### 2. Criar Configurations:

1. Project Navigator → Runner → Info
2. Configurations → Duplicar Debug e Release para cada flavor:
   - Debug-development, Release-development
   - Debug-staging, Release-staging
   - Debug-production, Release-production

### 3. Configurar Bundle Identifiers:

Em cada configuration, definir:
- Development: `com.example.app.dev`
- Staging: `com.example.app.staging`
- Production: `com.example.app`

### 4. Comandos de Build iOS:

```bash
# Development
flutter run --flavor development -t lib/main_development.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter build ipa --release --flavor production -t lib/main_production.dart
```

## Makefile Targets

O Makefile já inclui targets para cada flavor:

```bash
make apk-dev      # Build APK development
make apk-staging  # Build APK staging
make apk-prod     # Build APK production
make ipa-dev      # Build IPA development
make ipa-prod     # Build IPA production
```
