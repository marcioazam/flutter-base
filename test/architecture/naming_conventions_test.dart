import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **Architecture Test: Naming Conventions**
/// Validates file and directory naming follows Flutter 2025 standards.
void main() {
  group('Naming Conventions', () {
    test('All Dart files use snake_case', () {
      final dartFiles = _findAllDartFiles('lib/');

      for (final file in dartFiles) {
        final filename = file.split('/').last;

        // Ignore generated files
        if (filename.endsWith('.g.dart') ||
            filename.endsWith('.freezed.dart') ||
            filename.endsWith('.gr.dart')) {
          continue;
        }

        // File name must be snake_case (lowercase with underscores)
        final isSnakeCase = RegExp(
          r'^[a-z][a-z0-9_]*\.dart$',
        ).hasMatch(filename);

        expect(isSnakeCase, isTrue, reason: 'File $file is not in snake_case');
      }
    });

    test('Directory names use snake_case (no camelCase)', () {
      final directories = _findAllDirectories('lib/');

      for (final dir in directories) {
        final dirName = dir.split('/').last;

        // Ignore root and special directories
        if (dirName.isEmpty || dirName == 'lib') continue;

        // Directory must be snake_case or lowercase
        final hasUpperCase = dirName.contains(RegExp('[A-Z]'));

        expect(
          hasUpperCase,
          isFalse,
          reason: 'Directory $dir contains uppercase letters (use snake_case)',
        );
      }
    });

    test('Feature folders follow data/domain/presentation structure', () {
      final featuresDir = Directory('lib/features');
      if (!featuresDir.existsSync()) return;

      final features = featuresDir.listSync().whereType<Directory>();

      for (final feature in features) {
        final featureName = feature.path.split(Platform.pathSeparator).last;

        // Check if domain layer exists
        final domainDir = Directory('${feature.path}/domain');
        expect(
          domainDir.existsSync(),
          isTrue,
          reason:
              'Feature $featureName missing domain/ layer (Clean Architecture requires all features have domain)',
        );
      }
    });

    test('DTOs use _dto suffix', () {
      final dtoFiles = _findDartFiles('lib/features/*/data/dtos/');

      for (final file in dtoFiles) {
        final filename = file.split('/').last;

        // Ignore generated files
        if (filename.endsWith('.g.dart') ||
            filename.endsWith('.freezed.dart')) {
          continue;
        }

        expect(
          filename.endsWith('_dto.dart'),
          isTrue,
          reason: 'DTO file $file does not end with _dto.dart suffix',
        );
      }
    });

    test('Repositories use _repository suffix', () {
      final repoFiles = _findDartFiles('lib/**/repositories/');

      for (final file in repoFiles) {
        final filename = file.split('/').last;

        expect(
          filename.endsWith('_repository.dart') ||
              filename.endsWith('_repository_impl.dart'),
          isTrue,
          reason: 'Repository file $file does not use _repository suffix',
        );
      }
    });

    test('Use cases use _usecase suffix', () {
      final usecaseFiles = _findDartFiles('lib/**/use_cases/');

      for (final file in usecaseFiles) {
        final filename = file.split('/').last;

        // Ignore .gitkeep
        if (filename == '.gitkeep') continue;

        expect(
          filename.endsWith('_usecase.dart'),
          isTrue,
          reason: 'Use case file $file does not use _usecase suffix',
        );
      }
    });
  });
}

List<String> _findAllDartFiles(String path) {
  final files = <String>[];
  final dir = Directory(path);

  if (!dir.existsSync()) return files;

  dir.listSync(recursive: true).whereType<File>().forEach((file) {
    if (file.path.endsWith('.dart')) {
      files.add(file.path.replaceAll(r'\', '/'));
    }
  });

  return files;
}

List<String> _findAllDirectories(String path) {
  final dirs = <String>[];
  final dir = Directory(path);

  if (!dir.existsSync()) return dirs;

  dir.listSync(recursive: true).whereType<Directory>().forEach((directory) {
    dirs.add(directory.path.replaceAll(r'\', '/'));
  });

  return dirs;
}

List<String> _findDartFiles(String pattern) {
  final files = <String>[];
  final libDir = Directory('lib');

  if (!libDir.existsSync()) return files;

  final regexPattern = pattern
      .replaceAll('**/', '.*/')
      .replaceAll('*/', '[^/]+/')
      .replaceAll('.dart', r'\.dart$');

  final regex = RegExp(regexPattern);

  libDir.listSync(recursive: true).whereType<File>().forEach((file) {
    final relativePath = file.path.replaceAll(r'\', '/').replaceAll('lib/', '');
    if (file.path.endsWith('.dart') && regex.hasMatch(relativePath)) {
      files.add(file.path.replaceAll(r'\', '/'));
    }
  });

  return files;
}
