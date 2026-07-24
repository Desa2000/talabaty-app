import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  runApp(const TalabatyApp());
}
