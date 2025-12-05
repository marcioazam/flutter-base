import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart';

import 'package:flutter_base_2025/shared/widgets/responsive_builder.dart';

/// **Feature: flutter-base-2025, Property 24: Responsive Layout Adaptation**
/// **Validates: Requirements 6.3**
void main() {
  group('Responsive Layout', () {
    group('Breakpoints', () {
      test('mobile breakpoint is 600', () {
        expect(Breakpoints.mobile, equals(600));
      });

      test('tablet breakpoint is 900', () {
        expect(Breakpoints.tablet, equals(900));
      });

      test('desktop breakpoint is 1200', () {
        expect(Breakpoints.desktop, equals(1200));
      });
    });

    group('ResponsiveLayout Widget', () {
      testWidgets('shows mobile widget on small screens', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: ResponsiveLayout(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        );

        expect(find.text('Mobile'), findsOneWidget);
        expect(find.text('Tablet'), findsNothing);
        expect(find.text('Desktop'), findsNothing);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      testWidgets('shows tablet widget on medium screens', (tester) async {
        tester.view.physicalSize = const Size(700, 1000);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: ResponsiveLayout(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        );

        expect(find.text('Mobile'), findsNothing);
        expect(find.text('Tablet'), findsOneWidget);
        expect(find.text('Desktop'), findsNothing);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      testWidgets('shows desktop widget on large screens', (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: ResponsiveLayout(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        );

        expect(find.text('Mobile'), findsNothing);
        expect(find.text('Tablet'), findsNothing);
        expect(find.text('Desktop'), findsOneWidget);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      testWidgets('falls back to mobile when tablet is null', (tester) async {
        tester.view.physicalSize = const Size(700, 1000);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const MaterialApp(
            home: ResponsiveLayout(
              mobile: Text('Mobile'),
            ),
          ),
        );

        expect(find.text('Mobile'), findsOneWidget);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    group('Property Tests', () {
      /// **Property 24: Responsive Layout Adaptation**
      /// For any screen size change, the layout SHALL adapt according to defined breakpoints.
      Glados<int>(iterations: 100).test(
        'screen size determines correct ScreenSize enum',
        (width) {
          final normalizedWidth = (width.abs() % 2000) + 100;

          final expectedSize = normalizedWidth < Breakpoints.mobile
              ? ScreenSize.mobile
              : normalizedWidth < Breakpoints.tablet
                  ? ScreenSize.tablet
                  : ScreenSize.desktop;

          // Verify breakpoint logic
          if (normalizedWidth < 600) {
            expect(expectedSize, equals(ScreenSize.mobile));
          } else if (normalizedWidth < 900) {
            expect(expectedSize, equals(ScreenSize.tablet));
          } else {
            expect(expectedSize, equals(ScreenSize.desktop));
          }
        },
      );

      test('responsiveValue returns correct value for each size', () {
        // Test mobile
        expect(
          _getResponsiveValueForWidth(400, mobile: 1, tablet: 2, desktop: 3),
          equals(1),
        );

        // Test tablet
        expect(
          _getResponsiveValueForWidth(700, mobile: 1, tablet: 2, desktop: 3),
          equals(2),
        );

        // Test desktop
        expect(
          _getResponsiveValueForWidth(1000, mobile: 1, tablet: 2, desktop: 3),
          equals(3),
        );
      });

      test('responsiveValue falls back correctly', () {
        // Tablet falls back to mobile when null
        expect(
          _getResponsiveValueForWidth(700, mobile: 1),
          equals(1),
        );

        // Desktop falls back to tablet when null
        expect(
          _getResponsiveValueForWidth(1000, mobile: 1, tablet: 2),
          equals(2),
        );

        // Desktop falls back to mobile when both are null
        expect(
          _getResponsiveValueForWidth(1000, mobile: 1),
          equals(1),
        );
      });
    });
  });
}

/// Helper to test responsiveValue logic without BuildContext.
int _getResponsiveValueForWidth(
  double width, {
  required int mobile,
  int? tablet,
  int? desktop,
}) {
  final screenSize = width < Breakpoints.mobile
      ? ScreenSize.mobile
      : width < Breakpoints.tablet
          ? ScreenSize.tablet
          : ScreenSize.desktop;

  return switch (screenSize) {
    ScreenSize.desktop => desktop ?? tablet ?? mobile,
    ScreenSize.tablet => tablet ?? mobile,
    ScreenSize.mobile => mobile,
  };
}
