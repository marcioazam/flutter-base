/// Riverpod 3.0 compatibility helpers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension to add valueOrNull to AsyncValue for backwards compatibility.
/// In Riverpod 3.0, use whenOrNull instead.
extension AsyncValueExtension<T> on AsyncValue<T> {
  /// Returns the value if available, null otherwise.
  T? get valueOrNull => whenOrNull(data: (v) => v);
}
