import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a testable widget wrapped with necessary providers.
Widget createTestableWidget({
  required Widget child,
  List<Override>? overrides,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Creates a ProviderContainer for unit testing providers.
ProviderContainer createContainer({List<Override>? overrides}) {
  final container = ProviderContainer(overrides: overrides ?? []);
  addTearDown(container.dispose);
  return container;
}

/// Pumps widget and settles all animations.
Future<void> pumpAndSettle(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

/// Extension for common test operations.
extension WidgetTesterExtension on WidgetTester {
  /// Enters text into a TextField by key.
  Future<void> enterTextByKey(Key key, String text) async {
    await tap(find.byKey(key));
    await enterText(find.byKey(key), text);
    await pump();
  }

  /// Taps a widget by key.
  Future<void> tapByKey(Key key) async {
    await tap(find.byKey(key));
    await pump();
  }

  /// Taps a widget by text.
  Future<void> tapByText(String text) async {
    await tap(find.text(text));
    await pump();
  }

  /// Scrolls until widget is visible.
  Future<void> scrollUntilVisible(
    Finder finder, {
    double delta = 100,
    int maxScrolls = 50,
  }) async {
    var scrolls = 0;
    while (!finder.evaluate().isNotEmpty && scrolls < maxScrolls) {
      await drag(find.byType(Scrollable).first, Offset(0, -delta));
      await pump();
      scrolls++;
    }
  }
}

/// Test data generators.
abstract final class TestData {
  static DateTime get now => DateTime(2024, 1, 1, 12, 0, 0);

  static String get validEmail => 'test@example.com';
  static String get validPassword => 'password123';
  static String get validName => 'Test User';

  static String get invalidEmail => 'invalid-email';
  static String get shortPassword => '123';
}
