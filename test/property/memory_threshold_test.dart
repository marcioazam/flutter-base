import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart';

import 'package:flutter_base_2025/core/observability/performance_monitor.dart';

/// **Feature: flutter-2025-final-polish, Property 8: Memory Threshold Cache Cleanup**
/// **Validates: Requirements 12.4**
void main() {
  group('Memory Threshold Properties', () {
    late MemoryMonitor monitor;
    late bool cleanupCalled;

    setUp(() {
      cleanupCalled = false;
      monitor = MemoryMonitor(
        thresholdBytes: 100 * 1024 * 1024, // 100MB
        onThresholdExceeded: () => cleanupCalled = true,
      );
    });

    tearDown(() {
      monitor.dispose();
    });

    Glados<int>(iterations: 100).test(
      'Cleanup callback is triggered when memory exceeds threshold',
      (memoryMB) async {
        // Ensure positive memory value
        final memoryBytes = (memoryMB.abs() % 500 + 1) * 1024 * 1024;
        final threshold = 100 * 1024 * 1024; // 100MB

        cleanupCalled = false;
        monitor.reportMemoryUsage(memoryBytes);
        await monitor.checkMemory();

        if (memoryBytes > threshold) {
          expect(cleanupCalled, isTrue,
              reason: 'Cleanup should be called when memory ($memoryBytes) > threshold ($threshold)');
        } else {
          expect(cleanupCalled, isFalse,
              reason: 'Cleanup should NOT be called when memory ($memoryBytes) <= threshold ($threshold)');
        }
      },
    );

    test('Cleanup is NOT triggered when memory is below threshold', () async {
      monitor.reportMemoryUsage(50 * 1024 * 1024); // 50MB
      final result = await monitor.checkMemory();

      expect(result.exceeded, isFalse);
      expect(cleanupCalled, isFalse);
    });

    test('Cleanup IS triggered when memory exceeds threshold', () async {
      monitor.reportMemoryUsage(150 * 1024 * 1024); // 150MB
      final result = await monitor.checkMemory();

      expect(result.exceeded, isTrue);
      expect(cleanupCalled, isTrue);
    });

    test('Cleanup is triggered at exact threshold boundary', () async {
      // At exactly threshold, should NOT trigger (> not >=)
      monitor.reportMemoryUsage(100 * 1024 * 1024); // Exactly 100MB
      final result = await monitor.checkMemory();

      expect(result.exceeded, isFalse);
      expect(cleanupCalled, isFalse);
    });

    test('Cleanup is triggered just above threshold', () async {
      monitor.reportMemoryUsage(100 * 1024 * 1024 + 1); // 100MB + 1 byte
      final result = await monitor.checkMemory();

      expect(result.exceeded, isTrue);
      expect(cleanupCalled, isTrue);
    });

    test('MemoryCheckResult calculates usage percentage correctly', () async {
      monitor.reportMemoryUsage(75 * 1024 * 1024); // 75MB
      final result = await monitor.checkMemory();

      expect(result.usagePercentage, closeTo(75.0, 0.1));
    });

    test('simulateMemoryPressure triggers check', () async {
      monitor.simulateMemoryPressure(200 * 1024 * 1024); // 200MB

      // Give async callback time to execute
      await Future.delayed(Duration.zero);

      expect(cleanupCalled, isTrue);
    });

    test('Custom threshold is respected', () async {
      final customMonitor = MemoryMonitor(
        thresholdBytes: 50 * 1024 * 1024, // 50MB threshold
        onThresholdExceeded: () => cleanupCalled = true,
      );

      cleanupCalled = false;
      customMonitor.reportMemoryUsage(60 * 1024 * 1024); // 60MB
      await customMonitor.checkMemory();

      expect(cleanupCalled, isTrue);

      customMonitor.dispose();
    });
  });

  group('MemoryMonitorService', () {
    test('Singleton instance is created', () {
      final instance1 = MemoryMonitorService.instance;
      final instance2 = MemoryMonitorService.instance;

      expect(identical(instance1, instance2), isTrue);
    });

    test('Configure creates new instance with settings', () {
      var called = false;
      MemoryMonitorService.configure(
        thresholdBytes: 200 * 1024 * 1024,
        onThresholdExceeded: () => called = true,
      );

      final instance = MemoryMonitorService.instance;
      expect(instance.thresholdBytes, equals(200 * 1024 * 1024));
    });
  });
}
