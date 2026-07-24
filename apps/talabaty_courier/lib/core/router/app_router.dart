import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../constants/enums.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/courier/screens/courier_main_screen.dart';
import '../../features/courier/screens/courier_delivery_screen.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final authNotifier = RouterNotifier();

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isAuth = auth.isAuthenticated;
      final isGoingToSplash = state.uri.toString() == '/splash';
      final isGoingToLogin = state.uri.toString() == '/login';
      final isGoingToRegister = state.uri.toString() == '/register';
      final isGoingToOtp = state.uri.toString() == '/otp';

      if (!isAuth &&
          !isGoingToSplash &&
          !isGoingToLogin &&
          !isGoingToRegister &&
          !isGoingToOtp) {
        return '/login';
      }

      if (isAuth && (isGoingToLogin || isGoingToRegister || isGoingToSplash)) {
        if (auth.currentUser?.role == UserRole.courier) {
          return '/courier';
        } else {
          // Non-courier account trying to open courier app
          return '/login';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final Map<String, dynamic> data =
              state.extra as Map<String, dynamic>? ??
              {'phone': '', 'email': ''};
          return OtpScreen(
            phone: data['phone']?.toString() ?? '',
            email: data['email']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final Map<String, dynamic> data =
              state.extra as Map<String, dynamic>? ??
              {'phone': '', 'email': ''};
          return RegisterScreen(
            phone: data['phone']?.toString() ?? '',
            email: data['email']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: '/courier',
        builder: (context, state) => const CourierMainScreen(),
      ),
      GoRoute(
        path: '/courier/delivery/:id',
        builder: (context, state) =>
            CourierDeliveryScreen(orderId: state.pathParameters['id']!),
      ),
    ],
  );
}

class RouterNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
