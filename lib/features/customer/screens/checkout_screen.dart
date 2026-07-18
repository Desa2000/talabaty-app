import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../core/services/delivery_fee_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/mock/mock_data.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _selectedPayment = PaymentMethod.cashOnDelivery;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  // Default selected address, can be updated via AddressScreen
  AddressModel _selectedAddress = MockData.addressBahri;
  double? _userLat;
  double? _userLng;

  // Premium HSL-derived colors
  final Color hslPrimary = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.50).toColor();
  final Color hslGradientStart = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.55).toColor();
  final Color hslGradientEnd = HSLColor.fromAHSL(1.0, 12.0, 1.0, 0.50).toColor();
  final Color hslCream = HSLColor.fromAHSL(1.0, 25.0, 0.85, 0.97).toColor();
  final Color hslSoftGray = HSLColor.fromAHSL(1.0, 240.0, 0.05, 0.94).toColor();

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLat = pos.latitude;
          _userLng = pos.longitude;
          // Pre-fill selected address coordinates if it's the default mock address
          _selectedAddress = AddressModel(
            id: _selectedAddress.id,
            title: _selectedAddress.title,
            city: _selectedAddress.city,
            area: _selectedAddress.area,
            street: _selectedAddress.street,
            landmark: _selectedAddress.landmark,
            latitude: pos.latitude,
            longitude: pos.longitude,
            phone: _selectedAddress.phone,
          );
        });
      }
    } catch (_) {}
  }

  void _confirmOrder(double deliveryFee, double serviceFee, double total, double storeLat, double storeLng) {
    final cart = context.read<CartProvider>();
    final dataProvider = context.read<DataProvider>();
    final auth = context.read<AuthProvider>();

    if (cart.items.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final storeId = cart.items.first.product.storeId;
      
      final newOrder = dataProvider.placeOrder(
        customerId: auth.currentUser?.id ?? '',
        storeId: storeId,
        cartItems: cart.items,
        address: _selectedAddress,
        customerLat: _selectedAddress.latitude != 0 ? _selectedAddress.latitude : (_userLat ?? 15.5006),
        customerLng: _selectedAddress.longitude != 0 ? _selectedAddress.longitude : (_userLng ?? 32.5599),
        storeLat: storeLat,
        storeLng: storeLng,
        subtotal: cart.totalPrice,
        deliveryFee: deliveryFee,
        serviceFee: serviceFee,
        discount: 0.0,
        total: total,
        paymentMethod: _selectedPayment,
        paymentStatus: PaymentStatus.unpaid,
      );

      final orderId = newOrder.id;
      cart.clearCart();

      if (mounted) {
        context.go('/customer/order-tracking/$orderId');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final dataProvider = context.watch<DataProvider>();

    if (cart.items.isEmpty) {
      return Scaffold(
        backgroundColor: hslCream,
        appBar: AppBar(
          title: Text('إتمام الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'عربة التسوق فارغة',
            style: GoogleFonts.cairo(fontSize: 18, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final storeId = cart.items.first.product.storeId;
    final store = dataProvider.stores.firstWhere(
      (s) => s.id == storeId,
      orElse: () => dataProvider.stores.first,
    );

    // Calculate dynamic delivery fee based on customer address
    double custLat = _selectedAddress.latitude != 0 ? _selectedAddress.latitude : (_userLat ?? 15.5006);
    double custLng = _selectedAddress.longitude != 0 ? _selectedAddress.longitude : (_userLng ?? 32.5599);

    final distance = DeliveryFeeService.distanceKm(custLat, custLng, store.latitude, store.longitude);
    final deliveryFee = DeliveryFeeService.deliveryFee(distance);
    final serviceFee = DeliveryFeeService.serviceFee(cart.totalPrice);
    final total = DeliveryFeeService.orderTotal(
      subtotal: cart.totalPrice,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
    );

    return Scaffold(
      backgroundColor: hslCream,
      appBar: AppBar(
        title: Text('إتمام الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Delivery Address Section
              Text(
                'موقع التوصيل',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final result = await context.push('/customer/address');
                  if (!mounted) return;
                  if (result != null && result is String) {
                    setState(() {
                      // Note: We use geolocator coordinates if selecting a new location
                      _selectedAddress = AddressModel(
                        id: 'new',
                        title: 'موقع مخصص',
                        city: '',
                        area: '',
                        street: result,
                        landmark: '',
                        latitude: _userLat ?? 15.5006,
                        longitude: _userLng ?? 32.5599,
                        phone: '',
                      );
                    });
                  }
                },
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: hslPrimary.withOpacity(0.15), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: hslPrimary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on_rounded, color: hslPrimary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'العنوان المختار',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedAddress.street,
                              style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 2. Payment Methods Section
              Text(
                'طريقة الدفع',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _buildPaymentCard(
                title: 'الدفع عند الاستلام',
                subtitle: 'نقداً (كاش)',
                icon: Icons.payments_outlined,
                method: PaymentMethod.cashOnDelivery,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildPaymentCard(
                title: 'بنكك (Bankak)',
                subtitle: 'تحويل بنكي مباشر',
                icon: Icons.account_balance_outlined,
                method: PaymentMethod.bankak,
                color: Colors.blue,
              ),

              const SizedBox(height: 28),

              // 3. Notes Section
              Text(
                'ملاحظات للطلب',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'مثال: بدون بصل، زيادة كاتشب...',
                  hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 28),

              // 4. Order Summary Section
              Text(
                'ملخص الفاتورة',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderGray.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('المجموع الفرعي', '${cart.totalPrice.toInt()} ج.س'),
                    const SizedBox(height: 10),
                    _buildSummaryRow('مسافة التوصيل', '${distance.toStringAsFixed(1)} كم'),
                    const SizedBox(height: 10),
                    _buildSummaryRow('رسوم التوصيل (3,000 ج.س/كم)', '${deliveryFee.toInt()} ج.س'),
                    const SizedBox(height: 10),
                    _buildSummaryRow('رسوم الخدمة (6%)', '${serviceFee.toInt()} ج.س'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: AppColors.borderGray, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الإجمالي', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w900)),
                        Text(
                          '${total.toInt()} ج.س',
                          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: hslPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // 5. Confirm Button
              Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [hslGradientStart, hslGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: hslPrimary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _isLoading ? null : () => _confirmOrder(deliveryFee, serviceFee, total, store.latitude, store.longitude),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          'تأكيد وإرسال الطلب',
                          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required PaymentMethod method,
    required Color color,
  }) {
    final isSelected = _selectedPayment == method;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPayment = method;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? hslPrimary : AppColors.borderGray.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? hslPrimary.withOpacity(0.03)
                  : Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? hslPrimary : Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    ).animate(target: isSelected ? 1.0 : 0.0)
     .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 150.ms);
  }
}
