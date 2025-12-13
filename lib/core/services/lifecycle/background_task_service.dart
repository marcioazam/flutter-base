import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'background_task_service.g.dart';

/// Background task execution status
enum BackgroundTaskStatus { idle, running, completed, failed, cancelled }

/// Background task result
sealed class BackgroundTaskResult<T> {
  const BackgroundTaskResult();
}

final class BackgroundTaskSuccess<T> extends BackgroundTaskResult<T> {
  const BackgroundTaskSuccess(this.data);
  final T data;
}

final class BackgroundTaskFailure<T> extends BackgroundTaskResult<T> {
  const BackgroundTaskFailure(this.error, [this.stackTrace]);
  final Object error;
  final StackTrace? stackTrace;
}

/// Configuration for background task
class BackgroundTaskConfig {
  const BackgroundTaskConfig({
    this.taskId,
    this.initialDelay = Duration.zero,
    this.frequency,
    this.requiresNetwork = false,
    this.requiresCharging = false,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 30),
  });

  final String? taskId;
  final Duration initialDelay;
  final Duration? frequency;
  final bool requiresNetwork;
  final bool requiresCharging;
  final int maxRetries;
  final Duration retryDelay;
}

/// Background task definition
class BackgroundTask<T> {
  BackgroundTask({
    required this.id,
    required this.execute,
    this.config = const BackgroundTaskConfig(),
  });

  final String id;
  final Future<T> Function() execute;
  final BackgroundTaskConfig config;

  int _retryCount = 0;
  BackgroundTaskStatus _status = BackgroundTaskStatus.idle;

  BackgroundTaskStatus get status => _status;
  int get retryCount => _retryCount;
  bool get canRetry => _retryCount < config.maxRetries;
}

/// Service for managing background tasks
/// Uses platform-specific implementations (WorkManager/BGTaskScheduler)
abstract interface class BackgroundTaskService {
  /// Register a one-time background task
  Future<void> registerOneTimeTask<T>(BackgroundTask<T> task);

  /// Register a periodic background task
  Future<void> registerPeriodicTask<T>(
    BackgroundTask<T> task,
    Duration frequency,
  );

  /// Cancel a specific task
  Future<void> cancelTask(String taskId);

  /// Cancel all registered tasks
  Future<void> cancelAllTasks();

  /// Check if a task is registered
  Future<bool> isTaskRegistered(String taskId);

  /// Get task status
  BackgroundTaskStatus getTaskStatus(String taskId);

  /// Stream of task completion events
  Stream<BackgroundTaskResult<dynamic>> get taskCompletionStream;
}

/// In-memory implementation for development/testing
class InMemoryBackgroundTaskService implements BackgroundTaskService {
  final Map<String, BackgroundTask<dynamic>> _tasks = {};
  final Map<String, Timer> _timers = {};
  final _completionController =
      StreamController<BackgroundTaskResult<dynamic>>.broadcast();

  @override
  Future<void> registerOneTimeTask<T>(BackgroundTask<T> task) async {
    _tasks[task.id] = task;

    if (task.config.initialDelay > Duration.zero) {
      _timers[task.id] = Timer(task.config.initialDelay, () {
        _executeTask(task);
      });
    } else {
      await _executeTask(task);
    }
  }

  @override
  Future<void> registerPeriodicTask<T>(
    BackgroundTask<T> task,
    Duration frequency,
  ) async {
    _tasks[task.id] = task;

    _timers[task.id] = Timer.periodic(frequency, (_) {
      _executeTask(task);
    });
  }

  Future<void> _executeTask<T>(BackgroundTask<T> task) async {
    task._status = BackgroundTaskStatus.running;

    try {
      final result = await task.execute();
      task._status = BackgroundTaskStatus.completed;
      _completionController.add(BackgroundTaskSuccess<T>(result));
    } on Exception catch (e, st) {
      task._retryCount++;

      if (task.canRetry) {
        await Future<void>.delayed(task.config.retryDelay);
        await _executeTask(task);
      } else {
        task._status = BackgroundTaskStatus.failed;
        _completionController.add(BackgroundTaskFailure<T>(e, st));
      }
    }
  }

  @override
  Future<void> cancelTask(String taskId) async {
    _timers[taskId]?.cancel();
    _timers.remove(taskId);

    final task = _tasks[taskId];
    if (task != null) {
      task._status = BackgroundTaskStatus.cancelled;
    }
    _tasks.remove(taskId);
  }

  @override
  Future<void> cancelAllTasks() async {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    for (final task in _tasks.values) {
      task._status = BackgroundTaskStatus.cancelled;
    }
    _tasks.clear();
  }

  @override
  Future<bool> isTaskRegistered(String taskId) async =>
      _tasks.containsKey(taskId);

  @override
  BackgroundTaskStatus getTaskStatus(String taskId) =>
      _tasks[taskId]?.status ?? BackgroundTaskStatus.idle;

  @override
  Stream<BackgroundTaskResult<dynamic>> get taskCompletionStream =>
      _completionController.stream;

  void dispose() {
    cancelAllTasks();
    _completionController.close();
  }
}

@Riverpod(keepAlive: true)
BackgroundTaskService backgroundTaskService(Ref ref) {
  final service = InMemoryBackgroundTaskService();
  ref.onDispose(service.dispose);
  return service;
}
