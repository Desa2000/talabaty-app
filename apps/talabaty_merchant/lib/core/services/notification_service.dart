import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _lastRegisteredToken;
  String? _currentAppType;

  Future<void> initialize() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _localNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground: ${message.data}');
        if (message.notification != null) {
          _showLocalNotification(message);
        }
      });

      _fcm.onTokenRefresh.listen((newToken) {
        if (_currentAppType != null) {
          registerFCMToken(_currentAppType!, overrideToken: newToken);
        }
      });
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Register FCM token to Backend PostgreSQL database via REST API
  Future<void> registerFCMToken(String appType, {String? overrideToken}) async {
    _currentAppType = appType;
    try {
      final token = overrideToken ?? await _fcm.getToken();
      if (token == null || token.isEmpty) return;

      _lastRegisteredToken = token;
      await ApiClient().dio.post(
        '/devices/token',
        data: {
          'token': token,
          'platform': 'ANDROID',
          'appType': appType,
        },
      );
      debugPrint('FCM token registered to backend [$appType]');
    } catch (e) {
      debugPrint('Error registering FCM token to backend: $e');
    }
  }

  /// Unregister FCM token on logout
  Future<void> unregisterFCMToken() async {
    try {
      final token = _lastRegisteredToken ?? await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        await ApiClient().dio.delete(
          '/devices/token',
          data: {'token': token},
        );
        debugPrint('FCM token unregistered from backend');
      }
    } catch (e) {
      debugPrint('Error unregistering FCM token from backend: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'talabaty_main_channel',
            'Talabaty Notifications',
            channelDescription: 'Main channel for Talabaty order notifications',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _localNotificationsPlugin.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'إشعار جديد',
        body: message.notification?.body ?? '',
        notificationDetails: notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      return null;
    }
  }
}
