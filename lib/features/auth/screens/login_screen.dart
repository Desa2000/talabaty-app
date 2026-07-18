import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Premium colors defined using HSL for precise visual harmony
  final Color hslPrimary = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.50).toColor(); // #FF6A00 Orange
  final Color hslGradientStart = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.55).toColor();
  final Color hslGradientEnd = HSLColor.fromAHSL(1.0, 12.0, 1.0, 0.50).toColor(); // Darker warm red-orange
  final Color hslCream = HSLColor.fromAHSL(1.0, 25.0, 0.85, 0.97).toColor(); // Extremely soft cream
  final Color hslSoftGray = HSLColor.fromAHSL(1.0, 240.0, 0.05, 0.94).toColor(); // Soft slate grey

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (phone.isEmpty || phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال رقم هاتف صحيح', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال بريد إلكتروني صحيح', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      String formattedPhone = phone;
      if (!phone.startsWith('+')) {
        formattedPhone = phone.startsWith('0') ? '+249${phone.substring(1)}' : '+249$phone';
      }

      await authProvider.sendOtp(
        phone: formattedPhone,
        email: email,
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )
            );
          }
        },
        onCodeSent: () {
          if (mounted) {
            context.push('/otp', extra: {'phone': formattedPhone, 'email': email});
          }
        },
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('خطأ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: Text('حسناً', style: TextStyle(color: hslPrimary, fontWeight: FontWeight.bold))
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: hslCream,
      body: Stack(
        children: [
          // Background aurora light effects (glowing blurred shapes)
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
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header & Logo Container
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: hslPrimary.withValues(alpha: 0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 110,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.shopping_bag_outlined, 
                                  size: 70, 
                                  color: hslPrimary
                                ),
                              ),
                            ).animate().scale(delay: 100.ms, duration: 600.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 24),
                            Text(
                              'أهلاً بك في طلباتي', 
                              style: GoogleFonts.cairo(
                                fontSize: 28, 
                                fontWeight: FontWeight.w900, 
                                color: AppColors.textPrimary,
                              )
                            ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 8),
                            Text(
                              'سجل دخولك لتجربة تسوق فريدة ومميزة', 
                              style: GoogleFonts.cairo(
                                color: AppColors.textSecondary, 
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Premium Inputs Card with Glassmorphic Style
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Phone input field
                            Text(
                              'رقم الهاتف', 
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold, 
                                fontSize: 15, 
                                color: AppColors.textPrimary
                              )
                            ),
                            const SizedBox(height: 10),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                style: GoogleFonts.outfit(
                                  fontSize: 18, 
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: '9XXXXXXX',
                                  hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, letterSpacing: 2),
                                  filled: true,
                                  fillColor: hslSoftGray,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: BorderSide.none
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: BorderSide.none
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: BorderSide(color: hslPrimary, width: 1.5)
                                  ),
                                  prefixIcon: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '+249', 
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w800, 
                                            fontSize: 16, 
                                            color: hslPrimary
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),

                            // Email input field
                            Text(
                              'البريد الإلكتروني', 
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold, 
                                fontSize: 15, 
                                color: AppColors.textPrimary
                              )
                            ),
                            const SizedBox(height: 10),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.ltr,
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'example@email.com',
                                  hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
                                  filled: true,
                                  fillColor: hslSoftGray,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: BorderSide.none
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: BorderSide.none
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: BorderSide(color: hslPrimary, width: 1.5)
                                  ),
                                  prefixIcon: Icon(Icons.email_outlined, color: hslPrimary),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Premium Glowing Continue Button
                            Container(
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [hslGradientStart, hslGradientEnd],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: hslPrimary.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _sendOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24, 
                                        width: 24, 
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                      )
                                    : Text(
                                        'متابعة', 
                                        style: GoogleFonts.cairo(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.bold,
                                        )
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(delay: 400.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'إذا لم يكن لديك حساب، سيتم تحويلك تلقائياً لإنشاء حساب جديد',
                          style: GoogleFonts.cairo(
                            color: AppColors.textSecondary.withValues(alpha: 0.8), 
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fade(delay: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

