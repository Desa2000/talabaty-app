import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../constants/enums.dart';
import '../../data/models/product_model.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/merchant/screens/merchant_main_screen.dart';
import '../../features/merchant/screens/merchant_orders_screen.dart';
import '../../features/merchant/screens/merchant_products_screen.dart';
import '../../features/merchant/screens/add_product_screen.dart';
import '../../features/merchant/screens/edit_product_screen.dart';
import '../../features/merchant/screens/inventory_screen.dart';

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
        if (auth.currentUser?.role == UserRole.merchant) {
          return '/merchant';
        } else {
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
        path: '/merchant',
        builder: (context, state) => const MerchantMainScreen(),
      ),
      GoRoute(
        path: '/merchant/orders',
        builder: (context, state) => const MerchantOrdersScreen(),
      ),
      GoRoute(
        path: '/merchant/products',
        builder: (context, state) => const MerchantProductsScreen(),
      ),
      GoRoute(
        path: '/merchant/products/add',
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/merchant/products/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final products = context.read<ProductProvider>().products;
          final product = products.firstWhere(
            (p) => p.id == id,
            orElse: () => products.isNotEmpty
                ? products.first
                : ProductModel(
                    id: id,
                    storeId: '',
                    name: 'المنتج غير موجود',
                    description: '',
                    image: '',
                    category: '',
                    price: 0,
                    stockQuantity: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
          );
          return EditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: '/merchant/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
    ],
  );
}

class RouterNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
