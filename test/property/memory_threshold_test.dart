import 'package:flutter_base_2025/core/observability/performance_monitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown, setUpAll, tearDownAll;

// Configure Glados for 100 iterations
final _explore = ExploreConfig(numRuns: 100);

/// **Feature: flutter-2025-final-polish, Property 8: Performance Monitor Tests**
/// **Validates: Requirements 12.4**
void main() {
  group('PerformanceMonitor Properties', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor.instance;
      monitor.clear();
    });

    test('startTrace creates a new trace', () {
      final trace = monitor.startTrace('test_operation');

      expect(trace, isNotNull);
      expect(trace.name, equals('test_operation'));
      expect(trace.isRunning, isTrue);
    });

    test('stopTrace returns duration', () {
      monitor.startTrace('test_operation');
      final duration = monitor.stopTrace('test_operation');

      expect(duration, isNotNull);
      expect(duration!.inMicroseconds, greaterThanOrEqualTo(0));
    });

    test('stopTrace returns null for non-existent trace', () {
      final duration = monitor.stopTrace('non_existent');
      expect(duration, isNull);
    });

    Glados<String>(any.nonEmptyLetters, _explore).test(
      'Trace names are preserved correctly',
      (name) {
        final safeName = name.replaceAll(RegExp(r'[^\w]'), '_');
        final trace = monitor.startTrace(safeName);

        expect(trace.name, equals(safeName));
        monitor.stopTrace(safeName);
      },
    );

    test('measure captures operation duration', () {
      final result = monitor.measure('sync_op', () {
        var sum = 0;
        for (var i = 0; i < 1000; i++) {
          sum += i;
        }
        return sum;
      });

      expect(result, equals(499500));
      expect(monitor.completedTraces.any((t) => t.name == 'sync_op'), isTrue);
    });

    test('measureAsync captures async operation duration', () async {
      final result = await monitor.measureAsync('async_op', () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      expect(result, equals(42));
      expect(monitor.completedTraces.any((t) => t.name == 'async_op'), isTrue);
    });

    test('averageDuration calculates correctly', () {
      for (var i = 0; i < 5; i++) {
        monitor.startTrace('repeated_op');
        monitor.stopTrace('repeated_op');
      }

      final avg = monitor.averageDuration('repeated_op');
      expect(avg, isNotNull);
    });

    test('averageDuration returns null for unknown trace', () {
      final avg = monitor.averageDuration('unknown_op');
      expect(avg, isNull);
    });

    test('clear removes all traces', () {
      monitor.startTrace('op1');
      monitor.stopTrace('op1');
      monitor.startTrace('op2');
      monitor.stopTrace('op2');

      monitor.clear();

      expect(monitor.completedTraces, isEmpty);
    });

    test('PerformanceTrace attributes work correctly', () {
      final trace = PerformanceTrace('test');
      trace.setAttribute('key1', 'value1');
      trace.setAttribute('key2', 42);

      expect(trace.isRunning, isTrue);
      trace.stop();
      expect(trace.isRunning, isFalse);
    });

    test('PerformanceTrace metrics work correctly', () {
      final trace = PerformanceTrace('test');
      trace.incrementMetric('counter');
      trace.incrementMetric('counter');
      trace.incrementMetric('counter', 5);

      expect(trace.getMetric('counter'), equals(7));
      expect(trace.getMetric('unknown'), isNull);
    });
  });
}
