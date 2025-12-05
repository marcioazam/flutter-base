import 'package:flutter/widgets.dart';
import 'package:flutter_base_2025/shared/providers/locale_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// RTL languages list.
const _rtlLanguages = ['ar', 'he', 'fa', 'ur', 'ps', 'sd', 'yi'];

/// Provider for text direction based on current locale.
final textDirectionProvider = Provider<TextDirection>((ref) {
  final locale = ref.watch(localeProvider);
  return _rtlLanguages.contains(locale.languageCode)
      ? TextDirection.rtl
      : TextDirection.ltr;
});

/// Provider for checking if current locale is RTL.
final isRtlProvider = Provider<bool>((ref) {
  final direction = ref.watch(textDirectionProvider);
  return direction == TextDirection.rtl;
});

/// Extension for locale RTL check.
extension LocaleRtlExtension on Locale {
  /// Returns true if this locale uses RTL text direction.
  bool get isRtl => _rtlLanguages.contains(languageCode);

  /// Returns the text direction for this locale.
  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;
}

/// Widget that provides directionality based on locale.
class LocaleDirectionality extends ConsumerWidget {
  const LocaleDirectionality({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final direction = ref.watch(textDirectionProvider);
    return Directionality(
      textDirection: direction,
      child: child,
    );
  }
}

/// Mixin for widgets that need RTL-aware layout.
mixin RtlAwareMixin {
  /// Returns start alignment based on text direction.
  AlignmentGeometry startAlignment(TextDirection direction) =>
      direction == TextDirection.rtl
          ? Alignment.centerRight
          : Alignment.centerLeft;

  /// Returns end alignment based on text direction.
  AlignmentGeometry endAlignment(TextDirection direction) =>
      direction == TextDirection.rtl
          ? Alignment.centerLeft
          : Alignment.centerRight;

  /// Returns start padding based on text direction.
  EdgeInsetsGeometry startPadding(TextDirection direction, double value) =>
      direction == TextDirection.rtl
          ? EdgeInsets.only(right: value)
          : EdgeInsets.only(left: value);

  /// Returns end padding based on text direction.
  EdgeInsetsGeometry endPadding(TextDirection direction, double value) =>
      direction == TextDirection.rtl
          ? EdgeInsets.only(left: value)
          : EdgeInsets.only(right: value);
}
