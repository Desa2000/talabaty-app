import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:talabaty_app/core/providers/data_provider.dart';
import 'package:talabaty_app/core/providers/auth_provider.dart';
import 'package:talabaty_app/core/constants/app_colors.dart';
import 'package:talabaty_app/data/models/store_model.dart';
import 'package:talabaty_app/core/constants/enums.dart';
import 'package:talabaty_app/core/services/delivery_fee_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  double? _userLat;
  double? _userLng;

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
      if (mounted) setState(() { _userLat = pos.latitude; _userLng = pos.longitude; });
    } catch (_) {}
  }

  // Distance label
  String _distanceLabel(StoreModel store) {
    if (_userLat == null || _userLng == null) return '';
    final km = DeliveryFeeService.distanceKm(_userLat!, _userLng!, store.latitude, store.longitude);
    return km < 1 ? '${(km * 1000).round()} م' : '${km.toStringAsFixed(1)} كم';
  }

  // Delivery fee label
  String _deliveryFeeLabel(StoreModel store) {
    if (_userLat == null || _userLng == null) return '';
    final fee = DeliveryFeeService.deliveryFeeFromCoords(_userLat!, _userLng!, store.latitude, store.longitude);
    return '${fee.toStringAsFixed(0)} ج.س';
  }

  // Sort stores by distance
  List<StoreModel> _sortedByDistance(List<StoreModel> stores) {
    if (_userLat == null || _userLng == null) return stores;
    final list = List<StoreModel>.from(stores);
    list.sort((a, b) {
      final da = DeliveryFeeService.distanceKm(_userLat!, _userLng!, a.latitude, a.longitude);
      final db = DeliveryFeeService.distanceKm(_userLat!, _userLng!, b.latitude, b.longitude);
      return da.compareTo(db);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final authProvider = context.watch<AuthProvider>();
    final stores = dataProvider.stores;
    final currentUser = authProvider.currentUser;
    final userName = (currentUser != null && currentUser.name.trim().isNotEmpty)
        ? currentUser.name.trim().split(' ').first
        : 'ضيف';

    final restaurants = _sortedByDistance(stores.where((s) => s.type == StoreType.restaurant).toList());
    final supermarkets = _sortedByDistance(stores.where((s) => s.type == StoreType.supermarket).toList());
    final pharmacies = _sortedByDistance(stores.where((s) => s.type == StoreType.pharmacy).toList());
    final nearby = _sortedByDistance(stores).take(8).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, userName)),
            SliverToBoxAdapter(child: _buildSearchBar(context)),
            // Location chip
            if (_userLat != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'تم تحديد موقعك — المسافات محسوبة تلقائياً',
                        style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(child: _buildCategories(context)),
            SliverToBoxAdapter(child: _buildSectionTitle('🍽️ المطاعم', '${restaurants.length} مطعم')),
            SliverToBoxAdapter(child: _buildHorizontalStoreList(context, restaurants)),
            SliverToBoxAdapter(child: _buildSectionTitle('🛒 سوبرماركت', '${supermarkets.length} متجر')),
            SliverToBoxAdapter(child: _buildHorizontalStoreList(context, supermarkets)),
            SliverToBoxAdapter(child: _buildSectionTitle('💊 الصيدليات', '${pharmacies.length} صيدلية')),
            SliverToBoxAdapter(child: _buildHorizontalStoreList(context, pharmacies)),
            SliverToBoxAdapter(child: _buildSectionTitle('📍 الأقرب إليك', '${nearby.length} متجر')),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildVerticalStoreCard(context, nearby[index]),
                  childCount: nearby.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً، $userName 👋',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'وش تبي تطلب اليوم؟',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: () => context.push('/customer/notifications'),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF111111)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SEARCH BAR ────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/customer/search'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.primaryColor, size: 22),
            const SizedBox(width: 10),
            Text(
              'ابحث عن مطعم أو منتج...',
              style: GoogleFonts.cairo(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BANNER ────────────────────────────────────────────────
  Widget _buildBanner() {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6A00), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6A00).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'خصم حصري 🔥',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'توصيل مجاني\nلأول 3 طلبات',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.delivery_dining_rounded,
                  size: 80,
                  color: Colors.white.withOpacity(0.85),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CATEGORIES ────────────────────────────────────────────
  Widget _buildCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            'الأقسام',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111111),
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              _buildCategoryChip(context, Icons.restaurant_rounded, 'المطاعم', const Color(0xFFFF6A00), 'restaurant'),
              _buildCategoryChip(context, Icons.shopping_basket_rounded, 'سوبرماركت', const Color(0xFF2E7D32), 'supermarket'),
              _buildCategoryChip(context, Icons.local_pharmacy_rounded, 'صيدلية', const Color(0xFF007AFF), 'pharmacy'),
              _buildCategoryChip(context, Icons.card_giftcard_rounded, 'هدايا', const Color(0xFF9C27B0), 'gift'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, IconData icon, String label, Color color, String type) {
    return GestureDetector(
      onTap: () => context.push('/customer/stores/$type'),
      child: Container(
        width: 82,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: const Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SECTION TITLE ─────────────────────────────────────────
  Widget _buildSectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111111),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HORIZONTAL STORE LIST ─────────────────────────────────
  Widget _buildHorizontalStoreList(BuildContext context, List<StoreModel> stores) {
    if (stores.isEmpty) {
      return Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'لا توجد متاجر حالياً',
            style: GoogleFonts.cairo(color: Colors.grey[400], fontSize: 14),
          ),
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          return _buildHorizontalStoreCard(context, store);
        },
      ),
    );
  }

  Widget _buildHorizontalStoreCard(BuildContext context, StoreModel store) {
    final dist = _distanceLabel(store);
    final fee = _deliveryFeeLabel(store);
    return GestureDetector(
      onTap: () => context.push('/customer/store/${store.id}'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 100,
                width: double.infinity,
                color: AppColors.primaryColor.withOpacity(0.08),
                child: Image.network(
                  store.logo ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      _getStoreIcon(store.type),
                      size: 40,
                      color: AppColors.primaryColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF111111)),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text('${store.rating}', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                      if (dist.isNotEmpty) ...[  
                        const SizedBox(width: 6),
                        const Text('•', style: TextStyle(color: Color(0xFFCCCCCC))),
                        const SizedBox(width: 6),
                        const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primaryColor),
                        Text(dist, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF555555))),
                      ],
                    ],
                  ),
                  if (fee.isNotEmpty) ...[  
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.delivery_dining_rounded, size: 13, color: Color(0xFF888888)),
                        const SizedBox(width: 4),
                        Text('توصيل $fee', style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF888888))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── VERTICAL STORE CARD ───────────────────────────────────
  Widget _buildVerticalStoreCard(BuildContext context, StoreModel store) {
    return GestureDetector(
      onTap: () => context.push('/customer/store/${store.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 150,
                width: double.infinity,
                color: AppColors.primaryColor.withOpacity(0.06),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      store.coverImage ?? store.logo ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getStoreIcon(store.type),
                              size: 50,
                              color: AppColors.primaryColor.withOpacity(0.4),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store.name,
                              style: GoogleFonts.cairo(
                                color: AppColors.primaryColor.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor.withOpacity(0.3),
                          ),
                        );
                      },
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: const Color(0xFF111111),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 3),
                            Text(
                              '${store.rating}',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    store.area,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Chips row
                  Row(
                    children: [
                      _buildInfoTag(Icons.access_time, store.preparationTime),
                      const SizedBox(width: 16),
                      _buildInfoTag(Icons.delivery_dining, '${store.deliveryFee.toInt()} ج.س'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  IconData _getStoreIcon(StoreType type) {
    switch (type) {
      case StoreType.restaurant:
        return Icons.restaurant_rounded;
      case StoreType.supermarket:
        return Icons.shopping_basket_rounded;
      case StoreType.pharmacy:
        return Icons.local_pharmacy_rounded;
      case StoreType.gift:
        return Icons.card_giftcard_rounded;
    }
  }
}
