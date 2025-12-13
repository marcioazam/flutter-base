/// Performance trace for timing operations.
class PerformanceTrace {
  PerformanceTrace(this.name) : startTime = DateTime.now();
  final String name;
  final DateTime startTime;
  DateTime? _endTime;
  final Map<String, dynamic> _attributes = {};
  final Map<String, int> _metrics = {};

  /// Stops the trace and returns duration.
  Duration stop() {
    _endTime = DateTime.now();
    return duration;
  }

  /// Returns trace duration.
  Duration get duration {
    final end = _endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Returns true if trace is still running.
  bool get isRunning => _endTime == null;

  /// Sets a custom attribute.
  void setAttribute(String key, dynamic value) {
    _attributes[key] = value;
  }

  /// Increments a metric counter.
  void incrementMetric(String name, [int value = 1]) {
    _metrics[name] = (_metrics[name] ?? 0) + value;
  }

  /// Gets metric value.
  int? getMetric(String name) => _metrics[name];

  @override
  String toString() =>
      'PerformanceTrace($name, duration: ${duration.inMilliseconds}ms)';
}

/// Performance monitor for tracking operation timing.
class PerformanceMonitor {
  PerformanceMonitor._({int maxCompletedTraces = 100})
    : _maxCompletedTraces = maxCompletedTraces;
  final Map<String, PerformanceTrace> _activeTraces = {};
  final List<PerformanceTrace> _completedTraces = [];
  final int _maxCompletedTraces;

  static PerformanceMonitor? _instance;

  /// Gets or creates singleton instance.
  static PerformanceMonitor get instance {
    _instance ??= PerformanceMonitor._();
    return _instance!;
  }

  /// Starts a new trace.
  PerformanceTrace startTrace(String name) {
    final trace = PerformanceTrace(name);
    _activeTraces[name] = trace;
    return trace;
  }

  /// Stops a trace by name.
  Duration? stopTrace(String name) {
    final trace = _activeTraces.remove(name);
    if (trace == null) return null;

    final duration = trace.stop();
    _completedTraces.add(trace);

    // Keep only recent traces
    while (_completedTraces.length > _maxCompletedTraces) {
      _completedTraces.removeAt(0);
    }

    return duration;
  }

  /// Gets an active trace by name.
  PerformanceTrace? getTrace(String name) => _activeTraces[name];

  /// Measures an async operation.
  Future<T> measureAsync<T>(String name, Future<T> Function() operation) async {
    final trace = startTrace(name);
    try {
      return await operation();
    } finally {
      trace.stop();
      _activeTraces.remove(name);
      _completedTraces.add(trace);
    }
  }

  /// Measures a sync operation.
  T measure<T>(String name, T Function() operation) {
    final trace = startTrace(name);
    try {
      return operation();
    } finally {
      trace.stop();
      _activeTraces.remove(name);
      _completedTraces.add(trace);
    }
  }

  /// Gets completed traces.
  List<PerformanceTrace> get completedTraces =>
      List.unmodifiable(_completedTraces);

  /// Gets average duration for a trace name.
  Duration? averageDuration(String name) {
    final traces = _completedTraces.where((t) => t.name == name).toList();
    if (traces.isEmpty) return null;

    final totalMs = traces.fold<int>(
      0,
      (sum, trace) => sum + trace.duration.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ traces.length);
  }

  /// Clears all traces.
  void clear() {
    _activeTraces.clear();
    _completedTraces.clear();
  }
}

/// Global performance monitor instance.
PerformanceMonitor get performanceMonitor => PerformanceMonitor.instance;
