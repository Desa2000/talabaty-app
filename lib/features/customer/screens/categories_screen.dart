import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/constants/enums.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final stores = dataProvider.stores;

    final restaurantCount = stores.where((s) => s.type == StoreType.restaurant).length;
    final supermarketCount = stores.where((s) => s.type == StoreType.supermarket).length;
    final pharmacyCount = stores.where((s) => s.type == StoreType.pharmacy).length;
    final giftCount = stores.where((s) => s.type == StoreType.gift).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCategoryCard(
                    context,
                    title: 'المطاعم',
                    description: 'أشهى المأكولات وأسرع توصيل',
                    icon: Icons.restaurant_rounded,
                    color: const Color(0xFFFF8C00),
                    storeCount: restaurantCount,
                    route: '/customer/stores/restaurant',
                    index: 0,
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'السوبرماركت',
                    description: 'مقاضي البيت ومستلزمات يومية',
                    icon: Icons.local_grocery_store_rounded,
                    color: const Color(0xFF4CAF50),
                    storeCount: supermarketCount,
                    route: '/customer/stores/supermarket',
                    index: 1,
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'الصيدليات',
                    description: 'أدوية ومستلزمات طبية',
                    icon: Icons.local_pharmacy_rounded,
                    color: const Color(0xFF2196F3),
                    storeCount: pharmacyCount,
                    route: '/customer/stores/pharmacy',
                    index: 2,
                  ),
                  _buildCategoryCard(
                    context,
                    title: 'الهدايا',
                    description: 'هدايا وباقات ورد لكل المناسبات',
                    icon: Icons.card_giftcard_rounded,
                    color: const Color(0xFFE91E63),
                    storeCount: giftCount,
                    route: '/customer/stores/gift',
                    index: 3,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
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
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        title: Text(
          'التصنيفات',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            fontFamily: GoogleFonts.cairo().fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required int storeCount,
    required String route,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push(route),
          child: Stack(
            children: [
              Positioned(
                left: -20,
                bottom: -20,
                child: Icon(icon, size: 120, color: color.withValues(alpha: 0.05)),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, size: 36, color: color),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              fontFamily: GoogleFonts.cairo().fontFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontFamily: GoogleFonts.cairo().fontFamily,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$storeCount',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'متجر متوفر',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: GoogleFonts.cairo().fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutBack);
  }
}
