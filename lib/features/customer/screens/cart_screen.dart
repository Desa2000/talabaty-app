import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/delivery_fee_service.dart';
import '../../../core/widgets/custom_image.dart';
import '../../../data/models/product_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double? _userLat;
  double? _userLng;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _loadingLocation = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _loadingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _loadingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLat = pos.latitude;
          _userLng = pos.longitude;
          _loadingLocation = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final dataProvider = context.watch<DataProvider>();
    final Color hslPrimary = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.50).toColor(); // Orange
    final Color hslGradientStart = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.55).toColor();
    final Color hslGradientEnd = HSLColor.fromAHSL(1.0, 12.0, 1.0, 0.50).toColor();
    final Color hslSoftGray = HSLColor.fromAHSL(1.0, 240.0, 0.05, 0.94).toColor();

    if (cart.items.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text('عربة التسوق', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)
                    ],
                  ),
                  child: Icon(Icons.shopping_basket_outlined, size: 80, color: hslPrimary),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                Text(
                  'عربة التسوق فارغة', 
                  style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                ),
                const SizedBox(height: 8),
                Text(
                  'تصفح الأقسام وأضف بعض المنتجات اللذيذة!', 
                  style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary)
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hslPrimary,
                    minimumSize: const Size(180, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => context.pop(), 
                  child: Text('ابدأ التسوق الآن', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white))
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Get store information for the products in cart
    final storeId = cart.items.first.product.storeId;
    final store = dataProvider.stores.firstWhere(
      (s) => s.id == storeId,
      orElse: () => dataProvider.stores.first,
    );

    // Calculate dynamic delivery fee
    double distance = 0.0;
    double deliveryFee = 3000.0; // fallback default delivery fee

    if (_userLat != null && _userLng != null) {
      distance = DeliveryFeeService.distanceKm(_userLat!, _userLng!, store.latitude, store.longitude);
      deliveryFee = DeliveryFeeService.deliveryFee(distance);
    } else {
      // default location of store (if gps fails)
      distance = DeliveryFeeService.distanceKm(15.5006, 32.5599, store.latitude, store.longitude);
      deliveryFee = DeliveryFeeService.deliveryFee(distance);
    }

    final double serviceFee = DeliveryFeeService.serviceFee(cart.totalPrice);
    final double total = DeliveryFeeService.orderTotal(
      subtotal: cart.totalPrice,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('عربة التسوق', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  
                  String optionsText = '';
                  if (item.selectedOptions.isNotEmpty) {
                    List<String> optNames = [];
                    for (var group in item.product.optionGroups) {
                      if (item.selectedOptions.containsKey(group.id)) {
                        for (var optId in item.selectedOptions[group.id]!) {
                          final opt = group.options.firstWhere(
                            (o) => o.id == optId, 
                            orElse: () => ProductOption(id: '', name: '', extraPrice: 0)
                          );
                          if (opt.name.isNotEmpty) optNames.add(opt.name);
                        }
                      }
                    }
                    optionsText = optNames.join('، ');
                  }
                  
                  if (item.selectedAddOns.isNotEmpty) {
                    if (optionsText.isNotEmpty) optionsText += '، ';
                    optionsText += item.selectedAddOns.map((e) => e.name).join('، ');
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderGray.withOpacity(0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CustomImage(
                            imagePath: item.product.image,
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name, 
                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)
                              ),
                              if (optionsText.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    optionsText, 
                                    style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 12)
                                  ),
                                ),
                              if (item.notes.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ملاحظة: ${item.notes}', 
                                    style: GoogleFonts.cairo(color: Colors.amber.shade900, fontSize: 11, fontWeight: FontWeight.bold)
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Text(
                                '${item.totalPrice.toInt()} ج.س', 
                                style: GoogleFonts.cairo(color: hslPrimary, fontWeight: FontWeight.w900, fontSize: 15)
                              ),
                            ],
                          ),
                        ),
                        
                        // Styled quantity editor
                        Container(
                          decoration: BoxDecoration(
                            color: hslSoftGray,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.add_rounded, color: hslPrimary, size: 18),
                                onPressed: () => cart.updateQuantity(item, item.quantity + 1),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                              Text(
                                '${item.quantity}', 
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 14)
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_rounded, color: AppColors.textPrimary, size: 18),
                                onPressed: () => cart.updateQuantity(item, item.quantity - 1),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 300.ms).slideX(begin: 0.05, end: 0);
                },
              ),
            ),
            
            // Bottom Receipt Summary
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05), 
                    blurRadius: 20, 
                    offset: const Offset(0, -6)
                  )
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: AppColors.borderGray.withOpacity(0.6), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Location Status or warning
                  if (_loadingLocation)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor)),
                          const SizedBox(width: 8),
                          Text('جاري حساب مسافة التوصيل لتحديد التكلفة...', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    )
                  else if (_userLat != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.primaryColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'مسافة التوصيل: ${distance.toStringAsFixed(1)} كم من ${store.name}',
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  
                  // Financial Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المجموع الفرعي', style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 14)),
                      Text('${cart.totalPrice.toInt()} ج.س', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('رسوم التوصيل (3,000 ج.س/كم)', style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 14)),
                      Text('${deliveryFee.toInt()} ج.س', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('رسوم الخدمة (6%)', style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 14)),
                      Text('${serviceFee.toInt()} ج.س', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppColors.borderGray),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900)),
                      Text(
                        '${total.toInt()} ج.س', 
                        style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900, color: hslPrimary)
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Checkout Button
                  Container(
                    width: double.infinity,
                    height: 56,
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
                      onPressed: () => context.push('/customer/checkout'),
                      child: Text(
                        'إتمام الطلب', 
                        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
