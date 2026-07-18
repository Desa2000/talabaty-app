import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/providers/data_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/store_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class CourierJobsTab extends StatefulWidget {
  const CourierJobsTab({super.key});

  @override
  State<CourierJobsTab> createState() => _CourierJobsTabState();
}

class _CourierJobsTabState extends State<CourierJobsTab> {
  final Set<String> _rejectedOrders = {};
  final MapController _mapController = MapController();
  bool _isOnline = false;
  String? _selectedOrderId;
  
  LatLng _currentLocation = const LatLng(15.5007, 32.5599); 
  bool _isLoadingLocation = true;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationWarning('خدمات الموقع (GPS) مغلقة، يرجى تفعيلها من إعدادات الهاتف.');
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationWarning('التطبيق يحتاج لصلاحية الموقع لتحديد موقعك وتلقي الطلبات.');
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationWarning('صلاحية الموقع مرفوضة دائماً. يرجى تفعيلها من إعدادات التطبيق.');
      if (mounted) setState(() => _isLoadingLocation = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      if (_isMapReady) {
        _mapController.move(_currentLocation, 14.0);
      }
    }
  }

  void _showLocationWarning(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تنبيه الموقع', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(message, style: GoogleFonts.cairo()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dataProvider = context.watch<DataProvider>();
    
    final courierId = auth.currentUser?.id ?? '';
    final courier = dataProvider.couriers.firstWhere(
      (c) => c.userId == courierId,
      orElse: () => dataProvider.couriers.isNotEmpty
          ? dataProvider.couriers.first
          : CourierProfile(userId: courierId, nationalId: '123', dateOfBirth: '1995-01-01', emergencyPhone: '123', vehicleType: VehicleType.motorcycle),
    ); 
    final courierUser = dataProvider.users.firstWhere(
      (u) => u.id == courier.userId,
      orElse: () => dataProvider.users.isNotEmpty
          ? dataProvider.users.first
          : UserModel(id: 'dummy', name: 'سائق تجريبي', email: '', phone: '123', password: '', role: UserRole.courier, createdAt: DateTime.now()),
    );

    final myOrders = dataProvider.getOrdersForCourier(courier.userId);
    final activeOrder = myOrders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).firstOrNull;
    final availableOrders = dataProvider.getAvailableOrdersForCourier().where((o) => !_rejectedOrders.contains(o.id)).toList();

    if (_selectedOrderId != null && !availableOrders.any((o) => o.id == _selectedOrderId)) {
      _selectedOrderId = null;
    }

    final selectedOrder = _selectedOrderId != null
        ? availableOrders.cast<OrderModel?>().firstWhere((o) => o?.id == _selectedOrderId, orElse: () => null)
        : null;
    
    final isOnline = _isOnline;
    final Color hslPrimary = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.50).toColor();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('كابتن ${courierUser.name}', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: activeOrder != null
            ? _buildActiveOrderView(activeOrder)
            : Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentLocation,
                            initialZoom: 14.0,
                            onMapReady: () {
                              _isMapReady = true;
                              if (!_isLoadingLocation) {
                                _mapController.move(_currentLocation, 14.0);
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.talabaty.app',
                            ),
                            if (selectedOrder != null)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: [
                                      _currentLocation,
                                      LatLng(selectedOrder.storeLat, selectedOrder.storeLng),
                                      LatLng(selectedOrder.customerLat, selectedOrder.customerLng),
                                    ],
                                    color: AppColors.primaryColor,
                                    strokeWidth: 4.0,
                                  ),
                                ],
                              ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentLocation,
                                  width: 50,
                                  height: 50,
                                  child: _isLoadingLocation 
                                      ? const CircularProgressIndicator(color: AppColors.primaryColor)
                                      : Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(color: hslPrimary.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)],
                                            border: Border.all(color: hslPrimary, width: 2),
                                          ),
                                          child: Icon(Icons.motorcycle_rounded, color: hslPrimary, size: 30),
                                        ),
                                ),
                                ...availableOrders.map((order) {
                                  return Marker(
                                    point: LatLng(order.storeLat, order.storeLng),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 40),
                                  );
                                }),
                                if (selectedOrder != null)
                                  Marker(
                                    point: LatLng(selectedOrder.customerLat, selectedOrder.customerLng),
                                    width: 45,
                                    height: 45,
                                    child: const Icon(Icons.person_pin_circle_rounded, color: Colors.blue, size: 45),
                                  ),
                              ],
                            ),
                          ],
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
                                color: isOnline ? Colors.green.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.7),
                                boxShadow: [
                                  BoxShadow(
                                    color: isOnline ? Colors.green.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  )
                                ],
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 3),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(isOnline ? Icons.wifi_rounded : Icons.power_settings_new_rounded, color: Colors.white, size: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                      isOnline ? 'متصل' : 'اضغط للاتصال',
                                      style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10))],
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
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)]),
                                      child: const Icon(Icons.bedtime_rounded, size: 64, color: AppColors.textSecondary),
                                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                                    const SizedBox(height: 24),
                                    Text('أنت الآن في وضع عدم الاتصال', style: GoogleFonts.cairo(fontSize: 18, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text('قم بالاتصال بالشبكة لاستقبال طلبات التوصيل', style: GoogleFonts.cairo(color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            )
                          ] else if (availableOrders.isEmpty) ...[
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)]),
                                      child: const Icon(Icons.radar_rounded, size: 64, color: AppColors.primaryColor),
                                    ),
                                    const SizedBox(height: 24),
                                    Text('جاري البحث عن طلبات قريبة منك...', style: GoogleFonts.cairo(fontSize: 18, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            )
                          ] else ...[
                            Text('طلبات التوصيل المتاحة (${availableOrders.length})', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 100),
                                physics: const BouncingScrollPhysics(),
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
                                  return _buildAvailableOrderCard(context, order, courier.userId, dataProvider, isSelected, distanceInKm)
                                      .animate().fade(duration: 400.ms, delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.05);
                                },
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
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
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 10))]),
              child: const Icon(Icons.delivery_dining_rounded, size: 80, color: AppColors.primaryColor),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            Text('لديك طلب قيد التوصيل!', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('رقم الطلب #${order.id}', style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textSecondary)),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primaryColor.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: () => context.push('/courier/delivery/${order.id}'),
                child: Text('متابعة التوصيل', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
          : StoreModel(id: 'dummy', ownerId: '', name: 'متجر غير معروف', type: StoreType.restaurant, phone: '', area: '', street: '', landmark: '', latitude: 0, longitude: 0, openingTime: '', closingTime: '', preparationTime: '', minimumOrder: 0, deliveryFee: 0, status: '', rating: 0, ratingCount: 0),
    );
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOrderId = isSelected ? null : order.id;
        });
        if (_selectedOrderId != null) {
          _mapController.move(LatLng(order.storeLat, order.storeLng), 14.5);
        } else {
          _mapController.move(_currentLocation, 14.0);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.primaryColor.withValues(alpha: 0.15),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.15) : AppColors.primaryColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text('طلب جديد', style: GoogleFonts.cairo(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_bike_rounded, color: AppColors.primaryColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${distanceInKm.toStringAsFixed(1)} كم',
                            style: GoogleFonts.cairo(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text('${order.deliveryFee.toStringAsFixed(0)} ج.س', style: GoogleFonts.outfit(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.store_rounded, color: AppColors.primaryColor, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('استلام من', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                  Text(store.name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                ])),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20), 
              child: SizedBox(
                height: 20, 
                child: CustomPaint(
                  painter: DashedLinePainter(),
                )
              )
            ),
            Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.location_on_rounded, color: Colors.green, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('توصيل إلى', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                  Text(order.address.street, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                ])),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _rejectedOrders.add(order.id);
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red, 
                      side: const BorderSide(color: Colors.red, width: 1.5), 
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('رفض', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      dataProvider.courierAcceptOrder(order.id, courierId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor, 
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text('قبول الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
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

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 4, startY = 0;
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

