import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _currentLanguage = 'العربية';
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _currentLanguage = prefs.getString('language') ?? 'العربية';
      _locationEnabled = prefs.getBool('location_enabled') ?? true;
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111111)),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'الإعدادات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Color(0xFF111111),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Account Section
            _buildSectionHeader('الحساب'),
            _buildSettingsTile(
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.primaryColor,
              title: 'الملف الشخصي',
              subtitle: 'تعديل بياناتك الشخصية',
              onTap: () => context.push('/customer/profile'),
            ),
            _buildSettingsTile(
              icon: Icons.location_on_outlined,
              iconColor: Colors.blue,
              title: 'العناوين المحفوظة',
              subtitle: 'إدارة عناوين التوصيل',
              onTap: () => context.push('/customer/address'),
            ),
            _buildSettingsTile(
              icon: Icons.payment_outlined,
              iconColor: Colors.green,
              title: 'طرق الدفع',
              subtitle: 'إدارة بطاقاتك ومحافظك',
              onTap: () => context.push('/customer/payment-methods'),
            ),
            const SizedBox(height: 16),

            // Preferences Section
            _buildSectionHeader('التفضيلات'),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              iconColor: Colors.orange,
              title: 'الإشعارات',
              subtitle: 'استقبال إشعارات الطلبات والعروض',
              value: _notificationsEnabled,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
                _savePreference('notifications_enabled', v);
              },
            ),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              iconColor: const Color(0xFF5C6BC0),
              title: 'الوضع الليلي',
              subtitle: 'تقليل إجهاد العينين في الليل',
              value: _darkModeEnabled,
              onChanged: (v) {
                setState(() => _darkModeEnabled = v);
                _savePreference('dark_mode_enabled', v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(v ? '🌙 تم تفعيل الوضع الليلي' : '☀️ تم تفعيل الوضع النهاري'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primaryColor,
                  ),
                );
              },
            ),
            _buildSwitchTile(
              icon: Icons.location_on_outlined,
              iconColor: Colors.red,
              title: 'الموقع الجغرافي',
              subtitle: 'السماح للتطبيق بالوصول لموقعك',
              value: _locationEnabled,
              onChanged: (v) {
                setState(() => _locationEnabled = v);
                _savePreference('location_enabled', v);
              },
            ),
            _buildSettingsTile(
              icon: Icons.language_outlined,
              iconColor: Colors.teal,
              title: 'اللغة',
              subtitle: _currentLanguage,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _currentLanguage == 'العربية' ? '🇸🇦 عربي' : '🇬🇧 English',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: _showLanguageDialog,
            ),
            const SizedBox(height: 16),

            // About Section
            _buildSectionHeader('حول التطبيق'),
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: Colors.blueGrey,
              title: 'إصدار التطبيق',
              subtitle: 'الإصدار 1.0.0',
            ),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: Colors.indigo,
              title: 'سياسة الخصوصية',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              iconColor: Colors.deepPurple,
              title: 'الشروط والأحكام',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.headset_mic_outlined,
              iconColor: Colors.cyan,
              title: 'الدعم الفني',
              subtitle: 'تواصل مع فريق الدعم',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً: خدمة الدعم الفني'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            const SizedBox(height: 16),

            // Logout
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Colors.red),
                ),
                title: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                onTap: () => _showLogoutDialog(context),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w900,
          fontSize: 18,
          color: Color(0xFF111111),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Color(0xFF111111),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Color(0xFF888888),
                  fontSize: 13,
                ),
              )
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF888888))
                : null),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Color(0xFF111111),
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888), fontSize: 13))
            : null,
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر لغة التطبيق',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              _buildLangOption(ctx, 'العربية', '🇸🇦'),
              const SizedBox(height: 12),
              _buildLangOption(ctx, 'English', '🇬🇧'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangOption(BuildContext ctx, String lang, String flag) {
    final isSelected = _currentLanguage == lang;
    return InkWell(
      onTap: () {
        setState(() => _currentLanguage = lang);
        _savePreference('language', lang);
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تغيير اللغة إلى $lang'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryColor,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? AppColors.primaryColor.withOpacity(0.08) : Colors.grey.shade50,
          border: isSelected ? Border.all(color: AppColors.primaryColor, width: 2) : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(
              lang,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isSelected ? AppColors.primaryColor : const Color(0xFF111111),
              ),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900)),
          content: const Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
            style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF555555)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF555555))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await context.read<AuthProvider>().logout();
                if (context.mounted) context.go('/login');
              },
              child: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
