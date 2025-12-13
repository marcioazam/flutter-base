import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **Architecture Test: Domain Layer Purity**
/// Validates that domain layer has ZERO Flutter dependencies.
///
/// **Clean Architecture Rule:**
/// Domain layer must be framework-agnostic (pure Dart, no Flutter imports).
void main() {
  group('Clean Architecture Dependency Rules', () {
    test('Domain layer has no Flutter dependencies', () {
      final domainFiles = _findDartFiles('lib/features/*/domain/');

      for (final file in domainFiles) {
        final content = File(file).readAsStringSync();

        // Domain MUST NOT import Flutter
        expect(
          content.contains('package:flutter/'),
          isFalse,
          reason:
              'Domain layer file $file imports Flutter (violates Clean Architecture)',
        );

        // Domain SHOULD NOT import Riverpod (state management is presentation concern)
        expect(
          content.contains('package:flutter_riverpod/') ||
              content.contains('package:riverpod/'),
          isFalse,
          reason:
              'Domain layer file $file imports Riverpod (state management belongs in presentation)',
        );
      }

      // Ensure we actually found domain files
      expect(
        domainFiles.isNotEmpty,
        isTrue,
        reason: 'No domain files found to test',
      );
    });

    test('Presentation layer does not import Data layer directly', () {
      final presentationFiles = _findDartFiles('lib/features/*/presentation/');

      for (final file in presentationFiles) {
        final content = File(file).readAsStringSync();

        // Exception: Providers can import datasources for DI (Riverpod pattern)
        final isProvider =
            file.contains('/providers/') && file.endsWith('_provider.dart');

        if (!isProvider) {
          // Presentation pages/widgets should NOT import data_sources
          expect(
            content.contains('/data/data_sources/'),
            isFalse,
            reason:
                'Presentation layer file $file imports DataSource directly (use Repository interface instead)',
          );
        }

        // Presentation should NOT import dtos (use entities)
        expect(
          content.contains('/data/dtos/'),
          isFalse,
          reason:
              'Presentation layer file $file imports DTOs directly (use Domain entities instead)',
        );
      }
    });

    test('Data layer implements Domain interfaces', () {
      // This test ensures repository implementations exist
      final repositoryImpls = _findDartFiles(
        'lib/features/*/data/repositories/',
      );

      for (final implFile in repositoryImpls) {
        final content = File(implFile).readAsStringSync();

        // Repository impl must import domain repository interface
        expect(
          content.contains('/domain/repositories/'),
          isTrue,
          reason:
              'Repository implementation $implFile does not import domain repository interface',
        );

        // Must have "implements" keyword
        expect(
          content.contains('implements'),
          isTrue,
          reason:
              'Repository implementation $implFile does not implement interface',
        );
      }
    });
  });
}

/// Finds all Dart files matching glob pattern.
List<String> _findDartFiles(String pattern) {
  final files = <String>[];
  final libDir = Directory('lib');

  if (!libDir.existsSync()) return files;

  libDir.listSync(recursive: true).whereType<File>().forEach((file) {
    if (!file.path.endsWith('.dart')) return;

    final normalizedPath = file.path.replaceAll(r'\', '/');

    // Check if path contains the pattern
    if (pattern.contains('*/domain/')) {
      if (normalizedPath.contains('/domain/')) {
        files.add(normalizedPath);
      }
    } else if (pattern.contains('*/presentation/')) {
      if (normalizedPath.contains('/presentation/')) {
        files.add(normalizedPath);
      }
    } else if (pattern.contains('*/repositories/')) {
      if (normalizedPath.contains('/repositories/')) {
        files.add(normalizedPath);
      }
    }
  });

  return files;
}
