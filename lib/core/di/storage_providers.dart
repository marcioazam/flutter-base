/// Storage-related providers.
///
/// Contains providers for:
/// - Hive (Offline cache)
/// - Drift (SQLite database)
/// - TokenStorage (Secure storage for JWT tokens)
/// - SharedPreferences (Persistence)
///
/// **Pattern:**
/// All providers use @riverpod code generation.
library;

// TODO: Move providers from lib/core/cache/providers/
// TODO: Move providers from lib/core/database/
// TODO: Move providers from lib/core/storage/
// Example:
// ```dart
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:flutter_base_2025/core/storage/token_storage.dart';
// import 'package:flutter_base_2025/core/database/database.dart';
//
// part 'storage_providers.g.dart';
//
// @riverpod
// TokenStorage tokenStorage(Ref ref) {
//   return TokenStorageImpl();
// }
//
// @riverpod
// AppDatabase database(Ref ref) {
//   return AppDatabase();
// }
// ```
