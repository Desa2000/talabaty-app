import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/services/routing_service.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/order_api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  final RoutingService _routingService = RoutingService();
  GoogleMapController? _mapController;

  List<LatLng> _routePoints = [];
  double _distanceMeters = 0;
  double _durationSecs = 0;
  bool _isLoadingRoute = true;

  // Courier position (from Socket)
  LatLng? _courierPos;
  double _courierBearing = 0;

  // Smooth animation
  late AnimationController _animController;
  late Animation<double> _anim;
  LatLng? _animStart;
  LatLng? _animEnd;

  Timer? _etaRefreshTimer;
  DateTime? _lastRouteRefresh;
  StreamSubscription? _socketSub;

  static const _refreshInterval = Duration(minutes: 3);

  OrderModel? get _order {
    try {
      return context.read<DataProvider>().orders.firstWhere(
        (o) => o.id == widget.orderId,
      );
    } catch (_) {
      return null;
    }
  }

  LatLng get _merchantPos =>
      LatLng(_order?.storeLat ?? 15.5007, _order?.storeLng ?? 32.5599);

  LatLng get _customerPos =>
      LatLng(_order?.customerLat ?? 15.5500, _order?.customerLng ?? 32.5500);

  bool get _isPickedUp {
    final s = _order?.status;
    return s == OrderStatus.pickedUp ||
        s == OrderStatus.onTheWay ||
        s == OrderStatus.delivered;
  }

  LatLng get _routeOrigin =>
      _courierPos ?? (_isPickedUp ? _merchantPos : _merchantPos);

  LatLng get _routeDest => _isPickedUp ? _customerPos : _merchantPos;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.addListener(_onAnimTick);

    _fetchRoute();

    _etaRefreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (mounted) _maybeFetchRoute();
    });

    // Listen to socket events from DataProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToSocketUpdates();
    });
  }

  void _listenToSocketUpdates() {
    final dp = context.read<DataProvider>();
    dp.addCourierLocationListener(widget.orderId, _onCourierLocationUpdate);
  }

  void _onCourierLocationUpdate(double lat, double lng, double heading) {
    if (!mounted) return;
    final newPos = LatLng(lat, lng);

    if (_courierPos != null) {
      _animStart = _courierPos;
      _animEnd = newPos;
      _animController.forward(from: 0);
    }

    setState(() {
      _courierBearing = heading;
      if (_courierPos == null) _courierPos = newPos;
    });
  }

  void _onAnimTick() {
    if (_animStart == null || _animEnd == null) return;
    final t = _anim.value;
    setState(() {
      _courierPos = LatLng(
        _animStart!.latitude + (_animEnd!.latitude - _animStart!.latitude) * t,
        _animStart!.longitude +
            (_animEnd!.longitude - _animStart!.longitude) * t,
      );
    });
  }

  Future<void> _fetchRoute() async {
    if (!mounted) return;
    setState(() => _isLoadingRoute = true);

    final result = await _routingService.getRoute(_routeOrigin, _routeDest);

    if (!mounted) return;
    setState(() {
      _routePoints = result?.points ?? [_routeOrigin, _routeDest];
      _distanceMeters = result?.distanceInMeters ?? 0;
      _durationSecs = result?.durationInSeconds ?? 0;
      _isLoadingRoute = false;
      _lastRouteRefresh = DateTime.now();
    });
  }

  void _maybeFetchRoute() {
    final now = DateTime.now();
    if (_lastRouteRefresh == null ||
        now.difference(_lastRouteRefresh!) >= _refreshInterval) {
      _fetchRoute();
    }
  }

  @override
  void dispose() {
    context.read<DataProvider>().removeCourierLocationListener(widget.orderId);
    _etaRefreshTimer?.cancel();
    _animController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1114),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _courierPos ?? _merchantPos,
              zoom: 14.5,
            ),
            onMapCreated: (c) async {
              _mapController = c;
              await c.setMapStyle(_talabatyMapStyle);
            },
            markers: _buildMarkers(order),
            polylines: _buildPolylines(),
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Loading overlay
          if (_isLoadingRoute)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),

          // ── Top back button ──────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2026).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xFF2E3238)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),

          // ── Bottom info card ─────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildInfoCard(order),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(OrderModel order) {
    final markers = <Marker>{};

    // Courier arrow
    if (_courierPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('courier'),
          position: _courierPos!,
          rotation: _courierBearing,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: const InfoWindow(title: 'المندوب'),
        ),
      );
    }

    // Merchant
    markers.add(
      Marker(
        markerId: const MarkerId('merchant'),
        position: _merchantPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: order.storeId),
      ),
    );

    // Customer destination
    markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: _customerPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'موقع التوصيل'),
      ),
    );

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (_routePoints.isEmpty) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: const Color(0xFFFF5722),
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  Widget _buildInfoCard(OrderModel order) {
    final etaMins = (_durationSecs / 60).ceil();
    final distKm = (_distanceMeters / 1000).toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C2026),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF2E3238))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: Color(0xFFFF5722),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusLabel(order.status),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _durationSecs > 0
                          ? 'المتوقع: $etaMins دقيقة · $distKm كم'
                          : 'جاري حساب الوقت...',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF9AA0A6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2E3238)),
          const SizedBox(height: 8),

          // Store name
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                color: Color(0xFF9AA0A6),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                order.storeId,
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Bankak Pending / Rejection Banners
          if (order.paymentMethod == PaymentMethod.bankak) ...[
            if (order.paymentStatus == PaymentStatus.bankakPending ||
                order.paymentStatus == PaymentStatus.bankakSubmitted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.hourglass_top_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'جاري التحقق من عملية الدفع',
                          style: GoogleFonts.cairo(
                            color: Colors.blue.shade200,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'سيتم تأكيد طلبك بعد مراجعة عملية بنكك بواسطة الإدارة المالية.',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF9AA0A6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (order.paymentStatus == PaymentStatus.bankakRejected) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'تعذر تأكيد عملية الدفع',
                          style: GoogleFonts.cairo(
                            color: Colors.red.shade200,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'لم نتمكن من مطابقة إشعار التحويل البنكي. يمكنك إدخال 4 أرقام جديدة أو التحويل كاش.',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF9AA0A6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _showReSubmitDialog(context, order),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              'إعادة إدخال الرقم',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _switchToCash(context, order),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              'تحويل إلى كاش',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],

          if (order.status == OrderStatus.delivered) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'تم تسليم الطلب بنجاح',
                    style: GoogleFonts.cairo(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(OrderStatus? status) {
    switch (status) {
      case OrderStatus.assignedToCourier:
        return 'المندوب في الطريق للمتجر';
      case OrderStatus.courierGoingToStore:
        return 'المندوب في الطريق للمتجر';
      case OrderStatus.courierArrivedStore:
        return 'المندوب في المتجر يستلم طلبك';
      case OrderStatus.pickedUp:
        return 'الطلب في الطريق إليك';
      case OrderStatus.onTheWay:
        return 'الطلب في الطريق إليك';
      case OrderStatus.courierArrivedCustomer:
        return 'المندوب وصل إليك!';
      case OrderStatus.delivered:
        return 'تم التسليم';
      default:
        return 'جاري تتبع طلبك...';
    }
  }

  Future<void> _showReSubmitDialog(
    BuildContext context,
    OrderModel order,
  ) async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'إعادة إدخال رقم عملية بنكك',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            hintText: 'أدخل آخر 4 أرقام من الإشعار (4 أرقام)',
            hintStyle: GoogleFonts.cairo(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final last4 = controller.text.trim();
              if (!RegExp(r'^\d{4}$').hasMatch(last4)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('أدخل 4 أرقام فقط بشكل صحيح'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                await OrderApiService().submitBankakLast4(order.id, last4);
                await context.read<DataProvider>().fetchRealOrders();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إرسال رقم العملية للتحقق'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
            ),
            child: Text(
              'إرسال',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchToCash(BuildContext context, OrderModel order) async {
    try {
      await OrderApiService().switchToCash(order.id);
      await context.read<DataProvider>().fetchRealOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم التحويل إلى الدفع عند الاستلام بنجاح'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Talabaty custom map style ──────────────────────────────────────────────
  static const String _talabatyMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#faf7f2"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#4a4e54"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#ffe8df"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#ffab91"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#d4e6f1"}]}
]
''';
}
