import 'package:flutter_base_2025/core/security/input_sanitizer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'input_sanitizer_provider.g.dart';

/// Provides InputSanitizer instance for dependency injection.
///
/// **Usage:**
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final sanitizer = ref.watch(inputSanitizerProvider);
///     final safe = sanitizer.sanitizeHtml(userInput);
///     return Text(safe);
///   }
/// }
/// ```
///
/// **Testing:**
/// ```dart
/// testWidgets('sanitizes input', (tester) async {
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: [
///         inputSanitizerProvider.overrideWith((ref) => MockInputSanitizer()),
///       ],
///       child: MyApp(),
///     ),
///   );
/// });
/// ```
@riverpod
InputSanitizer inputSanitizer(InputSanitizerRef ref) {
  return const DefaultInputSanitizer();
}
