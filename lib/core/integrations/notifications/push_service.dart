import 'dart:async';

import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// Push notification message.
class PushNotification {

  const PushNotification({
    required this.receivedAt, this.title,
    this.body,
    this.data,
    this.imageUrl,
  });

  factory PushNotification.fromJson(Map<String, dynamic> json) => PushNotification(
      title: json['title'] as String?,
      body: json['body'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      receivedAt: json['receivedAt'] != null
          ? DateTime.parse(json['receivedAt'] as String)
          : DateTime.now(),
    );
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final DateTime receivedAt;

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'data': data,
        'imageUrl': imageUrl,
        'receivedAt': receivedAt.toIso8601String(),
      };
}

/// Push notification authorization status.
enum PushAuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
}

/// Abstract push notification service interface.
abstract interface class PushNotificationService {
  /// Stream of incoming notifications when app is in foreground.
  Stream<PushNotification> get onForegroundMessage;

  /// Stream of notification taps.
  Stream<PushNotification> get onNotificationTap;

  /// Stream of token changes.
  Stream<String> get onTokenRefresh;

  /// Initializes the push notification service.
  Future<Result<void>> initialize();

  /// Requests notification permission.
  Future<PushAuthorizationStatus> requestPermission();

  /// Gets the current FCM token.
  Future<String?> getToken();

  /// Subscribes to a topic.
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes from a topic.
  Future<void> unsubscribeFromTopic(String topic);

  /// Gets the initial notification that opened the app.
  Future<PushNotification?> getInitialNotification();
}

/// Push notification service implementation.
/// Note: Requires firebase_messaging package.
class PushNotificationServiceImpl implements PushNotificationService {
  final _foregroundController = StreamController<PushNotification>.broadcast();
  final _tapController = StreamController<PushNotification>.broadcast();
  final _tokenController = StreamController<String>.broadcast();

  @override
  Stream<PushNotification> get onForegroundMessage =>
      _foregroundController.stream;

  @override
  Stream<PushNotification> get onNotificationTap => _tapController.stream;

  @override
  Stream<String> get onTokenRefresh => _tokenController.stream;

  @override
  Future<Result<void>> initialize() async {
    try {
      // Placeholder - requires firebase_messaging package
      // await Firebase.initializeApp();
      //
      // FirebaseMessaging.onMessage.listen((message) {
      //   _foregroundController.add(PushNotification(
      //     title: message.notification?.title,
      //     body: message.notification?.body,
      //     data: message.data,
      //     imageUrl: message.notification?.android?.imageUrl ??
      //         message.notification?.apple?.imageUrl,
      //     receivedAt: DateTime.now(),
      //   ));
      // });
      //
      // FirebaseMessaging.onMessageOpenedApp.listen((message) {
      //   _tapController.add(PushNotification(
      //     title: message.notification?.title,
      //     body: message.notification?.body,
      //     data: message.data,
      //     receivedAt: DateTime.now(),
      //   ));
      // });
      //
      // FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      //   _tokenController.add(token);
      // });

      return const Success(null);
    } on Exception catch (e) {
      return Failure(UnexpectedFailure('Push notification init failed: $e'));
    }
  }

  @override
  Future<PushAuthorizationStatus> requestPermission() async {
    // Placeholder - requires firebase_messaging package
    // final settings = await FirebaseMessaging.instance.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    //
    // return switch (settings.authorizationStatus) {
    //   AuthorizationStatus.authorized => PushAuthorizationStatus.authorized,
    //   AuthorizationStatus.denied => PushAuthorizationStatus.denied,
    //   AuthorizationStatus.notDetermined => PushAuthorizationStatus.notDetermined,
    //   AuthorizationStatus.provisional => PushAuthorizationStatus.provisional,
    // };

    return PushAuthorizationStatus.notDetermined;
  }

  @override
  Future<String?> getToken() async {
    // Placeholder - requires firebase_messaging package
    // return await FirebaseMessaging.instance.getToken();
    return null;
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    // Placeholder - requires firebase_messaging package
    // await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    // Placeholder - requires firebase_messaging package
    // await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  @override
  Future<PushNotification?> getInitialNotification() async {
    // Placeholder - requires firebase_messaging package
    // final message = await FirebaseMessaging.instance.getInitialMessage();
    // if (message == null) return null;
    //
    // return PushNotification(
    //   title: message.notification?.title,
    //   body: message.notification?.body,
    //   data: message.data,
    //   receivedAt: DateTime.now(),
    // );

    return null;
  }

  void dispose() {
    _foregroundController.close();
    _tapController.close();
    _tokenController.close();
  }
}

/// Push notification service factory.
PushNotificationService createPushNotificationService() =>
    PushNotificationServiceImpl();
