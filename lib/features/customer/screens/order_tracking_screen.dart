import 'package:talabaty_app/core/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:talabaty_app/core/constants/app_colors.dart';
import 'package:talabaty_app/core/constants/enums.dart';
import 'package:talabaty_app/core/providers/data_provider.dart';
import 'package:talabaty_app/core/services/routing_service.dart';
import 'package:talabaty_app/data/models/user_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final MapController _mapController = MapController();
  final RoutingService _routingService = RoutingService();
  
  List<LatLng> _routePoints = [];
  double _distanceInMeters = 0.0;
  double _durationInSeconds = 0.0;
  bool _isLoadingRoute = true;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
    
    // Simulate live tracking updates
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _fetchRoute();
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRoute() async {
    // Guard: the Timer may fire after dispose(); bail early if unmounted.
    if (!mounted) return;
    final dataProvider = context.read<DataProvider>();
    final order = dataProvider.orders.where((o) => o.id == widget.orderId).firstOrNull
        ?? (dataProvider.orders.isNotEmpty ? dataProvider.orders.first : null);
    if (order == null) return; // Orders not loaded yet; skip route fetch
    
    LatLng startPoint = LatLng(order.storeLat, order.storeLng);
    if (order.courierLat != null && order.courierLng != null) {
      startPoint = LatLng(order.courierLat!, order.courierLng!);
    }
    
    final endPoint = LatLng(order.customerLat, order.customerLng);
    final result = await _routingService.getRoute(startPoint, endPoint);
    
    if (mounted) {
      setState(() {
        if (result != null) {
          _routePoints = result.points;
          _distanceInMeters = result.distanceInMeters;
          _durationInSeconds = result.durationInSeconds;
        } else {
          _routePoints = [startPoint, endPoint];
        }
        _isLoadingRoute = false;
      });
      _fitMapBounds(startPoint, endPoint);
    }
  }

  void _fitMapBounds(LatLng start, LatLng end) {
    try {
      final bounds = LatLngBounds.fromPoints([start, end]);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.only(top: 80, bottom: 80, left: 50, right: 50),
        )
      );
    } catch (e) {
      // Map not fully initialized
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    // Safe fallbacks: .first on an empty list throws StateError
    final order = dataProvider.orders.where((o) => o.id == widget.orderId).firstOrNull
        ?? (dataProvider.orders.isNotEmpty ? dataProvider.orders.first : null);
    if (order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final store = dataProvider.stores.where((s) => s.id == order.storeId).firstOrNull
        ?? (dataProvider.stores.isNotEmpty ? dataProvider.stores.first : null);
    if (store == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    LatLng currentLoc = LatLng(order.storeLat, order.storeLng);
    if (order.courierLat != null && order.courierLng != null) {
      currentLoc = LatLng(order.courierLat!, order.courierLng!);
    }
    final customerLoc = LatLng(order.customerLat, order.customerLng);

    int etaMinutes = (_durationInSeconds / 60).ceil();
    if (etaMinutes == 0 && order.status != OrderStatus.delivered) etaMinutes = 5;

    // Premium visual status label
    String statusText = 'في الطريق';
    if (order.status == OrderStatus.delivered) {
      statusText = 'تم التوصيل';
    } else if (order.status == OrderStatus.preparing) {
      statusText = 'جاري التحضير';
    } else if (order.status == OrderStatus.readyForPickup) {
      statusText = 'جاهز للاستلام';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFF5A00), // Vibrant Brand Orange
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header Title Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 26,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Cairo',
                        ),
                        children: [
                          TextSpan(text: 'تتبع طلبك\n', style: TextStyle(color: Colors.white)), 
                          TextSpan(text: 'من البداية حتى الاستلام', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // 2. Map Container
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      child: Stack(
                        children: [
                          // The actual map widget
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: currentLoc,
                              initialZoom: 14.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                subdomains: const ['a', 'b', 'c', 'd'],
                                userAgentPackageName: 'com.talabaty.app',
                              ),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: _routePoints,
                                    color: Colors.black87,
                                    strokeWidth: 4,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  // Customer Home Pin (Orange pin dropped from black label)
                                  Marker(
                                    point: customerLoc,
                                    width: 100,
                                    height: 70,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Positioned(
                                          bottom: 4,
                                          child: Icon(Icons.location_on, color: Color(0xFFFF5A00), size: 36),
                                        ),
                                        Positioned(
                                          top: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.home, color: Colors.white, size: 22),
                                                Text('المنزل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Cairo')),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Courier / Delivery Blue Dot Marker
                                  Marker(
                                    point: currentLoc,
                                    width: 40,
                                    height: 40,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor, 
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          // Floating Close Icon inside Map Area
                          Positioned(
                            top: 16,
                            left: 16,
                            child: GestureDetector(
                              onTap: () => context.go('/customer'),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Icon(Icons.close, color: Colors.black, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // 3. Floating Bottom Info Card
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Restaurant Detail & Delivery Time Section
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CustomImage(
                                  imagePath: store.logo ?? '', 
                                  fit: BoxFit.cover,
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  store.name,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusText,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الوقت المقدر للوصول',
                                    style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$etaMinutes دقائق',
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Cairo'),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'طلباتي',
                                    style: TextStyle(color: Color(0xFFFF5A00), fontWeight: FontWeight.w900, fontSize: 19, fontFamily: 'Cairo'),
                                  ),
                                ],
                              ),
                              
                              // Orange circular progress with motorcycle icon
                              SizedBox(
                                width: 68,
                                height: 68,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: order.status == OrderStatus.delivered ? 1.0 : 0.75,
                                      strokeWidth: 4.5,
                                      backgroundColor: Colors.grey.shade100,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5A00)),
                                    ),
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFF0E5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.motorcycle,
                                        color: Color(0xFFFF5A00),
                                        size: 26,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Cream banner with thumb-up & delivery message
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade100),
                          bottom: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.thumb_up, color: Color(0xFFFF5A00), size: 18),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "طلبك في طريقه إليك الآن، سنعلمك عند وصوله! 🛵",
                              style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Delivery Agent Profile Section
                    Builder(
                      builder: (context) {
                        // Fallback to mock delivery hero if no courier assigned to the order yet
                        if (dataProvider.couriers.isEmpty) return const SizedBox.shrink();
                        final courier = dataProvider.couriers.firstWhere(
                          (c) => c.userId == order.courierId,
                          orElse: () => dataProvider.couriers.first, // safe: list confirmed non-empty
                        );
                        final courierUser = dataProvider.users.firstWhere(
                          (u) => u.id == courier.userId,
                          orElse: () => dataProvider.users.firstWhere(
                            (u) => u.role == UserRole.courier,
                            orElse: () => dataProvider.users.isNotEmpty 
                                ? dataProvider.users.first 
                                : UserModel(
                                    id: courier.userId,
                                    name: 'سائق التوصيل',
                                    phone: '',
                                    password: '',
                                    role: UserRole.courier,
                                    createdAt: DateTime.now(),
                                  ),
                          ),
                        );
                        
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0E5),
                                  shape: BoxShape.circle,
                                  image: courierUser.profileImage != null
                                      ? DecorationImage(
                                          image: NetworkImage(courierUser.profileImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: courierUser.profileImage == null
                                    ? const Icon(Icons.person, color: Color(0xFFFF5A00))
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      courierUser.name,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Cairo'),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'هو كابتن التوصيل لطلبك اليوم',
                                      style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade200),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black87),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('قريباً: المحادثة المباشرة مع الكابتن', style: TextStyle(fontFamily: 'Cairo')),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade200),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.phone_outlined, size: 20, color: Colors.black87),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('جاري الاتصال بـ ${courierUser.name}...', style: const TextStyle(fontFamily: 'Cairo')),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

