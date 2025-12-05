/// Glados helpers to avoid import conflicts with flutter_test.
/// 
/// Usage: Import this file instead of glados directly in test files.
/// ```dart
/// import 'package:flutter_test/flutter_test.dart';
/// import '../helpers/glados_helpers.dart';
/// ```
library;

// Re-export ExploreConfig for convenience
import 'package:glados/glados.dart' show ExploreConfig;

// Re-export glados hiding conflicting symbols
export 'package:glados/glados.dart' hide expect, group, test;

/// Default explore config with 100 iterations for property tests.
final defaultExplore = ExploreConfig();

/// Explore config with 50 iterations for faster tests.
final fastExplore = ExploreConfig(numRuns: 50);

/// Explore config with 200 iterations for thorough tests.
final thoroughExplore = ExploreConfig(numRuns: 200);
