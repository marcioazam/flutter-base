import 'package:flutter_base_2025/core/security/deep_link_validator.dart';
import 'package:flutter_base_2025/core/security/input_sanitizer_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deep_link_validator_provider.g.dart';

/// Provides DeepLinkValidatorConfig for dependency injection.
///
/// Override this provider to customize allowed schemes and hosts:
/// ```dart
/// ProviderScope(
///   overrides: [
///     deepLinkValidatorConfigProvider.overrideWith((ref) =>
///       DeepLinkValidatorConfig(
///         allowedSchemes: ['https', 'myapp'],
///         allowedHosts: ['myapp.com'],
///       ),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
@riverpod
DeepLinkValidatorConfig deepLinkValidatorConfig(
  DeepLinkValidatorConfigRef ref,
) {
  return const DeepLinkValidatorConfig(
    allowedSchemes: ['https', 'http', 'myapp'],
    allowedHosts: ['example.com', 'api.example.com'],
  );
}

/// Provides DeepLinkValidator instance for dependency injection.
///
/// **Usage:**
/// ```dart
/// class DeepLinkHandler extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final validator = ref.watch(deepLinkValidatorProvider);
///
///     if (validator.isValidDeepLink(url)) {
///       final path = validator.extractSafePath(url);
///       // Navigate to path
///     }
///   }
/// }
/// ```
///
/// **Testing:**
/// ```dart
/// testWidgets('validates deep link', (tester) async {
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: [
///         deepLinkValidatorProvider.overrideWith((ref) => MockDeepLinkValidator()),
///       ],
///       child: MyApp(),
///     ),
///   );
/// });
/// ```
@riverpod
DeepLinkValidator deepLinkValidator(DeepLinkValidatorRef ref) {
  final config = ref.watch(deepLinkValidatorConfigProvider);
  final sanitizer = ref.watch(inputSanitizerProvider);

  return DefaultDeepLinkValidator(
    config: config,
    inputSanitizer: sanitizer,
  );
}
