import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/enums.dart';

import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/product_model.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/customer/screens/customer_main_screen.dart';
import '../../features/customer/screens/store_details_screen.dart';
import '../../features/customer/screens/product_details_screen_v2.dart';
import '../../features/customer/screens/stores_screen.dart';
import '../../features/customer/screens/cart_screen.dart';
import '../../features/customer/screens/checkout_screen.dart';
import '../../features/customer/screens/order_tracking_screen.dart';
import '../../features/customer/screens/address_screen.dart';
import '../../features/customer/screens/map_picker_screen.dart';
import '../../features/customer/screens/notifications_screen.dart';
import '../../features/customer/screens/search_screen.dart';
import '../../features/customer/screens/add_address_screen.dart';
import '../../features/customer/screens/favorites_screen.dart';
import '../../features/customer/screens/payment_methods_screen.dart';
import '../../features/customer/screens/settings_screen.dart';
import '../../features/courier/screens/courier_main_screen.dart';
import '../../features/courier/screens/courier_delivery_screen.dart';
import '../../features/merchant/screens/merchant_main_screen.dart';
import '../../features/merchant/screens/merchant_orders_screen.dart';
import '../../features/merchant/screens/merchant_pos_screen.dart';
import '../../features/merchant/screens/products_screen.dart';
import '../../features/merchant/screens/add_product_screen.dart';
import '../../features/merchant/screens/edit_product_screen.dart';
import '../../features/merchant/screens/inventory_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_orders_screen.dart';
import '../../features/admin/screens/admin_merchants_screen.dart';
import '../../features/admin/screens/admin_couriers_screen.dart';

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

      if (!isAuth && !isGoingToSplash && !isGoingToLogin && !isGoingToRegister && !isGoingToOtp) {
        return '/login';
      }

      if (isAuth && (isGoingToLogin || isGoingToRegister || isGoingToSplash)) {
        switch (auth.currentUser!.role) {
          case UserRole.customer:
            return '/customer';
          case UserRole.courier:
            return '/courier';
          case UserRole.merchant:
            return '/merchant';
          case UserRole.admin:
            return '/admin';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>? ?? {'phone': '', 'email': ''};
          return OtpScreen(phone: data['phone']?.toString() ?? '', email: data['email']?.toString() ?? '');
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>? ?? {'phone': '', 'email': ''};
          return RegisterScreen(phone: data['phone']?.toString() ?? '', email: data['email']?.toString() ?? '');
        },
      ),
      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerMainScreen(),
      ),
      GoRoute(
        path: '/customer/address',
        builder: (context, state) => const AddressScreen(),
      ),
      GoRoute(
        path: '/customer/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/customer/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/customer/map_picker',
        builder: (context, state) => const MapPickerScreen(),
      ),
      GoRoute(
        path: '/add-address',
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: '/customer/store/:id',
        builder: (context, state) => StoreDetailsScreen(storeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/stores/:type',
        builder: (context, state) => StoresScreen(categoryType: state.pathParameters['type']!),
      ),
      GoRoute(
        path: '/customer/product/:id',
        builder: (context, state) => ProductDetailsScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/customer/order-tracking/:id',
        builder: (context, state) => OrderTrackingScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/customer/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/customer/payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/customer/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/courier',
        builder: (context, state) => const CourierMainScreen(),
      ),
      GoRoute(
        path: '/courier/delivery/:id',
        builder: (context, state) => CourierDeliveryScreen(orderId: state.pathParameters['id']!),
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
        path: '/merchant/pos',
        builder: (context, state) => const MerchantPOSScreen(),
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
                    name: 'Product not found',
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
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/merchants',
        builder: (context, state) => const AdminMerchantsScreen(),
      ),
      GoRoute(
        path: '/admin/couriers',
        builder: (context, state) => const AdminCouriersScreen(),
      ),
    ],
  );
}

class RouterNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
