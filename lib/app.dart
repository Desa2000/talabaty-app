import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/data_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/product_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/address_provider.dart';

import 'core/providers/payment_provider.dart';
import 'features/customer/screens/customer_main_screen.dart';

class TalabatyApp extends StatelessWidget {
  const TalabatyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'طلباتي',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('en', 'US'),
            ],
            locale: const Locale('ar', 'SA'),
            routerConfig: AppRouter.router,
          );
        }
      ),
    );
  }
}
