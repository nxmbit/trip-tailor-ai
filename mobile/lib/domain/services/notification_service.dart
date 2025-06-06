import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/data/api/api_client.dart';
import '../../data/api/endpoints.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;
  ApiClient? _apiClient;

  void setApiClient(ApiClient apiClient) {
    _apiClient = apiClient;
  }

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('Permission status: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    // android setup
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
    AndroidInitializationSettings('notification_icon');

    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid
    );

    // flutter notification setup
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
              'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: 'notification_icon',
            )
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    //foreground message
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    // background message
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      // open chat screen
    }
  }

  // Expose method to get FCM token
  Future<String?> getFcmToken() async {
    return await _messaging.getToken();
  }

  Future<void> clearFcmTokenOnLogout() async {
    try {
      final String? token = await _messaging.getToken();

      if (token != null && _apiClient != null) {
        try {
          await _apiClient!.dio.delete(
              Endpoints.firebaseTokenEndpoint,
              data: {'token': token}
          );
        } catch (e) {
          print('Error removing token from backend: $e');
        }
      }

      await _messaging.deleteToken();
    } catch (e) {
      print('Error clearing FCM token: $e');
    }
  }
}