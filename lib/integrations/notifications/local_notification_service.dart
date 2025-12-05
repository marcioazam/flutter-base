import 'dart:async';

import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';

/// Notification importance level.
enum NotificationImportance { min, low, normal, high, max }

/// Notification channel configuration.
class NotificationChannel {
  final String id;
  final String name;
  final String? description;
  final NotificationImportance importance;
  final bool playSound;
  final bool enableVibration;
  final bool showBadge;

  const NotificationChannel({
    required this.id,
    required this.name,
    this.description,
    this.importance = NotificationImportance.normal,
    this.playSound = true,
    this.enableVibration = true,
    this.showBadge = true,
  });
}

/// Local notification configuration.
class LocalNotification {
  final int id;
  final String title;
  final String body;
  final String? channelId;
  final String? payload;
  final String? iconPath;
  final String? soundPath;
  final bool ongoing;

  const LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    this.channelId,
    this.payload,
    this.iconPath,
    this.soundPath,
    this.ongoing = false,
  });
}

/// Scheduled notification configuration.
class ScheduledNotification extends LocalNotification {
  final DateTime scheduledDate;
  final bool allowWhileIdle;

  const ScheduledNotification({
    required super.id,
    required super.title,
    required super.body,
    required this.scheduledDate,
    super.channelId,
    super.payload,
    super.iconPath,
    super.soundPath,
    this.allowWhileIdle = true,
  });
}

/// Recurring notification configuration.
class RecurringNotification extends LocalNotification {
  final Duration interval;
  final DateTime? startDate;

  const RecurringNotification({
    required super.id,
    required super.title,
    required super.body,
    required this.interval,
    this.startDate,
    super.channelId,
    super.payload,
    super.iconPath,
    super.soundPath,
  });
}

/// Abstract local notification service interface.
abstract interface class LocalNotificationService {
  /// Stream of notification taps.
  Stream<String?> get onNotificationTap;

  /// Initializes the notification service.
  Future<Result<void>> initialize();

  /// Creates a notification channel (Android).
  Future<void> createChannel(NotificationChannel channel);

  /// Shows an immediate notification.
  Future<Result<void>> show(LocalNotification notification);

  /// Schedules a notification.
  Future<Result<void>> schedule(ScheduledNotification notification);

  /// Schedules a recurring notification.
  Future<Result<void>> scheduleRecurring(RecurringNotification notification);

  /// Cancels a notification by ID.
  Future<void> cancel(int id);

  /// Cancels all notifications.
  Future<void> cancelAll();

  /// Gets pending notifications.
  Future<List<int>> getPendingNotificationIds();

  /// Requests notification permission.
  Future<bool> requestPermission();
}

/// Local notification service implementation.
/// Note: Requires flutter_local_notifications package.
class LocalNotificationServiceImpl implements LocalNotificationService {
  final _tapController = StreamController<String?>.broadcast();

  @override
  Stream<String?> get onNotificationTap => _tapController.stream;

  @override
  Future<Result<void>> initialize() async {
    try {
      // Placeholder - requires flutter_local_notifications package
      // final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      //
      // const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      // const iosSettings = DarwinInitializationSettings(
      //   requestAlertPermission: false,
      //   requestBadgePermission: false,
      //   requestSoundPermission: false,
      // );
      //
      // const settings = InitializationSettings(
      //   android: androidSettings,
      //   iOS: iosSettings,
      // );
      //
      // await flutterLocalNotificationsPlugin.initialize(
      //   settings,
      //   onDidReceiveNotificationResponse: (response) {
      //     _tapController.add(response.payload);
      //   },
      // );

      return const Success(null);
    } catch (e) {
      return Failure(UnexpectedFailure('Notification init failed: $e'));
    }
  }

  @override
  Future<void> createChannel(NotificationChannel channel) async {
    // Placeholder - requires flutter_local_notifications package
    // final androidChannel = AndroidNotificationChannel(
    //   channel.id,
    //   channel.name,
    //   description: channel.description,
    //   importance: _mapImportance(channel.importance),
    //   playSound: channel.playSound,
    //   enableVibration: channel.enableVibration,
    //   showBadge: channel.showBadge,
    // );
    //
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(androidChannel);
  }

  @override
  Future<Result<void>> show(LocalNotification notification) async {
    try {
      // Placeholder - requires flutter_local_notifications package
      // await flutterLocalNotificationsPlugin.show(
      //   notification.id,
      //   notification.title,
      //   notification.body,
      //   NotificationDetails(
      //     android: AndroidNotificationDetails(
      //       notification.channelId ?? 'default',
      //       'Default',
      //       ongoing: notification.ongoing,
      //     ),
      //     iOS: const DarwinNotificationDetails(),
      //   ),
      //   payload: notification.payload,
      // );

      return const Success(null);
    } catch (e) {
      return Failure(UnexpectedFailure('Show notification failed: $e'));
    }
  }

  @override
  Future<Result<void>> schedule(ScheduledNotification notification) async {
    try {
      // Placeholder - requires flutter_local_notifications package
      // await flutterLocalNotificationsPlugin.zonedSchedule(
      //   notification.id,
      //   notification.title,
      //   notification.body,
      //   tz.TZDateTime.from(notification.scheduledDate, tz.local),
      //   NotificationDetails(...),
      //   androidScheduleMode: notification.allowWhileIdle
      //       ? AndroidScheduleMode.exactAllowWhileIdle
      //       : AndroidScheduleMode.exact,
      //   uiLocalNotificationDateInterpretation:
      //       UILocalNotificationDateInterpretation.absoluteTime,
      //   payload: notification.payload,
      // );

      return const Success(null);
    } catch (e) {
      return Failure(UnexpectedFailure('Schedule notification failed: $e'));
    }
  }

  @override
  Future<Result<void>> scheduleRecurring(
    RecurringNotification notification,
  ) async {
    try {
      // Placeholder - requires flutter_local_notifications package
      // await flutterLocalNotificationsPlugin.periodicallyShow(
      //   notification.id,
      //   notification.title,
      //   notification.body,
      //   _mapInterval(notification.interval),
      //   NotificationDetails(...),
      //   payload: notification.payload,
      // );

      return const Success(null);
    } catch (e) {
      return Failure(UnexpectedFailure('Schedule recurring failed: $e'));
    }
  }

  @override
  Future<void> cancel(int id) async {
    // Placeholder - requires flutter_local_notifications package
    // await flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    // Placeholder - requires flutter_local_notifications package
    // await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<List<int>> getPendingNotificationIds() async {
    // Placeholder - requires flutter_local_notifications package
    // final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    // return pending.map((n) => n.id).toList();
    return [];
  }

  @override
  Future<bool> requestPermission() async {
    // Placeholder - requires flutter_local_notifications package
    // final result = await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         IOSFlutterLocalNotificationsPlugin>()
    //     ?.requestPermissions(alert: true, badge: true, sound: true);
    // return result ?? false;
    return false;
  }

  void dispose() {
    _tapController.close();
  }
}

/// Local notification service factory.
LocalNotificationService createLocalNotificationService() =>
    LocalNotificationServiceImpl();
