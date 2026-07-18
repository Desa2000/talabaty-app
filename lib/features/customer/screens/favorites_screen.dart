import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/data_provider.dart';
import '../../../data/models/store_model.dart';
import '../../../core/widgets/custom_image.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    // For now, take first 2 stores as favorites for demonstration
    final favoriteStores = dataProvider.stores.take(2).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'المفضلة',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontFamily: GoogleFonts.cairo().fontFamily,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: favoriteStores.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: favoriteStores.length,
              itemBuilder: (context, index) {
                final store = favoriteStores[index];
                return _buildFavoriteCard(store, context, index);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primaryColor.withValues(alpha: 0.1), blurRadius: 40)
              ]
            ),
            child: const Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.primaryColor),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          Text(
            'لا توجد مطاعم في المفضلة',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: GoogleFonts.cairo().fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'استكشف المطاعم المفضلة لديك وأضفها هنا!',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontFamily: GoogleFonts.cairo().fontFamily,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/customer/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              'تصفح المطاعم',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
        ],
      ),
    ).animate().fade();
  }

  Widget _buildFavoriteCard(StoreModel store, BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
          onTap: () => context.push('/customer/store/${store.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'fav_cover_${store.id}',
                child: Container(
                  height: 140,
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
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.favorite_rounded, color: Colors.pink, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إزالة المطعم من المفضلة')));
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
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
                              Icon(Icons.delivery_dining_rounded, color: AppColors.primaryColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${store.deliveryFee.toInt()} ج.س',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
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
    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
  }
}
