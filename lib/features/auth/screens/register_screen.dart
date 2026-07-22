import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_provider.dart';
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
  // Common Fields
  final _nameController = TextEditingController();
  UserRole _selectedRole = UserRole.customer;

  // Courier Fields
  VehicleType _selectedVehicle = VehicleType.motorcycle;
  final _licensePlateController = TextEditingController();
  final _idNumberController = TextEditingController();

  // Merchant Fields
  final _businessNameController = TextEditingController();
  final _businessDescController = TextEditingController();
  StoreType _selectedStoreType = StoreType.restaurant;
  final _businessAreaController = TextEditingController();
  XFile? _storeLogo;

  bool _isLoading = false;

  final Color hslPrimary = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.50).toColor();
  final Color hslGradientStart = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.55).toColor();
  final Color hslGradientEnd = HSLColor.fromAHSL(1.0, 12.0, 1.0, 0.50).toColor();
  final Color hslCream = HSLColor.fromAHSL(1.0, 25.0, 0.85, 0.97).toColor();
  final Color hslSoftGray = HSLColor.fromAHSL(1.0, 240.0, 0.05, 0.94).toColor();

  Future<void> _register() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('الرجاء كتابة الاسم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.register(
        name: _nameController.text.trim(),
        phone: widget.phone,
        email: widget.email,
        role: _selectedRole,
        businessName: _businessNameController.text.trim(),
        storeName: _businessNameController.text.trim().isNotEmpty
            ? _businessNameController.text.trim()
            : 'مطعم ${_nameController.text.trim()}',
        storeCategory: _selectedStoreType.name.toUpperCase(),
        vehicleType: _selectedVehicle.name.toUpperCase(),
        licenseNumber: _licensePlateController.text.trim(),
      );
      
      if (mounted) {
        context.read<NotificationProvider>().initFCM();
      }

      setState(() => _isLoading = false);

      if (mounted) {
        if (_selectedRole == UserRole.customer) context.go('/customer');
        else if (_selectedRole == UserRole.courier) context.go('/courier');
        else if (_selectedRole == UserRole.merchant) context.go('/merchant');
        else if (_selectedRole == UserRole.admin) context.go('/admin');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: GoogleFonts.cairo(fontWeight: FontWeight.bold)), backgroundColor: AppColors.error));
      }
    }
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: hslPrimary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: hslPrimary, width: 1.5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hslCream,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hslPrimary.withValues(alpha: 0.15),
              ),
            ).animate().fade(duration: 1000.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), curve: Curves.easeInOut),
          ),
          Positioned(
            bottom: -150,
            left: -120,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hslGradientEnd.withValues(alpha: 0.08),
              ),
            ).animate().fade(duration: 1200.ms, delay: 200.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), curve: Curves.easeInOut),
          ),
          SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                      ],
                    ),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: hslPrimary.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 10))
                              ],
                            ),
                            child: Icon(Icons.verified_user_rounded, size: 64, color: hslPrimary),
                          ).animate().scale(delay: 100.ms, duration: 600.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 16),
                          Text('تم توثيق الرقم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)).animate().fade(delay: 200.ms),
                          Text(widget.phone, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)).animate().fade(delay: 200.ms),
                          const SizedBox(height: 8),
                          Text('أهلاً بك! لنكمل إنشاء حسابك', style: GoogleFonts.cairo(color: AppColors.textSecondary)).animate().fade(delay: 300.ms),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text('اختر نوع الحساب', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)).animate().fade(delay: 400.ms),
                    const SizedBox(height: 12),
                    SegmentedButton<UserRole>(
                      segments: [
                        ButtonSegment(value: UserRole.customer, label: Text('عميل', style: GoogleFonts.cairo()), icon: const Icon(Icons.person)),
                        ButtonSegment(value: UserRole.courier, label: Text('مندوب', style: GoogleFonts.cairo()), icon: const Icon(Icons.motorcycle)),
                        ButtonSegment(value: UserRole.merchant, label: Text('تاجر', style: GoogleFonts.cairo()), icon: const Icon(Icons.store)),
                      ],
                      selected: {_selectedRole},
                      style: SegmentedButton.styleFrom(
                        selectedForegroundColor: Colors.white,
                        selectedBackgroundColor: hslPrimary,
                      ),
                      onSelectionChanged: (Set<UserRole> newSelection) {
                        setState(() {
                          _selectedRole = newSelection.first;
                        });
                      },
                    ).animate().fade(delay: 450.ms),
                    const SizedBox(height: 32),
                    
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 12))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('الاسم الكامل', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 10),
                          _buildPremiumTextField(
                            controller: _nameController,
                            hintText: _selectedRole == UserRole.merchant ? 'اسم مالك المتجر' : 'اسمك الثلاثي',
                            icon: Icons.person_outline,
                          ),
                          
                          if (_selectedRole == UserRole.courier) ...[
                            const SizedBox(height: 24),
                            Text('معلومات المركبة (اختياري)', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: DropdownButtonFormField<VehicleType>(
                                value: _selectedVehicle,
                                style: GoogleFonts.cairo(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                                  prefixIcon: Icon(Icons.directions_car_outlined, color: hslPrimary),
                                ),
                                items: [
                                  DropdownMenuItem(value: VehicleType.motorcycle, child: Text('دراجة نارية (مواتر)', style: GoogleFonts.cairo())),
                                  DropdownMenuItem(value: VehicleType.car, child: Text('سيارة', style: GoogleFonts.cairo())),
                                  DropdownMenuItem(value: VehicleType.bicycle, child: Text('دراجة هوائية', style: GoogleFonts.cairo())),
                                ],
                                onChanged: (val) => setState(() => _selectedVehicle = val!),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPremiumTextField(controller: _licensePlateController, hintText: 'رقم اللوحة', icon: Icons.pin_outlined),
                          ],

                          if (_selectedRole == UserRole.merchant) ...[
                            const SizedBox(height: 24),
                            Text('معلومات المتجر (اختياري الآن)', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final pickedImage = await picker.pickImage(source: ImageSource.gallery);
                                  if (pickedImage != null) {
                                    setState(() {
                                      _storeLogo = pickedImage;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: hslSoftGray,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: hslPrimary.withValues(alpha: 0.3), width: 2),
                                    image: _storeLogo != null ? DecorationImage(image: FileImage(File(_storeLogo!.path)), fit: BoxFit.cover) : null,
                                  ),
                                  child: _storeLogo == null ? Icon(Icons.add_a_photo_outlined, size: 30, color: hslPrimary) : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPremiumTextField(controller: _businessNameController, hintText: 'اسم النشاط التجاري', icon: Icons.storefront_outlined),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: DropdownButtonFormField<StoreType>(
                                value: _selectedStoreType,
                                style: GoogleFonts.cairo(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                                  prefixIcon: Icon(Icons.category_outlined, color: hslPrimary),
                                ),
                                items: [
                                  DropdownMenuItem(value: StoreType.restaurant, child: Text('مطعم', style: GoogleFonts.cairo())),
                                  DropdownMenuItem(value: StoreType.supermarket, child: Text('سوبرماركت', style: GoogleFonts.cairo())),
                                  DropdownMenuItem(value: StoreType.pharmacy, child: Text('صيدلية', style: GoogleFonts.cairo())),
                                ],
                                onChanged: (val) => setState(() => _selectedStoreType = val!),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),
                          Container(
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(colors: [hslGradientStart, hslGradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              boxShadow: [BoxShadow(color: hslPrimary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text('دخول', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

