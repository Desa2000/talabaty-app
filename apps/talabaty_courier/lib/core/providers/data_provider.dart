import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/store_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/user_model.dart';
import '../../data/mock/data_mapper.dart';
import '../../data/services/store_api_service.dart';
import '../../data/services/order_api_service.dart';
import '../../data/services/address_api_service.dart';
import '../../data/services/courier_api_service.dart';
import '../../core/services/socket_service.dart';
import '../../core/constants/enums.dart';

class DataProvider extends ChangeNotifier {
  final StoreApiService _storeApiService = StoreApiService();
  final OrderApiService _orderApiService = OrderApiService();
  final AddressApiService _addressApiService = AddressApiService();
  final CourierApiService _courierApiService = CourierApiService();
  final SocketService _socketService = SocketService();

  // Courier live-location listeners: orderId → callback
  final Map<String, Function(double lat, double lng, double heading)>
  _courierLocationListeners = {};

  List<StoreModel> _stores = [];
  List<ProductModel> _products = [];
  List<OrderModel> _orders = [];
  List<AddressModel> _addresses = [];
  List<CourierProfile> _couriers = [];
  List<UserModel> _users = [];

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool _isLoadingStores = false;
  bool get isLoadingStores => _isLoadingStores;
  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;
  String? _ordersError;
  String? get ordersError => _ordersError;
  bool _isDisposed = false;

  DataProvider() {
    _initData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _socketService.offAllListeners();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> _initData() async {
    // 1. Initialize local cache fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;

      final storesData = prefs.getString('stores');
      if (storesData != null && storesData.isNotEmpty) {
        _stores = DataMapper.decodeStores(storesData);
      }
    } catch (_) {
      _stores = [];
    }

    notifyListeners();

    // 2. Fetch real stores and real orders from Backend REST API
    await fetchRealStores();
    await fetchRealOrders();

    // 3. Connect Socket.IO for real-time order status and location tracking
    try {
      await _socketService.connect();
      _socketService.onOrderStatusUpdate((data) {
        debugPrint('⚡ Real-time Order Status Update via Socket: $data');
        fetchRealOrders();
      });
      _socketService.onOrderCreated((data) {
        debugPrint('⚡ Real-time Order Created via Socket: $data');
        fetchRealOrders();
      });

      _socketService.onCourierOfferReceived((data) {
        debugPrint(
          '🚚 Targeted courier offer received via Socket: ${data['id']}',
        );

        // REST remains authoritative. Refresh so the offer shown in
        // the UI is exactly the currently-live server-side offer.
        fetchRealOrders();
      });
    } catch (e) {
      debugPrint('Socket setup note: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> fetchRealStores({
    String? category,
    double? lat,
    double? lng,
    String? q,
  }) async {
    _isLoadingStores = true;
    notifyListeners();

    try {
      final fetched = await _storeApiService.fetchStores(
        category: category,
        lat: lat,
        lng: lng,
        q: q,
      );
      if (_isDisposed) return;
      if (fetched.isNotEmpty) {
        _stores = fetched;
        await _saveData();
      }
    } catch (e) {
      debugPrint('Error fetching real stores from REST API: $e');
    } finally {
      if (!_isDisposed) {
        _isLoadingStores = false;
        notifyListeners();
      }
    }
  }

  Future<StoreModel?> fetchStoreDetails(String storeId) async {
    try {
      final res = await _storeApiService.fetchStoreDetails(storeId);
      final store = res['store'] as StoreModel;
      final products = res['products'] as List<ProductModel>;

      final storeIdx = _stores.indexWhere((s) => s.id == storeId);
      if (storeIdx != -1) {
        _stores[storeIdx] = store;
      } else {
        _stores.add(store);
      }

      // Update cached products for this store
      _products.removeWhere((p) => p.storeId == storeId);
      _products.addAll(products);

      notifyListeners();
      return store;
    } catch (e) {
      debugPrint('Error fetching store details from REST API: $e');
      for (final store in _stores) {
        if (store.id == storeId) return store;
      }
      return null;
    }
  }

  Future<void> fetchRealOrders() async {
    _isLoadingOrders = true;
    _ordersError = null;
    notifyListeners();

    try {
      final rawOrders = await _orderApiService.getMyOrders();
      if (_isDisposed) return;

      final List<OrderModel> parsed = [];
      for (var json in rawOrders) {
        try {
          final itemsJson = json['items'] as List? ?? [];
          final items = itemsJson.map((i) {
            final p = ProductModel(
              id: i['productId'] ?? '',
              storeId: json['storeId'] ?? '',
              name: i['productName'] ?? '',
              description: '',
              price: (i['unitPrice'] as num?)?.toDouble() ?? 0.0,
              image: 'assets/images/placeholder_product.png',
              category: 'أخرى',
            );
            return CartItem(product: p, quantity: i['quantity'] ?? 1);
          }).toList();

          final statusStr = json['status']?.toString().toUpperCase();
          OrderStatus statusVal = OrderStatus.pending;
          if (statusStr == 'MERCHANT_ACCEPTED')
            statusVal = OrderStatus.acceptedByMerchant;
          if (statusStr == 'MERCHANT_REJECTED')
            statusVal = OrderStatus.rejectedByMerchant;
          if (statusStr == 'PREPARING') statusVal = OrderStatus.preparing;
          if (statusStr == 'READY_FOR_PICKUP')
            statusVal = OrderStatus.readyForPickup;
          if (statusStr == 'SEARCHING_COURIER')
            statusVal = OrderStatus.searchingCourier;
          if (statusStr == 'COURIER_ASSIGNED' ||
              statusStr == 'COURIER_ACCEPTED')
            statusVal = OrderStatus.assignedToCourier;
          if (statusStr == 'PICKED_UP') statusVal = OrderStatus.pickedUp;
          if (statusStr == 'ON_THE_WAY') statusVal = OrderStatus.onTheWay;
          if (statusStr == 'ARRIVED')
            statusVal = OrderStatus.courierArrivedCustomer;
          if (statusStr == 'DELIVERED' || statusStr == 'COMPLETED')
            statusVal = OrderStatus.delivered;
          if (statusStr == 'CUSTOMER_CANCELLED' ||
              statusStr == 'COURIER_CANCELLED')
            statusVal = OrderStatus.cancelled;

          final address = AddressModel(
            id: json['id'] ?? '',
            label: 'عنوان التوصيل',
            area: json['deliveryAddress'] ?? 'الخرطوم',
            street: json['deliveryAddress'] ?? '',
            landmark: '',
            latitude: (json['deliveryLatitude'] as num?)?.toDouble() ?? 15.5640,
            longitude:
                (json['deliveryLongitude'] as num?)?.toDouble() ?? 32.5840,
            phone: json['customer']?['phone'] ?? '0912345678',
          );

          final order = OrderModel(
            id: json['id'] ?? '',
            orderNumber: json['orderNumber'] ?? '',
            customerId: json['customerId'] ?? '',
            storeId: json['storeId'] ?? '',
            courierId: json['courierId'],
            items: items,
            address: address,
            customerLat:
                (json['deliveryLatitude'] as num?)?.toDouble() ?? 15.5640,
            customerLng:
                (json['deliveryLongitude'] as num?)?.toDouble() ?? 32.5840,
            storeLat:
                (json['store']?['latitude'] as num?)?.toDouble() ?? 15.5640,
            storeLng:
                (json['store']?['longitude'] as num?)?.toDouble() ?? 32.5840,
            status: statusVal,
            paymentMethod: json['paymentMethod'] == 'BANKAK'
                ? PaymentMethod.bankak
                : PaymentMethod.cashOnDelivery,
            paymentStatus: json['paymentStatus'] == 'PAID'
                ? PaymentStatus.paid
                : PaymentStatus.unpaid,
            subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
            deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 500.0,
            serviceFee: 0.0,
            discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
            total: (json['total'] as num?)?.toDouble() ?? 0.0,
            createdAt: json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
            dispatchOfferId:
                json['dispatchOfferId']?.toString(),
            offerRank: json['offerRank'] is num
                ? (json['offerRank'] as num).toInt()
                : null,
            offerExpiresAt:
                json['offerExpiresAt'] != null
                    ? DateTime.tryParse(
                        json['offerExpiresAt'].toString(),
                      )
                    : null,
            isTargetedOffer:
                json['_targeted'] == true,
          );
          parsed.add(order);
        } catch (e) {
          debugPrint('Error parsing order json: $e');
        }
      }

      _orders = parsed;
      _ordersError = null;
    } catch (e) {
      debugPrint('Error fetching real orders: $e');
      _ordersError = e.toString();
    } finally {
      if (!_isDisposed) {
        _isLoadingOrders = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchAddresses() async {
    try {
      final fetched = await _addressApiService.getAddresses();
      if (_isDisposed) return;
      _addresses = fetched;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    }
  }

  Future<AddressModel?> addAddress({
    required String title,
    required String area,
    required String street,
    String? landmark,
    required double latitude,
    required double longitude,
    required String phone,
  }) async {
    try {
      final addr = await _addressApiService.createAddress(
        title: title,
        area: area,
        street: street,
        landmark: landmark,
        latitude: latitude,
        longitude: longitude,
        phone: phone,
      );
      _addresses.insert(0, addr);
      notifyListeners();
      return addr;
    } catch (e) {
      debugPrint('Error adding address: $e');
      return null;
    }
  }

  Future<void> _saveData() async {
    if (_isDisposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      await prefs.setString('stores', DataMapper.encodeStores(_stores));
    } catch (e) {
      debugPrint('Error caching stores: $e');
    }
  }

  List<StoreModel> get stores => _stores;
  List<ProductModel> get products => _products;
  List<OrderModel> get orders => _orders;
  List<AddressModel> get addresses => _addresses;
  List<CourierProfile> get couriers => _couriers;
  List<UserModel> get users => _users;

  // Merchant actions via REST API
  Future<void> acceptOrder(String orderId) async {
    try {
      await _orderApiService.merchantAcceptOrder(orderId);
      await fetchRealOrders();
    } catch (e) {
      debugPrint('Error accepting order: $e');
    }
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    try {
      await _orderApiService.merchantRejectOrder(orderId, reason);
      await fetchRealOrders();
    } catch (e) {
      debugPrint('Error rejecting order: $e');
    }
  }

  Future<void> startPreparingOrder(String orderId) async {
    try {
      await _orderApiService.merchantStartPreparing(orderId);
      await fetchRealOrders();
    } catch (e) {
      debugPrint('Error preparing order: $e');
    }
  }

  Future<void> markOrderReady(String orderId) async {
    try {
      await _orderApiService.merchantReadyForPickup(orderId);
      await fetchRealOrders();
    } catch (e) {
      debugPrint('Error marking order ready: $e');
    }
  }

  // Courier actions via REST API
  Future<void> courierAcceptOrder(String orderId, String courierId) async {
    try {
      await _orderApiService.courierAcceptOrder(orderId);
      await fetchRealOrders();
    } catch (e) {
      debugPrint('Error courier accept order: $e');
      rethrow;
    }
  }

  Future<void> courierRejectOffer(String orderId) async {
    try {
      await _orderApiService.courierRejectOffer(orderId);
      await fetchRealOrders();
    } catch (e) {
      debugPrint('Error courier reject offer: $e');
      rethrow;
    }
  }

  /// Generic order status update — accepts either [OrderStatus] or a raw String.
  Future<void> updateOrderStatus(
    String orderId,
    dynamic newStatus, [
    String note = '',
  ]) async {
    try {
      final s = newStatus is OrderStatus
          ? newStatus
          : OrderStatus.values.firstWhere(
              (e) =>
                  e.name.toLowerCase() ==
                  newStatus.toString().toLowerCase().replaceAll('_', ''),
              orElse: () => OrderStatus.pending,
            );
      if (s == OrderStatus.pickedUp) {
        await _orderApiService.courierPickupOrder(orderId);
      } else if (s == OrderStatus.onTheWay) {
        await _orderApiService.courierOnTheWay(orderId);
      } else if (s == OrderStatus.courierArrivedCustomer) {
        await _orderApiService.courierArrived(orderId);
      } else if (s == OrderStatus.delivered) {
        await _orderApiService.courierDelivered(orderId);
      }
      await fetchRealOrders();
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  void courierUpdateLocation(
    String orderId,
    double lat,
    double lng, {
    double heading = 0,
  }) {
    _socketService.emitLocation(orderId, lat, lng);
    _courierApiService.updateLocation(
      latitude: lat,
      longitude: lng,
      orderId: orderId,
    );
  }

  // ─── Courier location listener registry (for tracking screens) ─────────
  void addCourierLocationListener(
    String orderId,
    Function(double lat, double lng, double heading) callback,
  ) {
    _courierLocationListeners[orderId] = callback;
    _socketService.onCourierLocation(orderId, callback);
  }

  void removeCourierLocationListener(String orderId) {
    _courierLocationListeners.remove(orderId);
    _socketService.offCourierLocation(orderId);
  }

  List<OrderModel> getOrdersForCustomer(String customerId) {
    return _orders.where((o) => o.customerId == customerId).toList();
  }

  List<OrderModel> getOrdersForMerchant(String merchantId) {
    return _orders;
  }

  List<OrderModel> getAvailableOrdersForCourier() {
    return _orders
        .where(
          (o) =>
              o.status == OrderStatus.searchingCourier &&
              o.hasLiveDispatchOffer,
        )
        .toList();
  }

  List<OrderModel> getOrdersForCourier(String courierId) {
    if (courierId.isEmpty) return [];
    return _orders.where((o) => o.courierId == courierId).toList();
  }

  Future<void> rateOrder({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    await _orderApiService.rateOrder(
      orderId: orderId,
      rating: rating,
      comment: comment,
    );
    await fetchRealOrders();
    await fetchRealStores();
  }

  Future<void> rateStore({
    required String storeId,
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    await rateOrder(orderId: orderId, rating: rating, comment: comment);
  }
}
