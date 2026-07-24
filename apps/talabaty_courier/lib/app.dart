import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/data_provider.dart';
import 'core/providers/notification_provider.dart';

class TalabatyApp extends StatelessWidget {
  const TalabatyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'طلباتي مندوب',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
            locale: const Locale('ar', 'SA'),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
