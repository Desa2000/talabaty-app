import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/directional_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/constants/enums.dart';
import 'dart:async';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String email;
  const OtpScreen({super.key, required this.phone, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _resendTimer = 60;
  Timer? _timer;

  // Premium HSL-derived colors matching login screen
  final Color hslPrimary = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.50).toColor(); // #FF6A00 Orange
  final Color hslGradientStart = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.55).toColor();
  final Color hslGradientEnd = HSLColor.fromAHSL(1.0, 12.0, 1.0, 0.50).toColor();
  final Color hslCream = HSLColor.fromAHSL(1.0, 25.0, 0.85, 0.97).toColor();
  final Color hslSoftGray = HSLColor.fromAHSL(1.0, 240.0, 0.05, 0.94).toColor();

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال الرمز المكون من 4 أرقام على الأقل', style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        )
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      bool hasError = false;
      final role = await authProvider.verifyOtp(
        otp,
        onError: (error) {
          hasError = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error, style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )
            );
          }
        },
      );
      
      if (hasError) return;

      if (mounted && role != null) {
        context.read<NotificationProvider>().initFCM();

        if (role == UserRole.customer) context.go('/customer');
        else if (role == UserRole.courier) context.go('/courier');
        else if (role == UserRole.merchant) context.go('/merchant');
        else context.go('/customer'); // fallback
      } else if (mounted) {
        context.go('/register', extra: {'phone': widget.phone, 'email': widget.email});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: hslCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(context.backIcon, color: AppColors.textPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background aurora light effects
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hslPrimary.withValues(alpha: 0.12),
              ),
            ).animate().fade(duration: 1000.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hslGradientEnd.withValues(alpha: 0.08),
              ),
            ).animate().fade(duration: 1200.ms, delay: 200.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
          ),

          SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'رمز التحقق', 
                        style: GoogleFonts.cairo(
                          fontSize: 28, 
                          fontWeight: FontWeight.w900, 
                          color: AppColors.textPrimary
                        )
                      ).animate().fade().slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 10),
                      Text(
                        'لقد أرسلنا رمز التحقق المكون من 6 أرقام إلى بريدك الإلكتروني:\n${widget.email}', 
                        style: GoogleFonts.cairo(
                          color: AppColors.textSecondary, 
                          height: 1.5,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )
                      ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 40),

                      // Premium Input Card
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            // Styled PIN Inputs Row (hidden field + styled boxes)
                            GestureDetector(
                              onTap: () => _focusNode.requestFocus(),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Opacity(
                                    opacity: 0,
                                    child: SizedBox(
                                      height: 56,
                                      child: TextField(
                                        controller: _otpController,
                                        focusNode: _focusNode,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        onChanged: (val) {
                                          setState(() {});
                                          if (val.length == 6) {
                                            _verifyOtp();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: List.generate(6, (index) {
                                        final text = _otpController.text;
                                        final isFocused = _focusNode.hasFocus && text.length == index;
                                        final hasValue = index < text.length;
                                        final digit = hasValue ? text[index] : '';

                                        return Container(
                                          width: 44,
                                          height: 52,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: hslSoftGray,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: isFocused
                                                  ? hslPrimary
                                                  : (hasValue ? hslPrimary.withValues(alpha: 0.4) : Colors.transparent),
                                              width: isFocused ? 2 : 1.5,
                                            ),
                                            boxShadow: isFocused
                                                ? [
                                                    BoxShadow(
                                                      color: hslPrimary.withValues(alpha: 0.1),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 3),
                                                    )
                                                  ]
                                                : [],
                                          ),
                                          child: Text(
                                            digit,
                                            style: GoogleFonts.cairo(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ).animate(target: isFocused ? 1.0 : 0.0)
                                         .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 150.ms);
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Countdown timer and Resend button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timer_outlined, size: 16, color: _resendTimer > 0 ? Colors.grey : hslPrimary),
                                const SizedBox(width: 6),
                                _resendTimer > 0 
                                  ? Text(
                                      'إعادة الإرسال خلال $_resendTimer ثانية', 
                                      style: GoogleFonts.cairo(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12)
                                    )
                                  : TextButton(
                                      onPressed: () {
                                        setState(() => _resendTimer = 60);
                                        _startTimer();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('تم إعادة إرسال الكود بنجاح', style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14)),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          )
                                        );
                                      },
                                      child: Text(
                                        'أعد إرسال الرمز الآن', 
                                        style: GoogleFonts.cairo(color: hslPrimary, fontWeight: FontWeight.w800, fontSize: 13)
                                      ),
                                    ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Glowing Verify Button
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
                                onPressed: isLoading ? null : _verifyOtp,
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
                                        'تأكيد الكود', 
                                        style: GoogleFonts.cairo(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.bold,
                                        )
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(delay: 200.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),
                      
                      // Demo credential notice styled nicely
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade200.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'للتجربة السريعة: أدخل الرمز 1234', 
                              style: GoogleFonts.cairo(
                                color: Colors.amber.shade900, 
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              )
                            ),
                          ],
                        ),
                      ).animate().fade(delay: 400.ms),
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

