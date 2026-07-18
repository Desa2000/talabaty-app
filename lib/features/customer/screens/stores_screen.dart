import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talabaty_app/core/widgets/custom_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/constants/enums.dart';
import '../../../data/models/store_model.dart';

class StoresScreen extends StatelessWidget {
  final String categoryType;
  const StoresScreen({super.key, required this.categoryType});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    
    StoreType? targetType;
    String title = '';
    String subtitle = '';
    IconData categoryIcon = Icons.storefront_rounded;
    Color categoryColor = AppColors.primaryColor;
    
    if (categoryType == 'restaurant') {
      targetType = StoreType.restaurant;
      title = 'المطاعم';
      subtitle = 'أشهى المأكولات من أفضل المطاعم';
      categoryIcon = Icons.restaurant_rounded;
      categoryColor = const Color(0xFFFF8C00);
    } else if (categoryType == 'supermarket') {
      targetType = StoreType.supermarket;
      title = 'السوبرماركت';
      subtitle = 'كل ما تحتاجه لمنزلك';
      categoryIcon = Icons.local_grocery_store_rounded;
      categoryColor = const Color(0xFF4CAF50);
    } else if (categoryType == 'pharmacy') {
      targetType = StoreType.pharmacy;
      title = 'الصيدليات';
      subtitle = 'أدوية ومستلزمات طبية';
      categoryIcon = Icons.local_pharmacy_rounded;
      categoryColor = const Color(0xFF2196F3);
    } else if (categoryType == 'gift') {
      targetType = StoreType.gift;
      title = 'الهدايا';
      subtitle = 'هدايا وباقات ورد لكل المناسبات';
      categoryIcon = Icons.card_giftcard_rounded;
      categoryColor = const Color(0xFFE91E63);
    }

    final stores = dataProvider.stores.where((s) => s.type == targetType).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, title, subtitle, categoryIcon, categoryColor),
          SliverToBoxAdapter(
            child: stores.isEmpty
                ? _buildEmptyState()
                : _buildStoresList(stores),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))
            ]
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Icon(icon, size: 250, color: color.withValues(alpha: 0.1)),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ).animate().fade(duration: 400.ms).scale(curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: GoogleFonts.cairo().fontFamily,
                      height: 1.2,
                    ),
                  ).animate().fade(delay: 100.ms).slideX(begin: 0.1),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontFamily: GoogleFonts.cairo().fontFamily,
                    ),
                  ).animate().fade(delay: 200.ms).slideX(begin: 0.1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primaryColor.withValues(alpha: 0.1), blurRadius: 30)
              ]
            ),
            child: const Icon(Icons.storefront_outlined, size: 64, color: AppColors.primaryColor),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            'لا توجد متاجر حالياً',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.cairo().fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم إضافة المزيد من المتاجر قريباً',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontFamily: GoogleFonts.cairo().fontFamily,
            ),
          ),
        ],
      ).animate().fade(),
    );
  }

  Widget _buildStoresList(List<StoreModel> stores) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return _buildStoreCard(context, store, index);
      },
    );
  }

  Widget _buildStoreCard(BuildContext context, StoreModel store, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/customer/store/${store.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'store_cover_${store.id}',
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    image: DecorationImage(
                      image: NetworkImage(store.coverImage ?? store.logo ?? 'https://via.placeholder.com/400x200'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(
                        colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                store.rating.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.delivery_dining_rounded, color: AppColors.primaryColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${store.deliveryFee.toInt()} ج.س',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))
                        ]
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CustomImage(imagePath: store.logo ?? ''),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.cairo().fontFamily,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: Colors.grey, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${store.area} - ${store.street}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontFamily: GoogleFonts.cairo().fontFamily,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, color: Colors.green, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                store.preparationTime,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.cairo().fontFamily,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.shopping_bag_outlined, color: Colors.orange.shade700, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'الحد الأدنى ${store.minimumOrder.toInt()} ج.س',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 13,
                                  fontFamily: GoogleFonts.cairo().fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(delay: (50 * index).ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
  }
}
