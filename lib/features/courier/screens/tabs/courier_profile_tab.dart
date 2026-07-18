import 'package:flutter/material.dart';
import 'package:talabaty_app/core/utils/directional_extensions.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/data_provider.dart';
import '../../../../core/constants/enums.dart';
import '../../../../data/models/user_model.dart';

class CourierProfileTab extends StatelessWidget {
  const CourierProfileTab({super.key});

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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('حسابي'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                    backgroundImage: courierUser.profileImage != null && courierUser.profileImage!.startsWith('http')
                        ? NetworkImage(courierUser.profileImage!)
                        : null,
                    child: courierUser.profileImage == null || !courierUser.profileImage!.startsWith('http')
                        ? const Icon(Icons.person_rounded, size: 50, color: AppColors.primaryColor)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(courierUser.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text('${courier.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text(' (120 تقييم)', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Vehicle Info
            const Align(alignment: Alignment.centerRight, child: Text('معلومات المركبة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildProfileItem(context, Icons.motorcycle, 'نوع المركبة', courier.vehicleType == VehicleType.motorcycle ? 'دراجة نارية' : 'سيارة'),
                  const Divider(height: 1),
                  _buildProfileItem(context, Icons.pin, 'رقم اللوحة', courier.vehiclePlate ?? 'غير متوفر'),
                  const Divider(height: 1),
                  _buildProfileItem(context, Icons.color_lens, 'لون المركبة', courier.vehicleColor ?? 'غير متوفر'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Settings Links
            const Align(alignment: Alignment.centerRight, child: Text('الإعدادات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildProfileItem(context, Icons.notifications_outlined, 'الإشعارات', null, isLink: true),
                  const Divider(height: 1),
                  _buildProfileItem(context, Icons.language, 'اللغة', 'العربية', isLink: true),
                  const Divider(height: 1),
                  _buildProfileItem(context, Icons.help_outline, 'الدعم الفني', null, isLink: true),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Logout
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () {
                  auth.logout();
                  context.go('/login');
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, String? subtitle, {bool isLink = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: isLink 
          ? Icon(context.forwardIconIos, size: 16, color: Colors.grey)
          : (subtitle != null ? Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)) : null),
      onTap: isLink ? () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً: عرض التفاصيل')));
      } : null,
    );
  }
}
