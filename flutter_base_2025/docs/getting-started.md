# Getting Started

## Prerequisites

- Flutter 3.27+
- Dart 3.6+
- VS Code ou Android Studio

## Setup

### 1. Clone e instale dependências

```bash
git clone <repo-url>
cd flutter_base_2025
flutter pub get
```

### 2. Configure ambiente

```bash
cp .env.example .env.development
# Edite .env.development com suas configurações
```

### 3. Gere código

```bash
make build
# ou
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Execute

```bash
# Development
flutter run -t lib/main_development.dart

# ou use Makefile
make run
```

## Estrutura de Arquivos

```
lib/
├── core/           # Infraestrutura compartilhada
├── features/       # Módulos de feature
├── shared/         # Widgets e providers compartilhados
├── l10n/           # Arquivos de tradução
├── main.dart       # Entry point padrão
├── main_development.dart
├── main_staging.dart
└── main_production.dart
```

## Comandos Úteis

```bash
make help          # Lista todos os comandos
make build         # Gera código (freezed, riverpod)
make test          # Roda testes
make test-coverage # Testes com coverage
make analyze       # Análise estática
make format        # Formata código
make clean         # Limpa build
```

## Criando uma Nova Feature

1. Crie a estrutura:
```
lib/features/nova_feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── providers/
    └── widgets/
```

2. Implemente na ordem:
   - Domain: Entities → Repository Interface → UseCases
   - Data: DTOs → DataSource → Repository Impl
   - Presentation: Providers → Pages → Widgets

## Testes

```bash
# Todos os testes
flutter test

# Testes de propriedade
flutter test test/property/

# Testes unitários
flutter test test/unit/

# Com coverage
flutter test --coverage
```

## Build

```bash
# Web
flutter build web --release -t lib/main_production.dart

# Android
flutter build apk --release -t lib/main_production.dart

# iOS
flutter build ipa --release -t lib/main_production.dart
```
