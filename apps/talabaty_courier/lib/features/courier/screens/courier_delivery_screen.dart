import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/routing_service.dart';
import '../../../data/models/order_model.dart';

class CourierDeliveryScreen extends StatefulWidget {
  final String orderId;
  const CourierDeliveryScreen({super.key, required this.orderId});

  @override
  State<CourierDeliveryScreen> createState() => _CourierDeliveryScreenState();
}

class _CourierDeliveryScreenState extends State<CourierDeliveryScreen>
    with TickerProviderStateMixin {
  final RoutingService _routingService = RoutingService();
  GoogleMapController? _mapController;

  // Current courier position
  LatLng? _courierPos;
  double _courierBearing = 0.0;
  LatLng? _prevPos;

  // Route state
  List<LatLng> _routePoints = [];
  double _distanceMeters = 0;
  double _durationSecs = 0;
  String _routeSource = '';

  // Phase: 1 = courier→merchant, 2 = courier→customer
  int _phase = 1;
  bool _mapReady = false;

  // Streams & timers
  StreamSubscription<Position>? _posSub;
  Timer? _etaTimer;
  DateTime? _lastRouteRefresh;
  static const _routeRefreshInterval = Duration(minutes: 2);
  static const _deviationThresholdMeters = 150.0;

  // Smooth interpolation animation
  late AnimationController _markerAnimController;
  late Animation<double> _markerAnim;
  LatLng? _animStart;
  LatLng? _animEnd;

  OrderModel? get _order {
    try {
      final dp = context.read<DataProvider>();
      return dp.orders.firstWhere((o) => o.id == widget.orderId);
    } catch (_) {
      return null;
    }
  }

  LatLng get _merchantPos =>
      LatLng(_order?.storeLat ?? 15.5007, _order?.storeLng ?? 32.5599);

  LatLng get _customerPos =>
      LatLng(_order?.customerLat ?? 15.5500, _order?.customerLng ?? 32.5500);

  LatLng get _targetPos => _phase == 1 ? _merchantPos : _customerPos;

  @override
  void initState() {
    super.initState();

    _markerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _markerAnim = CurvedAnimation(
      parent: _markerAnimController,
      curve: Curves.easeInOut,
    );
    _markerAnimController.addListener(_onMarkerAnimTick);

    _startLocationTracking();
    _refreshRoute();

    // Periodic ETA refresh — NOT on every GPS tick
    _etaTimer = Timer.periodic(_routeRefreshInterval, (_) {
      if (mounted) _refreshRouteIfNeeded();
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _etaTimer?.cancel();
    _markerAnimController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ─── Location tracking ─────────────────────────────────────────────────────

  Future<void> _startLocationTracking() async {
    bool svcEnabled = await Geolocator.isLocationServiceEnabled();
    if (!svcEnabled) {
      _showGpsError('GPS غير مفعّل — الرجاء تفعيل خدمة الموقع');
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      _showGpsError('تم رفض صلاحية الموقع دائمًا — يرجى تغييرها من الإعدادات');
      return;
    }
    if (perm == LocationPermission.denied) return;

    // Get initial position
    try {
      final init = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) _onPositionUpdate(init, initial: true);
    } catch (_) {}

    // Stream — update every 15m or 8s
    _posSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15, // meters before a new event
          ),
        ).listen((pos) {
          if (mounted) _onPositionUpdate(pos);
        });
  }

  void _onPositionUpdate(Position pos, {bool initial = false}) {
    final newPos = LatLng(pos.latitude, pos.longitude);
    final bearing = pos.heading;

    // Smooth interpolated animation for marker
    if (_courierPos != null && !initial) {
      _animStart = _courierPos;
      _animEnd = newPos;
      _markerAnimController.forward(from: 0);
    }

    setState(() {
      _courierBearing = bearing;
      if (initial || _courierPos == null) {
        _courierPos = newPos;
      }
    });

    // Send location to backend (Socket-based via DataProvider)
    final dp = context.read<DataProvider>();
    dp.courierUpdateLocation(
      widget.orderId,
      pos.latitude,
      pos.longitude,
      heading: bearing,
    );

    // Check deviation from route — reroute if > threshold
    if (!initial && _routePoints.isNotEmpty) {
      final deviation = _minDistanceToRoute(newPos);
      if (deviation > _deviationThresholdMeters) {
        _refreshRoute();
      }
    }

    // Auto-center map on courier
    _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));

    _prevPos = newPos;
  }

  void _onMarkerAnimTick() {
    if (_animStart == null || _animEnd == null) return;
    final t = _markerAnim.value;
    setState(() {
      _courierPos = LatLng(
        _animStart!.latitude + (_animEnd!.latitude - _animStart!.latitude) * t,
        _animStart!.longitude +
            (_animEnd!.longitude - _animStart!.longitude) * t,
      );
    });
  }

  // ─── Route fetching ────────────────────────────────────────────────────────

  Future<void> _refreshRoute() async {
    final from = _courierPos;
    if (from == null) return;

    final result = await _routingService.getRoute(from, _targetPos);
    if (!mounted || result == null) return;

    setState(() {
      _routePoints = result.points;
      _distanceMeters = result.distanceInMeters;
      _durationSecs = result.durationInSeconds;
      _routeSource = result.source;
      _lastRouteRefresh = DateTime.now();
    });
  }

  void _refreshRouteIfNeeded() {
    final now = DateTime.now();
    if (_lastRouteRefresh == null ||
        now.difference(_lastRouteRefresh!) > _routeRefreshInterval) {
      _refreshRoute();
    }
  }

  double _minDistanceToRoute(LatLng pos) {
    if (_routePoints.isEmpty) return 0;
    double minDist = double.maxFinite;
    for (final p in _routePoints) {
      final d = _haversineMeters(pos, p);
      if (d < minDist) minDist = d;
    }
    return minDist;
  }

  double _haversineMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;
    final x = math.sin(dLat / 2);
    final y = math.sin(dLon / 2);
    final aa =
        x * x +
        math.cos(a.latitude * math.pi / 180) *
            math.cos(b.latitude * math.pi / 180) *
            y *
            y;
    return R * 2 * math.atan2(math.sqrt(aa), math.sqrt(1 - aa));
  }

  // ─── External navigation ───────────────────────────────────────────────────

  Future<void> _openExternalNavigation() async {
    final target = _targetPos;
    final uri = Uri.parse(
      'google.navigation:q=${target.latitude},${target.longitude}&mode=m',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Web fallback
      final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${target.latitude},${target.longitude}&travelmode=driving',
      );
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  // ─── Phase transition ──────────────────────────────────────────────────────

  void _advanceToCustomerPhase() {
    setState(() => _phase = 2);
    _refreshRoute();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      body: order == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : Stack(
              children: [
                // ── Map ──────────────────────────────────────────────────────
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _courierPos ?? _merchantPos,
                    zoom: 15.5,
                  ),
                  onMapCreated: (c) async {
                    _mapController = c;
                    await c.setMapStyle(_talabatyMapStyle);
                    setState(() => _mapReady = true);
                  },
                  markers: _buildMarkers(order),
                  polylines: _buildPolylines(),
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),

                // ── Top status card ──────────────────────────────────────────
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  child: _buildStatusCard(order),
                ),

                // ── Bottom action card ───────────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildActionCard(order),
                ),
              ],
            ),
    );
  }

  Set<Marker> _buildMarkers(OrderModel order) {
    final markers = <Marker>{};

    if (_courierPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('courier'),
          position: _courierPos!,
          rotation: _courierBearing,
          flat: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          anchor: const Offset(0.5, 0.5),
          infoWindow: const InfoWindow(title: 'موقعك الحالي'),
        ),
      );
    }

    // Merchant marker
    markers.add(
      Marker(
        markerId: const MarkerId('merchant'),
        position: _merchantPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: order.storeName ?? 'المتجر'),
      ),
    );

    // Customer marker (show in phase 2)
    if (_phase == 2) {
      markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: _customerPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'العميل'),
        ),
      );
    }

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

  Widget _buildStatusCard(OrderModel order) {
    final etaMins = (_durationSecs / 60).ceil();
    final distKm = (_distanceMeters / 1000).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E3238)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
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
                  _phase == 1 ? 'في الطريق للمتجر' : 'في الطريق للعميل',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$distKm كم • $etaMins دقيقة',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF9AA0A6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_routeSource == 'FALLBACK_HAVERSINE')
            const Tooltip(
              message: 'مسافة تقريبية - GPS route غير متاح',
              child: Icon(Icons.warning_amber, color: Colors.amber, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard(OrderModel order) {
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
          // Order info row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber ?? '#طلب',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF9AA0A6),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      order.storeName ?? 'المتجر',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3238),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // External navigation button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openExternalNavigation,
              icon: const Icon(
                Icons.navigation,
                size: 18,
                color: Color(0xFFFF5722),
              ),
              label: Text(
                'ابدأ التوجيه في خرائط Google',
                style: GoogleFonts.cairo(color: const Color(0xFFFF5722)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF5722)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Phase action button
          if (_phase == 1) ...[
            _primaryButton(
              label: 'وصلت للمتجر — تأكيد الاستلام',
              icon: Icons.store_outlined,
              onTap: () => _confirmPickup(order),
            ),
          ] else ...[
            _primaryButton(
              label: 'وصلت للعميل — تسليم الطلب',
              icon: Icons.check_circle_outline,
              onTap: () => _confirmDelivery(order),
            ),
          ],
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5722),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ─── Order flow actions ─────────────────────────────────────────────────────

  Future<void> _confirmPickup(OrderModel order) async {
    final dp = context.read<DataProvider>();
    await dp.updateOrderStatus(order.id, 'PICKED_UP');
    _advanceToCustomerPhase();
  }

  Future<void> _confirmDelivery(OrderModel order) async {
    final dp = context.read<DataProvider>();
    await dp.updateOrderStatus(order.id, 'DELIVERED');
    if (mounted) context.pop();
  }

  void _showGpsError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo()),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  // ─── Talabaty custom map style ──────────────────────────────────────────────
  static const String _talabatyMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#faf7f2"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#4a4e54"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#ffffff"},{"weight":2}]},
  {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#1a1d20"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e8f3e8"}]},
  {"featureType":"poi.park","stylers":[{"visibility":"simplified"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#e2e6ea"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#ffe8df"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#ffab91"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#d4e6f1"}]}
]
''';
}
