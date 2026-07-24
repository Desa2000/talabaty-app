import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/constants/enums.dart';

class RegisterScreen extends StatefulWidget {
  final String phone;
  final String email;
  const RegisterScreen({super.key, required this.phone, required this.email});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _ownerNameController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _areaController = TextEditingController();
  StoreType _selectedStoreType = StoreType.restaurant;
  bool _isLoading = false;

  final Color hslPrimary = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.50).toColor();
  final Color hslGradientStart = HSLColor.fromAHSL(
    1.0,
    25.0,
    1.0,
    0.55,
  ).toColor();
  final Color hslGradientEnd = HSLColor.fromAHSL(
    1.0,
    12.0,
    1.0,
    0.50,
  ).toColor();
  final Color hslCream = HSLColor.fromAHSL(1.0, 25.0, 0.85, 0.97).toColor();
  final Color hslSoftGray = HSLColor.fromAHSL(1.0, 240.0, 0.05, 0.94).toColor();

  @override
  void dispose() {
    _ownerNameController.dispose();
    _storeNameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_ownerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إدخال اسم صاحب المتجر',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_storeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إدخال اسم المتجر / التجاري',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.register(
        name: _ownerNameController.text.trim(),
        phone: widget.phone,
        email: widget.email,
        role: UserRole.merchant,
        businessName: _storeNameController.text.trim(),
        storeName: _storeNameController.text.trim(),
        storeCategory: _selectedStoreType.name.toUpperCase(),
      );

      if (mounted) {
        context.read<NotificationProvider>().initFCM();
        setState(() => _isLoading = false);
        context.go('/merchant');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: hslSoftGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cairo(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: readOnly ? Colors.grey : hslPrimary,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hslCream,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [hslGradientStart, hslGradientEnd],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: hslPrimary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'تسجيل تاجر / متجر جديد',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fade().slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  Text(
                    'سجل متجرك في منصة طلباتي واستقبل طلبات العملاء مباشرة',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.2),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _storeNameController,
                    hintText: 'اسم المتجر / التجاري',
                    icon: Icons.storefront_rounded,
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ownerNameController,
                    hintText: 'اسم صاحب المتجر',
                    icon: Icons.person_outline_rounded,
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: TextEditingController(text: widget.phone),
                    hintText: 'رقم الهاتف للتواصل',
                    icon: Icons.phone_android_rounded,
                    readOnly: true,
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: TextEditingController(text: widget.email),
                    hintText: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    readOnly: true,
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  Text(
                    'نوع النشاط التجاري',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: hslSoftGray,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<StoreType>(
                        value: _selectedStoreType,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: hslPrimary,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: StoreType.restaurant,
                            child: Text('مطعم / كافيه'),
                          ),
                          DropdownMenuItem(
                            value: StoreType.supermarket,
                            child: Text('سوبرماركت / بقالة'),
                          ),
                          DropdownMenuItem(
                            value: StoreType.pharmacy,
                            child: Text('صيدلية'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null)
                            setState(() => _selectedStoreType = val);
                        },
                      ),
                    ),
                  ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _areaController,
                    hintText: 'المنطقة / الحي (الخرطوم / بحري / أم درمان)',
                    icon: Icons.location_on_outlined,
                  ).animate().fade(delay: 700.ms).slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [hslGradientStart, hslGradientEnd],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: hslPrimary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'إكمال تسجيل المتجر',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ).animate().fade(delay: 800.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
