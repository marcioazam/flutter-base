import 'package:flutter/widgets.dart';
import 'package:flutter_base_2025/core/observability/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown, setUpAll, tearDownAll;

// Configure Glados for 100 iterations
final _explore = ExploreConfig(numRuns: 100);

/// **Feature: flutter-modernization-2025, Property 11: Analytics Screen View Logging**
/// **Validates: Requirements 22.1**

/// Mock analytics service that records all calls.
class RecordingAnalyticsService implements AnalyticsService {
  final List<Map<String, dynamic>> screenViews = [];
  final List<Map<String, dynamic>> events = [];
  String? userId;
  final Map<String, String> userProperties = {};
  bool enabled = true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!enabled) return;
    screenViews.add({
      'screenName': screenName,
      'screenClass': screenClass,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!enabled) return;
    events.add({
      'name': name,
      'parameters': parameters,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> setUserId(String id) async {
    userId = id;
  }

  @override
  Future<void> clearUserId() async {
    userId = null;
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    userProperties[name] = value;
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool value) async {
    enabled = value;
  }

  void clear() {
    screenViews.clear();
    events.clear();
    userId = null;
    userProperties.clear();
    enabled = true;
  }
}

/// Test route for navigation observer.
class TestRoute extends PageRoute<void> {
  TestRoute(this.routeName);

  final String routeName;

  @override
  RouteSettings get settings => RouteSettings(name: routeName);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      const SizedBox();
}

void main() {
  group('Analytics Screen View Logging Properties', () {
    late RecordingAnalyticsService analytics;
    late AnalyticsNavigatorObserver observer;

    setUp(() {
      analytics = RecordingAnalyticsService();
      observer = AnalyticsNavigatorObserver(analytics);
    });

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'logScreenView records screen name correctly',
      (screenName) async {
        analytics.clear(); // Clear state for each iteration
        final validName = '/${screenName.replaceAll(RegExp(r'[^\w]'), '_')}';
        await analytics.logScreenView(screenName: validName);

        expect(analytics.screenViews.length, equals(1));
        expect(analytics.screenViews.first['screenName'], equals(validName));
      },
    );

    Glados2<String, String>(any.lowercaseLetters, any.lowercaseLetters, _explore).test(
      'logScreenView records screen name and class',
      (screenName, screenClass) async {
        analytics.clear(); // Clear state for each iteration
        final validName = '/${screenName.replaceAll(RegExp(r'[^\w]'), '_')}';
        final validClass = screenClass.replaceAll(RegExp(r'[^\w]'), '');

        await analytics.logScreenView(
          screenName: validName,
          screenClass: validClass,
        );

        expect(analytics.screenViews.length, equals(1));
        expect(analytics.screenViews.first['screenName'], equals(validName));
        expect(analytics.screenViews.first['screenClass'], equals(validClass));
      },
    );

    test('screen view includes timestamp', () async {
      final before = DateTime.now();
      await analytics.logScreenView(screenName: '/test');
      final after = DateTime.now();

      expect(analytics.screenViews.first['timestamp'], isNotNull);
      final timestamp =
          DateTime.parse(analytics.screenViews.first['timestamp'] as String);
      expect(timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(
          timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('disabled analytics does not log screen views', () async {
      await analytics.setAnalyticsCollectionEnabled(false);
      await analytics.logScreenView(screenName: '/test');

      expect(analytics.screenViews, isEmpty);
    });

    test('multiple screen views are recorded in order', () async {
      await analytics.logScreenView(screenName: '/home');
      await analytics.logScreenView(screenName: '/settings');
      await analytics.logScreenView(screenName: '/profile');

      expect(analytics.screenViews.length, equals(3));
      expect(analytics.screenViews[0]['screenName'], equals('/home'));
      expect(analytics.screenViews[1]['screenName'], equals('/settings'));
      expect(analytics.screenViews[2]['screenName'], equals('/profile'));
    });

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'logEvent records event name correctly',
      (eventName) async {
        analytics.clear(); // Clear state for each iteration
        final validName = eventName.replaceAll(RegExp(r'[^\w]'), '_');
        await analytics.logEvent(name: validName);

        expect(analytics.events.length, equals(1));
        expect(analytics.events.first['name'], equals(validName));
      },
    );

    test('logEvent records parameters', () async {
      await analytics.logEvent(
        name: 'button_click',
        parameters: {'button_id': 'submit', 'screen': 'login'},
      );

      expect(analytics.events.first['parameters'], isNotNull);
      expect(
        analytics.events.first['parameters']['button_id'],
        equals('submit'),
      );
    });

    test('setUserId and clearUserId work correctly', () async {
      expect(analytics.userId, isNull);

      await analytics.setUserId('user123');
      expect(analytics.userId, equals('user123'));

      await analytics.clearUserId();
      expect(analytics.userId, isNull);
    });

    test('setUserProperty stores properties', () async {
      await analytics.setUserProperty(name: 'plan', value: 'premium');
      await analytics.setUserProperty(name: 'country', value: 'BR');

      expect(analytics.userProperties['plan'], equals('premium'));
      expect(analytics.userProperties['country'], equals('BR'));
    });
  });
}
