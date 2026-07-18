import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../router/app_router.dart';
import '../constants/app_colors.dart';

class AppNotification {
  final String title;
  final String body;
  final IconData? icon;
  final DateTime createdAt;

  AppNotification({required this.title, required this.body, this.icon, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();
}

class NotificationProvider extends ChangeNotifier {
  String? fcmToken;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final List<AppNotification> _notifications = [];
  bool _isDisposed = false;
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get hasUnread => _notifications.isNotEmpty;

  @override
  void dispose() {
    _isDisposed = true;
    _fcmSubscription?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void removeAt(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> initFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      // Initialize Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
      await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
      if (_isDisposed) return;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (_isDisposed) return;

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        fcmToken = await messaging.getToken();
        if (_isDisposed) return;
        debugPrint('FCM Token: $fcmToken');
        
        await _fcmSubscription?.cancel();
        _fcmSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (_isDisposed) return;
          if (message.notification != null) {
            showNotification(
              title: message.notification!.title ?? 'إشعار جديد',
              body: message.notification!.body ?? '',
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  Future<void> showLocalNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      
      await flutterLocalNotificationsPlugin.show(
        id: DateTime.now().millisecond,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  void showNotification({
    required String title,
    required String body,
    IconData? icon,
    Color? color,
  }) {
    // Save to notification history list
    _notifications.insert(0, AppNotification(title: title, body: body, icon: icon));
    notifyListeners();

    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null) return;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -100.0, end: 0.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
                border: Border.all(color: color ?? AppColors.primaryColor, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (color ?? AppColors.primaryColor).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon ?? Icons.notifications_active,
                      color: color ?? AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () {
                      overlayEntry.remove();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
