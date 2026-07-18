import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/providers/data_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/product_provider.dart';

class MerchantDashboardTab extends StatefulWidget {
  const MerchantDashboardTab({super.key});

  @override
  State<MerchantDashboardTab> createState() => _MerchantDashboardTabState();
}

class _MerchantDashboardTabState extends State<MerchantDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        final storeId = 'store_${auth.currentUser!.id}';
        context.read<ProductProvider>().loadMerchantProducts(storeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) return const SizedBox();
    
    final dataProvider = context.watch<DataProvider>();
    
    final orders = dataProvider.getOrdersForMerchant(auth.currentUser?.id ?? 'none');
    final pendingCount = orders.where((o) => o.status == OrderStatus.pending).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          'مرحباً، ${auth.currentUser?.name ?? 'التاجر'} 👋',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () {
              auth.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ Premium Stats Grid
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _GradientStatCard(
                            title: 'طلبات جديدة',
                            value: '$pendingCount',
                            icon: Icons.shopping_bag_rounded,
                            gradientColors: const [Color(0xFFFF6A00), Color(0xFFFFAB00)],
                            shadowColor: Color(0xFFFF6A00),
                          ).animate().fade(duration: 400.ms).slideY(begin: 0.15, end: 0),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _GradientStatCard(
                            title: 'إجمالي المنتجات',
                            value: '${productProvider.totalProducts}',
                            icon: Icons.fastfood_rounded,
                            gradientColors: const [Color(0xFF1565C0), Color(0xFF29B6F6)],
                            shadowColor: Color(0xFF1565C0),
                          ).animate().fade(duration: 400.ms, delay: 80.ms).slideY(begin: 0.15, end: 0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _GradientStatCard(
                            title: 'متاح',
                            value: '${productProvider.availableProducts}',
                            icon: Icons.check_circle_rounded,
                            gradientColors: const [Color(0xFF1B5E20), Color(0xFF43A047)],
                            shadowColor: Color(0xFF1B5E20),
                          ).animate().fade(duration: 400.ms, delay: 160.ms).slideY(begin: 0.15, end: 0),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _GradientStatCard(
                            title: 'نفد المخزون',
                            value: '${productProvider.outOfStockProducts}',
                            icon: Icons.remove_shopping_cart_rounded,
                            gradientColors: const [Color(0xFFB71C1C), Color(0xFFEF5350)],
                            shadowColor: Color(0xFFB71C1C),
                          ).animate().fade(duration: 400.ms, delay: 240.ms).slideY(begin: 0.15, end: 0),
                        ),
                      ],
                    ),
                    if (productProvider.lowStockProducts > 0) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade50, Colors.amber.shade50],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.shade300, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'لديك ${productProvider.lowStockProducts} منتجات مخزونها منخفض!',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]
                  ],
                );
              }
            ),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إدارة المتجر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Cairo',
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryColor, Color(0xFFFFAB00)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/merchant/products/add'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'إضافة منتج',
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            const Text(
              'الأقسام السريعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick Actions
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _ActionCard(title: 'الطلبات', icon: Icons.list_alt, onTap: () => context.push('/merchant/orders')),
                _ActionCard(title: 'المنتجات', icon: Icons.inventory_2, onTap: () => context.push('/merchant/products')),
                _ActionCard(title: 'نقطة البيع POS', icon: Icons.point_of_sale, onTap: () => context.push('/merchant/pos')),
                _ActionCard(title: 'المخزون', icon: Icons.storefront, onTap: () => context.push('/merchant/inventory')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium gradient stat card — replaces the old flat _StatCard
class _GradientStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final Color shadowColor;

  const _GradientStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.38),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Cairo',
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.6), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
