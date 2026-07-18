import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:talabaty_app/core/utils/directional_extensions.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/address_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final user = authProvider.currentUser;
    final addresses = addressProvider.addresses;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, user?.name),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(context, user),
                  const SizedBox(height: 32),
                  
                  if (user != null) ...[
                    _buildSectionHeader('العناوين المحفوظة', () => context.push('/customer/address')),
                    const SizedBox(height: 16),
                    _buildAddressesList(context, addresses, addressProvider),
                    const SizedBox(height: 32),
                  ],

                  _buildSectionHeader('خيارات الحساب', null),
                  const SizedBox(height: 16),
                  _buildOptionsMenu(context),
                  
                  const SizedBox(height: 32),
                  _buildLogoutButton(context, authProvider),
                  
                  const SizedBox(height: 48),
                  const Center(
                    child: Text(
                      'طلباتي\nإصدار 1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String? name) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        title: Text(
          'الملف الشخصي',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontFamily: GoogleFonts.cairo().fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, size: 40, color: AppColors.primaryColor),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'ضيف',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.cairo().fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.phone ?? 'سجل دخولك الآن',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontFamily: GoogleFonts.cairo().fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildSectionHeader(String title, VoidCallback? onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.cairo().fontFamily,
          ),
        ),
        if (onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              'إدارة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ),
          ),
      ],
    ).animate().fade(delay: 100.ms);
  }

  Widget _buildAddressesList(BuildContext context, List addresses, AddressProvider addressProvider) {
    if (addresses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(Icons.location_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'لا توجد عناوين محفوظة',
              style: TextStyle(color: AppColors.textSecondary, fontFamily: GoogleFonts.cairo().fontFamily),
            ),
          ],
        ),
      ).animate().fade(delay: 200.ms);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: addresses.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 60),
        itemBuilder: (context, index) {
          final address = addresses[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.location_on_rounded, color: AppColors.primaryColor, size: 24),
            ),
            title: Text(
              address.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ),
            subtitle: Text(
              '${address.area} - ${address.street}',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: GoogleFonts.cairo().fontFamily),
            ),
            trailing: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
              ),
              onPressed: () {
                addressProvider.removeAddress(address.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف العنوان')));
              },
            ),
          );
        },
      ),
    ).animate().fade(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.receipt_long_rounded, 'طلباتي', Colors.blue, () => context.push('/customer/orders')),
          const Divider(height: 1, indent: 64),
          _buildMenuItem(Icons.favorite_rounded, 'المفضلة', Colors.pink, () => context.push('/customer/favorites')),
          const Divider(height: 1, indent: 64),
          _buildMenuItem(Icons.credit_card_rounded, 'طرق الدفع', Colors.green, () => context.push('/customer/payment-methods')),
          const Divider(height: 1, indent: 64),
          _buildMenuItem(Icons.settings_rounded, 'الإعدادات', Colors.orange, () => context.push('/customer/settings')),
        ],
      ),
    ).animate().fade(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildMenuItem(IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: GoogleFonts.cairo().fontFamily,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          authProvider.logout();
          if (context.mounted) context.go('/login');
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade600),
              const SizedBox(width: 12),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.cairo().fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(delay: 400.ms);
  }
}
