import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/store_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/user_model.dart';
import '../../data/mock/mock_data.dart';
import '../../data/mock/data_mapper.dart';
import '../../core/constants/enums.dart';
import 'package:provider/provider.dart';
import '../router/app_router.dart';
import 'notification_provider.dart';
import '../services/firestore_service.dart';

class DataProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  List<StoreModel> _stores = MockData.mockStores;
  List<ProductModel> _products = MockData.mockProducts;
  List<OrderModel> _orders = [];
  List<CourierProfile> _couriers = MockData.mockCourierProfiles;
  List<UserModel> _users = [...MockData.mockCustomers, ...MockData.mockMerchantUsers, ...MockData.mockCourierUsers];
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool _isDisposed = false;

  StreamSubscription<List<StoreModel>>? _storesSubscription;
  StreamSubscription<List<ProductModel>>? _productsSubscription;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  DataProvider() {
    _initData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _storesSubscription?.cancel();
    _productsSubscription?.cancel();
    _ordersSubscription?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> _initData() async {
    // Load local cache if available, fallback to mock data
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      
      try {
        final usersData = prefs.getString('users');
        if (usersData != null && usersData.isNotEmpty) {
          _users = DataMapper.decodeUsers(usersData);
        } else {
          _users = MockData.mockCustomers + MockData.mockMerchantUsers + MockData.mockCourierUsers;
        }
      } catch (e) {
        debugPrint('Error decoding users from cache: $e');
        _users = MockData.mockCustomers + MockData.mockMerchantUsers + MockData.mockCourierUsers;
      }

      try {
        final couriersData = prefs.getString('couriers');
        if (couriersData != null && couriersData.isNotEmpty) {
          _couriers = DataMapper.decodeCouriers(couriersData);
        } else {
          _couriers = MockData.mockCourierProfiles;
        }
      } catch (e) {
        debugPrint('Error decoding couriers from cache: $e');
        _couriers = MockData.mockCourierProfiles;
      }

      try {
        final storesData = prefs.getString('stores');
        if (storesData != null && storesData.isNotEmpty) {
          _stores = DataMapper.decodeStores(storesData);
        } else {
          _stores = MockData.mockStores;
        }
      } catch (e) {
        debugPrint('Error decoding stores from cache: $e');
        _stores = MockData.mockStores;
      }

      try {
        final productsData = prefs.getString('products');
        if (productsData != null && productsData.isNotEmpty) {
          _products = DataMapper.decodeProducts(productsData);
        } else {
          _products = MockData.mockProducts;
        }
      } catch (e) {
        debugPrint('Error decoding products from cache: $e');
        _products = MockData.mockProducts;
      }
    } catch (e) {
      debugPrint('Error loading cached data from SharedPreferences: $e');
      if (_isDisposed) return;
      _users = MockData.mockCustomers + MockData.mockMerchantUsers + MockData.mockCourierUsers;
      _couriers = MockData.mockCourierProfiles;
      _stores = MockData.mockStores;
      _products = MockData.mockProducts;
    }

    notifyListeners();

    if (_isDisposed) return;

    try {
      // Listen to real-time data instead of mock data
      await _storesSubscription?.cancel();
      if (_isDisposed) return;
      _storesSubscription = _firestore.streamStores().listen((stores) {
        if (_isDisposed) return;

        // Firestore may be empty while the project is still being prepared.
        // In that case, keep the cached/mock stores instead of replacing them
        // with an empty list and leaving the customer home screen blank.
        if (stores.isNotEmpty) {
          _stores = stores;
          unawaited(_saveData());
          debugPrint('Loaded ${stores.length} stores from Firestore.');
        } else {
          debugPrint(
            'Firestore stores collection is empty; running auto-migration...',
          );
          unawaited(migrateDataToFirestore());
        }

        notifyListeners();
      }, onError: (Object error, StackTrace stackTrace) {
        debugPrint('Error streaming stores: $error');
        debugPrintStack(stackTrace: stackTrace);
        // Keep the local/mock data when Firestore is unavailable.
        notifyListeners();
      });

      await _productsSubscription?.cancel();
      if (_isDisposed) return;
      _productsSubscription = _firestore.streamProducts().listen((products) {
        if (_isDisposed) return;

        // Keep cached/mock products if the remote collection is empty.
        if (products.isNotEmpty) {
          _products = products;
          unawaited(_saveData());
          debugPrint('Loaded ${products.length} products from Firestore.');
        } else {
          debugPrint(
            'Firestore products collection is empty; keeping ${_products.length} local products.',
          );
        }

        notifyListeners();
      }, onError: (Object error, StackTrace stackTrace) {
        debugPrint('Error streaming products: $error');
        debugPrintStack(stackTrace: stackTrace);
        // Keep the local/mock data when Firestore is unavailable.
        notifyListeners();
      });

      await _ordersSubscription?.cancel();
      if (_isDisposed) return;
      _ordersSubscription = _firestore.streamAllOrders().listen((syncedOrders) {
        if (_isDisposed) return;
        _orders = syncedOrders;
        unawaited(_saveData());
        notifyListeners();
      }, onError: (Object error, StackTrace stackTrace) {
        debugPrint('Error streaming orders: $error');
        debugPrintStack(stackTrace: stackTrace);
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Firestore streams are not initialized/available: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> migrateDataToFirestore() async {
    try {
      for (var store in MockData.mockStores) {
        await _firestore.saveStore(store);
      }
      for (var product in MockData.mockProducts) {
        await _firestore.saveProduct(product);
      }
      debugPrint("Migration completed!");
    } catch (e) {
      debugPrint("Migration failed: $e");
    }
  }

  Future<void> _saveData() async {
    if (_isDisposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      await prefs.setString('users', DataMapper.encodeUsers(_users));
      await prefs.setString('stores', DataMapper.encodeStores(_stores));
      await prefs.setString('products', DataMapper.encodeProducts(_products));
      await prefs.setString('couriers', DataMapper.encodeCouriers(_couriers));
    } catch (e) {
      debugPrint('Error saving data to SharedPreferences: $e');
    }
  }

  void _loadMockData() {
    _stores = MockData.mockStores;
    _products = MockData.mockProducts;
    _couriers = MockData.mockCourierProfiles;
    _users = [...MockData.mockCustomers, ...MockData.mockCourierUsers, ...MockData.mockMerchantUsers];
  }

  List<StoreModel> get stores => _stores;
  List<ProductModel> get products => _products;
  List<OrderModel> get orders => _orders;
  List<CourierProfile> get couriers => _couriers;
  List<UserModel> get users => _users;

  // Registration
  void registerNewUser(UserModel user, Map<String, dynamic>? extraData) {
    _users.add(user);
    if (user.role == UserRole.courier && extraData != null) {
      final newCourier = CourierProfile(
        userId: user.id,
        nationalId: extraData['idNumber'] as String? ?? '000000000',
        dateOfBirth: '1990-01-01',
        emergencyPhone: '0900000000',
        vehicleType: extraData['vehicleType'] as VehicleType? ?? VehicleType.motorcycle,
        vehiclePlate: extraData['licensePlate'] as String?,
        status: CourierStatus.offline,
        currentLat: 15.5006, // default mock lat
        currentLng: 32.5599, // default mock lng
        rating: 5.0,
        totalDeliveries: 0,
        todayEarnings: 0.0,
      );
      _couriers.add(newCourier);
    } else if (user.role == UserRole.merchant && extraData != null) {
      final newStore = StoreModel(
        id: MockData.uuid.v4(),
        ownerId: user.id,
        name: extraData['businessName'] as String? ?? 'New Store',
        type: extraData['storeType'] as StoreType? ?? StoreType.restaurant,
        area: extraData['businessArea'] as String? ?? 'الخرطوم',
        street: 'شارع النيل',
        landmark: 'بالقرب من المستشفى',
        phone: user.phone,
        rating: 0.0,
        deliveryFee: 1000.0,
        openingTime: '08:00 AM',
        closingTime: '11:00 PM',
        preparationTime: '30 دقيقة',
        minimumOrder: 2000.0,
        latitude: 15.5006,
        longitude: 32.5599,
        logo: extraData['logoPath'],
      );
      _stores.add(newStore);
    }
    _saveData(); notifyListeners();
  }

  // Global order placement
  OrderModel placeOrder({
    required String customerId,
    required String storeId,
    required List<CartItem> cartItems,
    required AddressModel address,
    required double customerLat,
    required double customerLng,
    required double storeLat,
    required double storeLng,
    required double subtotal,
    required double deliveryFee,
    required double serviceFee,
    required double discount,
    required double total,
    required PaymentMethod paymentMethod,
    required PaymentStatus paymentStatus,
  }) {
    final newOrder = OrderModel(
      id: MockData.uuid.v4(),
      customerId: customerId,
      storeId: storeId,
      items: List.from(cartItems),
      address: address,
      customerLat: customerLat,
      customerLng: customerLng,
      storeLat: storeLat,
      storeLng: storeLng,
      status: OrderStatus.pending,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      discount: discount,
      total: total,
      createdAt: DateTime.now(),
    );
    _orders.add(newOrder);
    _firestore.saveOrder(newOrder);
    _saveData(); // FIX: persist new order to local cache immediately
    notifyListeners();
    
    // Notify Merchant
    _notifyUser('طلب جديد 📦', 'لديك طلب جديد بقيمة ${newOrder.total} ج.س');
    return newOrder;
  }

  // Merchant actions
  void acceptOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].updateStatus(OrderStatus.acceptedByMerchant, 'Merchant', note: 'Merchant accepted the order');
      
      // Deduct inventory
      for (var item in _orders[index].items) {
        final prodIndex = _products.indexWhere((p) => p.id == item.product.id);
        if (prodIndex != -1 && _products[prodIndex].stockQuantity >= item.quantity) {
          final p = _products[prodIndex];
          _products[prodIndex] = p.copyWith(stockQuantity: p.stockQuantity - item.quantity);
          if (_products[prodIndex].stockQuantity == 0) {
            _products[prodIndex] = _products[prodIndex].copyWith(isAvailable: false);
          }
        }
      }

      _firestore.saveOrder(_orders[index]);
      _saveData(); notifyListeners();
    }
  }

  void startPreparingOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == OrderStatus.acceptedByMerchant) {
      _orders[index].updateStatus(OrderStatus.preparing, 'Merchant', note: 'بدأ المطعم في تجهيز الطلب');
      _firestore.saveOrder(_orders[index]);
      _saveData(); // FIX: cache status change locally
      notifyListeners();
    }
  }

  void markOrderReady(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == OrderStatus.preparing) {
      _orders[index].updateStatus(OrderStatus.readyForPickup, 'Merchant', note: 'الطلب جاهز للاستلام من المطعم');
      
      // Immediately move to searching for courier
      _orders[index].updateStatus(OrderStatus.searchingCourier, 'System', note: 'جاري البحث عن أقرب مندوب');
      _firestore.saveOrder(_orders[index]);
      _saveData(); // FIX: cache dual-status transition locally
      notifyListeners();
    }
  }

  void rejectOrder(String orderId, String reason) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].updateStatus(OrderStatus.rejectedByMerchant, 'Merchant', note: reason);
      _firestore.saveOrder(_orders[index]);
      _saveData(); // FIX: persist rejection status to local cache
      notifyListeners();
    }
  }

  void courierAcceptOrder(String orderId, String courierId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && (_orders[index].status == OrderStatus.searchingCourier || _orders[index].status == OrderStatus.readyForPickup)) {
      _orders[index].courierId = courierId;
      _orders[index].updateStatus(OrderStatus.assignedToCourier, 'Courier', note: 'تم قبول الطلب من المندوب');
      
      final courierIndex = _couriers.indexWhere((c) => c.userId == courierId);
      if (courierIndex != -1) {
        _couriers[courierIndex].status = CourierStatus.busy;
      }
      
      _notifyUser('مندوب التوصيل في الطريق', 'تم تعيين مندوب لطلبك وهو في طريقه للمطعم.');
      _firestore.saveOrder(_orders[index]);
      _saveData();
      notifyListeners();
    }
  }

  void courierUpdateLocation(String orderId, double lat, double lng) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].courierLat = lat;
      _orders[index].courierLng = lng;
      _firestore.saveOrder(_orders[index]);
      notifyListeners();
    }
  }

  // Courier actions
  void _notifyUser(String title, String body) {
    try {
      final context = AppRouter.rootNavigatorKey.currentContext;
      if (context != null) {
        Provider.of<NotificationProvider>(context, listen: false).showNotification(title: title, body: body);
      }
    } catch (e) {
      debugPrint('Could not show notification: $e');
    }
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus, String note) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].updateStatus(newStatus, 'System', note: note);
      
      bool courierStatusChanged = false;
      // If delivered, free the courier
      if (newStatus == OrderStatus.delivered) {
        if (_orders[index].paymentMethod == PaymentMethod.cashOnDelivery) {
          _orders[index].paymentStatus = PaymentStatus.paid;
        }
        final courierId = _orders[index].courierId;
        if (courierId != null) {
          final courierIndex = _couriers.indexWhere((c) => c.userId == courierId);
          if (courierIndex != -1) {
            _couriers[courierIndex].status = CourierStatus.available;
            courierStatusChanged = true;
          }
        }
      }
      
      // Send notification depending on status
      switch (newStatus) {
        case OrderStatus.preparing:
          _notifyUser('جاري تجهيز الطلب', 'المطعم بدأ في تحضير طلبك #${orderId.length >= 6 ? orderId.substring(0,6) : orderId}');
          break;
        case OrderStatus.readyForPickup:
          _notifyUser('الطلب جاهز!', 'طلبك جاهز في المطعم، ونبحث عن مندوب حالياً.');
          break;
        case OrderStatus.pickedUp:
          _notifyUser('المندوب استلم الطلب', 'طلبك الآن مع المندوب وفي طريقه إليك.');
          break;
        case OrderStatus.onTheWay:
          _notifyUser('الطلب في الطريق 🚀', 'المندوب متوجه إليك الآن!');
          break;
        case OrderStatus.delivered:
          _notifyUser('تم التوصيل 🎉', 'بالهناء والشفاء! نتمنى لك تجربة ممتعة.');
          break;
        default:
          _notifyUser('تحديث الطلب', note);
      }
      
      _firestore.saveOrder(_orders[index]);
      if (courierStatusChanged) {
        _saveData();
      }
      notifyListeners();
    }
  }

  // Queries
  List<OrderModel> getOrdersForCustomer(String customerId) {
    return _orders.where((o) => o.customerId == customerId).toList();
  }

  List<OrderModel> getOrdersForMerchant(String merchantId) {
    final storeIds = _stores.where((s) => s.ownerId == merchantId).map((s) => s.id).toList();
    return _orders.where((o) => storeIds.contains(o.storeId)).toList();
  }

  List<OrderModel> getAvailableOrdersForCourier() {
    return _orders.where((o) => o.status == OrderStatus.readyForPickup || o.status == OrderStatus.searchingCourier).toList();
  }

  List<OrderModel> getOrdersForCourier(String courierId) {
    return _orders.where((o) => o.courierId == courierId).toList();
  }

  Future<void> rateStore(String storeId, double newRating) async {
    final index = _stores.indexWhere((s) => s.id == storeId);
    if (index != -1) {
      final store = _stores[index];
      
      // Calculate new average rating
      final currentRating = store.rating;
      final currentCount = store.ratingCount;
      
      final updatedCount = currentCount + 1;
      final updatedRating = ((currentRating * currentCount) + newRating) / updatedCount;
      
      final updatedStore = StoreModel(
        id: store.id,
        ownerId: store.ownerId,
        name: store.name,
        type: store.type,
        logo: store.logo,
        coverImage: store.coverImage,
        phone: store.phone,
        area: store.area,
        street: store.street,
        landmark: store.landmark,
        latitude: store.latitude,
        longitude: store.longitude,
        openingTime: store.openingTime,
        closingTime: store.closingTime,
        preparationTime: store.preparationTime,
        minimumOrder: store.minimumOrder,
        deliveryFee: store.deliveryFee,
        status: store.status,
        rating: updatedRating,
        ratingCount: updatedCount,
      );
      
      _stores[index] = updatedStore;
      await _firestore.saveStore(updatedStore);
      if (_isDisposed) return;
      await _saveData();
      if (_isDisposed) return;
      notifyListeners();
    }
  }
}
