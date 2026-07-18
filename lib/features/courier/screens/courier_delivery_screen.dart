import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/delivery_fee_service.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/store_model.dart';

class CourierDeliveryScreen extends StatefulWidget {
  final String orderId;
  const CourierDeliveryScreen({super.key, required this.orderId});

  @override
  State<CourierDeliveryScreen> createState() => _CourierDeliveryScreenState();
}

class _CourierDeliveryScreenState extends State<CourierDeliveryScreen> {
  final MapController _mapController = MapController();
  LatLng? _courierCurrentPosition;
  double _distanceToTargetKm = 0.0;
  bool _isNearCustomer = false;
  StreamSubscription<Position>? _positionStreamSub;
  bool _isFirstLocationUpdate = true;
  
  // Phase 1 = Go to store, Phase 2 = Go to customer
  int _deliveryPhase = 1;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      // Get initial position
      final initialPos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _courierCurrentPosition = LatLng(initialPos.latitude, initialPos.longitude);
          _recalculateDistance();
          _isFirstLocationUpdate = false;
          _mapController.move(_courierCurrentPosition!, 15.0);
        });
      }

      // Start position stream
      _positionStreamSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // update every 10 meters
        ),
      ).listen((Position pos) {
        if (mounted) {
          setState(() {
            _courierCurrentPosition = LatLng(pos.latitude, pos.longitude);
            _recalculateDistance();
            
            // Periodically emit position updates to backend provider
            final dp = context.read<DataProvider>();
            dp.courierUpdateLocation(widget.orderId, pos.latitude, pos.longitude);

            if (_isFirstLocationUpdate) {
              _isFirstLocationUpdate = false;
              _mapController.move(_courierCurrentPosition!, 15.0);
            }
          });
        }
      });
    } catch (_) {}
  }

  void _recalculateDistance() {
    if (_courierCurrentPosition == null) return;
    
    final dp = context.read<DataProvider>();
    final order = dp.orders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => dp.orders.isNotEmpty
          ? dp.orders.first
          : OrderModel(
              id: widget.orderId,
              customerId: '',
              storeId: '',
              items: [],
              subtotal: 0,
              deliveryFee: 0,
              serviceFee: 0,
              total: 0,
              status: OrderStatus.pending,
              createdAt: DateTime.now(),
              address: AddressModel(id: 'mock', title: 'mock', city: '', area: '', street: '', landmark: '', latitude: 0, longitude: 0, phone: ''),
              customerLat: 15.5007,
              customerLng: 32.5599,
              storeLat: 15.5007,
              storeLng: 32.5599,
              paymentMethod: PaymentMethod.cashOnDelivery,
              paymentStatus: PaymentStatus.unpaid,
            ),
    );

    if (_deliveryPhase == 1) {
      // Distance to store
      _distanceToTargetKm = DeliveryFeeService.distanceKm(
        _courierCurrentPosition!.latitude,
        _courierCurrentPosition!.longitude,
        order.storeLat,
        order.storeLng,
      );
      _isNearCustomer = false;
    } else {
      // Distance to customer
      _distanceToTargetKm = DeliveryFeeService.distanceKm(
        _courierCurrentPosition!.latitude,
        _courierCurrentPosition!.longitude,
        order.customerLat,
        order.customerLng,
      );
      // If courier is less than 0.2 km (200m) from customer
      _isNearCustomer = _distanceToTargetKm < 0.2;
    }
  }

  Future<void> _completeDelivery(DataProvider dp, OrderModel order, String courierId) async {
    // 1. Update order status in Firebase/Local provider
    dp.updateOrderStatus(order.id, OrderStatus.delivered, 'تم توصيل الطلب بنجاح للعميل');

    // 2. Add delivery fee to courier wallet in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final walletKey = 'wallet_$courierId';
    double currentBalance = prefs.getDouble(walletKey) ?? 0.0;
    
    // Add delivery fee of this order
    double newBalance = currentBalance + order.deliveryFee;
    await prefs.setDouble(walletKey, newBalance);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إكمال التوصيل! أضيف ${order.deliveryFee.toStringAsFixed(0)} ج.س لمحفظتك 💰',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dataProvider = context.watch<DataProvider>();
    final courierId = auth.currentUser?.id ?? '';

    final order = dataProvider.orders.firstWhere(
      (o) => o.id == widget.orderId,
      orElse: () => dataProvider.orders.isNotEmpty
          ? dataProvider.orders.first
          : OrderModel(
              id: widget.orderId,
              customerId: '',
              storeId: '',
              items: [],
              subtotal: 0,
              deliveryFee: 0,
              serviceFee: 0,
              total: 0,
              status: OrderStatus.pending,
              createdAt: DateTime.now(),
              address: AddressModel(id: 'mock', title: 'mock', city: '', area: '', street: '', landmark: '', latitude: 0, longitude: 0, phone: ''),
              customerLat: 15.5007,
              customerLng: 32.5599,
              storeLat: 15.5007,
              storeLng: 32.5599,
              paymentMethod: PaymentMethod.cashOnDelivery,
              paymentStatus: PaymentStatus.unpaid,
            ),
    );

    final store = dataProvider.stores.firstWhere(
      (s) => s.id == order.storeId,
      orElse: () => dataProvider.stores.isNotEmpty
          ? dataProvider.stores.first
          : StoreModel(
              id: 'dummy',
              ownerId: '',
              name: 'المطعم',
              type: StoreType.restaurant,
              phone: '',
              area: '',
              street: '',
              landmark: '',
              latitude: 15.5007,
              longitude: 32.5599,
              openingTime: '08:00',
              closingTime: '23:00',
              preparationTime: '20',
              minimumOrder: 1000,
              deliveryFee: 3000,
              status: 'active',
              rating: 5.0,
              ratingCount: 1,
            ),
    );

    final storeLatLng = LatLng(order.storeLat, order.storeLng);
    final customerLatLng = LatLng(order.customerLat, order.customerLng);

    // Dynamic phase tracking depending on actual order status if loading from history
    if (order.status == OrderStatus.pickedUp ||
        order.status == OrderStatus.onTheWay ||
        order.status == OrderStatus.courierArrivedCustomer) {
      _deliveryPhase = 2;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Stack(
          children: [
            // ===== MAP VIEW =====
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: storeLatLng,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.talabaty_app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [storeLatLng, customerLatLng],
                      color: AppColors.primaryColor.withValues(alpha: 0.5),
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Store marker
                    Marker(
                      point: storeLatLng,
                      width: 50,
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.storefront_rounded, color: Colors.orange, size: 30),
                          Icon(Icons.location_on, color: Colors.orange, size: 20),
                        ],
                      ),
                    ),
                    // Customer marker
                    Marker(
                      point: customerLatLng,
                      width: 50,
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(Icons.person_pin_circle_rounded, color: Colors.blue, size: 30),
                          Icon(Icons.location_on, color: Colors.blue, size: 20),
                        ],
                      ),
                    ),
                    // Courier live location marker
                    if (_courierCurrentPosition != null)
                      Marker(
                        point: _courierCurrentPosition!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // ===== TOP STATUS BAR OVERLAY =====
            Positioned(
              top: 48,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D27),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _deliveryPhase == 1 ? 'المرحلة الأولى: التوجه للمطعم' : 'المرحلة الثانية: التوجه للعميل',
                          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _deliveryPhase == 1 ? 'استلم الطلب من ${store.name}' : 'توصيل الطلب للعميل',
                          style: GoogleFonts.cairo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryColor, width: 1.5),
                      ),
                      child: Text(
                        _courierCurrentPosition != null
                            ? '${_distanceToTargetKm.toStringAsFixed(2)} كم متبقي'
                            : 'جاري التحديد...',
                        style: GoogleFonts.cairo(color: AppColors.primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== BOTTOM ACTION SHEET =====
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, -5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تفاصيل التوصيل',
                          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF111111)),
                        ),
                        Text(
                          'أجرة التوصيل: ${order.deliveryFee.toStringAsFixed(0)} ج.س',
                          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Customer & Address Info
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.08), shape: BoxShape.circle),
                          child: const Icon(Icons.storefront_rounded, color: Colors.orange),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('المطعم', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
                              Text(store.name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.08), shape: BoxShape.circle),
                          child: const Icon(Icons.person_pin_circle_rounded, color: Colors.blue),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('العميل وموقع التوصيل', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
                              Text(order.address.street, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Phase Actions
                    if (_deliveryPhase == 1) ...[
                      // Phase 1 Actions
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            dataProvider.updateOrderStatus(
                              order.id,
                              OrderStatus.pickedUp,
                              'تم استلام الطلب من المتجر وبدء التوصيل للعميل',
                            );
                            setState(() {
                              _deliveryPhase = 2;
                              _recalculateDistance();
                            });
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                          label: Text(
                            'تم استلام الطلب من التاجر',
                            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Phase 2 Actions: Allow delivered only if within 200m proximity
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isNearCustomer ? Colors.green : Colors.grey.shade400,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: _isNearCustomer 
                              ? () => _completeDelivery(dataProvider, order, courierId) 
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'يجب أن تكون على بعد أقل من 200 متر من موقع العميل لإتمام التوصيل. المسافة الحالية: ${(_distanceToTargetKm * 1000).toStringAsFixed(0)} متر.',
                                        style: const TextStyle(fontFamily: 'Cairo'),
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                          label: Text(
                            'تم التوصيل وتسليم الطلب ✅',
                            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      if (!_isNearCustomer)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: Text(
                              'يبدو أنك لم تصل بعد لموقع العميل لتأكيد التوصيل',
                              style: GoogleFonts.cairo(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ]
                  ],
                ),
              ),
            ),
            // ===== RECENTER BUTTON =====
            if (_courierCurrentPosition != null)
              Positioned(
                bottom: 280,
                left: 16,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onPressed: () {
                    if (_courierCurrentPosition != null) {
                      _mapController.move(_courierCurrentPosition!, 15.0);
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
