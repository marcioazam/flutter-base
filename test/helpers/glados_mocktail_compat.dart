/// Compatibility layer for using glados and mocktail together.
/// This file provides explicit imports to avoid ambiguous_import errors.
library;

// Re-export glados with hide for conflicting names
export 'package:glados/glados.dart'
    hide test, group, expect, setUp, tearDown, setUpAll, tearDownAll;

// Re-export mocktail with hide for conflicting 'any'
export 'package:mocktail/mocktail.dart' hide any;

// Provide explicit aliases for mocktail's any
import 'package:mocktail/mocktail.dart' as mocktail;

/// Mocktail's any() matcher - use this instead of bare 'any' when using glados
T anyArg<T>() => mocktail.any<T>();

/// Mocktail's any() with named parameter
T anyNamed<T>(String name) => mocktail.any<T>(named: name);

/// Mocktail's captureAny
T captureAnyArg<T>() => mocktail.captureAny<T>();
