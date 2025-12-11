import 'package:flutter_base_2025/core/security/secure_random.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_random_provider.g.dart';

/// Provides SecureRandom instance for dependency injection.
///
/// **Usage:**
/// ```dart
/// class TokenGenerator extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final secureRandom = ref.watch(secureRandomProvider);
///     final token = secureRandom.generateToken();
///     return Text('Token: $token');
///   }
/// }
/// ```
///
/// **Testing:**
/// ```dart
/// testWidgets('generates predictable tokens in tests', (tester) async {
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: [
///         secureRandomProvider.overrideWith((ref) => MockSecureRandom()),
///       ],
///       child: MyApp(),
///     ),
///   );
/// });
/// ```
///
/// **Security Note:**
/// This provider creates a new instance for each consumer. For most use cases,
/// this is acceptable. If you need a singleton instance, use `.keepAlive()`.
@riverpod
SecureRandom secureRandom(SecureRandomRef ref) {
  return DefaultSecureRandom();
}
