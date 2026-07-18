import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dataProvider = context.watch<DataProvider>();
    
    final allOrders = dataProvider.orders;
    final pendingOrders = allOrders.where((o) => o.status == OrderStatus.pending).length;
    final totalSales = allOrders.where((o) => o.status == OrderStatus.delivered).fold(0.0, (sum, o) => sum + o.total);
    final restaurantCount = dataProvider.stores.where((s) => s.type == StoreType.restaurant).length;
    final supermarketCount = dataProvider.stores.where((s) => s.type == StoreType.supermarket).length;
    final pharmacyCount = dataProvider.stores.where((s) => s.type == StoreType.pharmacy).length;
    final availableCouriers = dataProvider.couriers.where((c) => c.status == CourierStatus.available).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () {
            auth.logout();
            context.go('/login');
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            Row(
              children: [
                Expanded(child: _StatCard(title: 'الطلبات', value: '${allOrders.length}', icon: Icons.shopping_bag, color: Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(title: 'المبيعات', value: '$totalSales', icon: Icons.attach_money, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'المطاعم', value: '$restaurantCount', icon: Icons.restaurant, color: Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(title: 'السوبرماركتات', value: '$supermarketCount', icon: Icons.shopping_cart, color: Colors.indigo)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'الصيدليات', value: '$pharmacyCount', icon: Icons.local_pharmacy, color: Colors.blueAccent)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(title: 'المناديب (متاح)', value: '$availableCouriers', icon: Icons.motorcycle, color: Colors.teal)),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text('الإدارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                _ActionCard(title: 'جميع الطلبات', icon: Icons.list_alt, onTap: () => context.push('/admin/orders')),
                _ActionCard(title: 'إدارة المتاجر', icon: Icons.storefront, onTap: () => context.push('/admin/merchants')),
                _ActionCard(title: 'إدارة المناديب', icon: Icons.people, onTap: () => context.push('/admin/couriers')),
                _ActionCard(title: 'التقارير', icon: Icons.bar_chart, onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('التقارير قيد التطوير')));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primaryColor),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
