import 'package:flutter_base_2025/core/theme/accessibility_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accessibility_service_provider.g.dart';

/// Provides AccessibilityService instance for dependency injection.
///
/// **Usage:**
/// ```dart
/// class ColorPicker extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final a11y = ref.watch(accessibilityServiceProvider);
///
///     final isAccessible = a11y.meetsContrastAA(textColor, backgroundColor);
///     if (!isAccessible) {
///       // Show warning or adjust colors
///     }
///
///     return ColoredBox(color: backgroundColor, child: Text('Sample'));
///   }
/// }
/// ```
///
/// **Testing:**
/// ```dart
/// testWidgets('validates contrast', (tester) async {
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: [
///         accessibilityServiceProvider.overrideWith(
///           (ref) => MockAccessibilityService(),
///         ),
///       ],
///       child: MyApp(),
///     ),
///   );
/// });
/// ```
@riverpod
AccessibilityService accessibilityService(Ref ref) => const DefaultAccessibilityService();
