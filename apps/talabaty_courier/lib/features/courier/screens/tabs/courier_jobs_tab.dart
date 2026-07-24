import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/providers/data_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/store_model.dart';

class CourierJobsTab extends StatefulWidget {
  const CourierJobsTab({super.key});

  @override
  State<CourierJobsTab> createState() => _CourierJobsTabState();
}

class _CourierJobsTabState extends State<CourierJobsTab> {
  final Set<String> _rejectedOrders = {};
  GoogleMapController? _mapController;
  bool _isOnline = false;
  String? _selectedOrderId;

  LatLng _currentLocation = const LatLng(15.5007, 32.5599);
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DataProvider>().fetchRealOrders();
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationWarning(
          'خدمات الموقع (GPS) مغلقة، يرجى تفعيلها من إعدادات الهاتف.',
        );
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationWarning(
            'التطبيق يحتاج لصلاحية الموقع لتحديد موقعك وتلقي الطلبات.',
          );
          if (mounted) setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationWarning(
          'صلاحية الموقع مرفوضة دائماً. يرجى تفعيلها من إعدادات التطبيق.',
        );
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        final newLoc = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentLocation = newLoc;
          _isLoadingLocation = false;
        });

        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLoc, 14.0));
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _showLocationWarning(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تنبيه الموقع',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(message, style: GoogleFonts.cairo()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dataProvider = context.watch<DataProvider>();

    final currentUser = auth.currentUser;
    final courierId = currentUser?.id ?? '';
    final courierName = currentUser?.name ?? 'المندوب';

    final myOrders = courierId.isNotEmpty
        ? dataProvider.getOrdersForCourier(courierId)
        : <OrderModel>[];

    final activeOrder = myOrders
        .where(
          (o) =>
              o.status != OrderStatus.delivered &&
              o.status != OrderStatus.cancelled,
        )
        .firstOrNull;

    final availableOrders = dataProvider
        .getAvailableOrdersForCourier()
        .where((o) => !_rejectedOrders.contains(o.id))
        .toList();

    if (_selectedOrderId != null &&
        !availableOrders.any((o) => o.id == _selectedOrderId)) {
      _selectedOrderId = null;
    }

    final selectedOrder = _selectedOrderId != null
        ? availableOrders.cast<OrderModel?>().firstWhere(
            (o) => o?.id == _selectedOrderId,
            orElse: () => null,
          )
        : null;

    final isOnline = _isOnline;

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('courier_self'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'موقعي الحالي'),
      ),
    };

    for (final order in availableOrders) {
      markers.add(
        Marker(
          markerId: MarkerId('store_${order.id}'),
          position: LatLng(order.storeLat, order.storeLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'المتجر'),
          onTap: () {
            setState(() {
              _selectedOrderId = order.id;
            });
          },
        ),
      );
    }

    if (selectedOrder != null) {
      markers.add(
        Marker(
          markerId: MarkerId('customer_${selectedOrder.id}'),
          position: LatLng(
            selectedOrder.customerLat,
            selectedOrder.customerLng,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'موقع العميل'),
        ),
      );
    }

    final Set<Polyline> polylines = {};
    if (selectedOrder != null) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('route_${selectedOrder.id}'),
          points: [
            _currentLocation,
            LatLng(selectedOrder.storeLat, selectedOrder.storeLng),
            LatLng(selectedOrder.customerLat, selectedOrder.customerLng),
          ],
          color: AppColors.primaryColor,
          width: 5,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'كابتن $courierName',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _buildBodyContent(
          dataProvider: dataProvider,
          activeOrder: activeOrder,
          availableOrders: availableOrders,
          selectedOrder: selectedOrder,
          courierId: courierId,
          isOnline: isOnline,
          markers: markers,
          polylines: polylines,
        ),
      ),
    );
  }

  Widget _buildBodyContent({
    required DataProvider dataProvider,
    required OrderModel? activeOrder,
    required List<OrderModel> availableOrders,
    required OrderModel? selectedOrder,
    required String courierId,
    required bool isOnline,
    required Set<Marker> markers,
    required Set<Polyline> polylines,
  }) {
    // 1. Loading State
    if (dataProvider.isLoadingOrders && dataProvider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 16),
            Text(
              'جاري تحميل الطلبات...',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Error State
    if (dataProvider.ordersError != null && dataProvider.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'تعذر تحميل الطلبات',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تأكد من الاتصال بالشبكة وحاول مرة أخرى',
                style: GoogleFonts.cairo(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => dataProvider.fetchRealOrders(),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Active Order State
    if (activeOrder != null) {
      return _buildActiveOrderView(activeOrder);
    }

    // 4. Available Orders & Map View (NO RefreshIndicator wrapping Column + Expanded)
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLocation,
                  zoom: 14.0,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers: markers,
                polylines: polylines,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isOnline = !_isOnline;
                    });
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline
                          ? Colors.green.withValues(alpha: 0.85)
                          : Colors.black.withValues(alpha: 0.7),
                      boxShadow: [
                        BoxShadow(
                          color: isOnline
                              ? Colors.green.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isOnline
                                ? Icons.wifi_rounded
                                : Icons.power_settings_new_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isOnline ? 'متصل' : 'اضغط للاتصال',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isOnline) ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.bedtime_rounded,
                              size: 56,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'أنت الآن في وضع عدم الاتصال',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'قم بالاتصال بالشبكة لاستقبال طلبات التوصيل',
                            style: GoogleFonts.cairo(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (availableOrders.isEmpty) ...[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.radar_rounded,
                              size: 56,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد طلبات متاحة حالياً',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'خليك متصل، الطلبات الجديدة حتظهر هنا.',
                            style: GoogleFonts.cairo(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                              side: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => dataProvider.fetchRealOrders(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                              'تحديث الطلبات',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'طلبات التوصيل المتاحة (${availableOrders.length})',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primaryColor,
                      onRefresh: () => dataProvider.fetchRealOrders(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: availableOrders.length,
                        itemBuilder: (context, index) {
                          final order = availableOrders[index];
                          final isSelected = order.id == _selectedOrderId;
                          final distanceInMeters = Geolocator.distanceBetween(
                            _currentLocation.latitude,
                            _currentLocation.longitude,
                            order.storeLat,
                            order.storeLng,
                          );
                          final distanceInKm = distanceInMeters / 1000;
                          return _buildAvailableOrderCard(
                            context,
                            order,
                            courierId,
                            dataProvider,
                            isSelected,
                            distanceInKm,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveOrderView(OrderModel order) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delivery_dining_rounded,
                size: 80,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'لديك طلب قيد التوصيل!',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'رقم الطلب #${(order.orderNumber ?? '').isNotEmpty ? order.orderNumber! : order.id}',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: () => context.push('/courier/delivery/${order.id}'),
                child: Text(
                  'متابعة التوصيل',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableOrderCard(
    BuildContext context,
    OrderModel order,
    String courierId,
    DataProvider dataProvider,
    bool isSelected,
    double distanceInKm,
  ) {
    final store = dataProvider.stores.firstWhere(
      (s) => s.id == order.storeId,
      orElse: () => dataProvider.stores.isNotEmpty
          ? dataProvider.stores.first
          : StoreModel(
              id: 'dummy',
              ownerId: '',
              name: 'المتجر',
              type: StoreType.restaurant,
              phone: '',
              area: '',
              street: '',
              landmark: '',
              latitude: 0,
              longitude: 0,
              openingTime: '',
              closingTime: '',
              preparationTime: '',
              minimumOrder: 0,
              deliveryFee: 0,
              status: '',
              rating: 0,
              ratingCount: 0,
            ),
    );
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOrderId = isSelected ? null : order.id;
        });
        if (_selectedOrderId != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(order.storeLat, order.storeLng),
              14.5,
            ),
          );
        } else {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_currentLocation, 14.0),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.primaryColor.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'يبعد ${distanceInKm.toStringAsFixed(1)} كم عن موقعك',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${order.deliveryFee.toStringAsFixed(0)} ج.س',
                    style: GoogleFonts.cairo(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    (order.address.area ?? '').isNotEmpty
                        ? order.address.area!
                        : 'عنوان التوصيل',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _rejectedOrders.add(order.id);
                        if (_selectedOrderId == order.id) {
                          _selectedOrderId = null;
                        }
                      });
                    },
                    child: Text(
                      'تجاهل',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      try {
                        await dataProvider.courierAcceptOrder(
                          order.id,
                          courierId,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم قبول الطلب بنجاح! 🚀'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تعذر قبول الطلب: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      'قبول الطلب',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
