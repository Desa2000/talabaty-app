import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/constants/enums.dart';
import '../../../data/models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // HSL Premium Colors
  final Color hslPrimary = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.50).toColor(); // Orange
  final Color hslCream = HSLColor.fromAHSL(1.0, 25.0, 0.85, 0.97).toColor(); // Soft cream

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    
    // Wait for splash animation and check authentication
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      authProvider.checkAuthStatus(),
    ]);

    if (!mounted) return;
    
    // devAutoLogin has been disabled to allow real backend auth flow testing.
    
    if (authProvider.isAuthenticated) {
      try { context.read<NotificationProvider>().initFCM(); } catch (_) {}
      
      final role = authProvider.currentUser!.role;
      if (role == UserRole.customer) context.go('/customer');
      else if (role == UserRole.courier) context.go('/courier');
      else if (role == UserRole.merchant) context.go('/merchant');
      else if (role == UserRole.admin) context.go('/admin');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hslCream,
      body: Stack(
        children: [
          // Aurora gradient lights
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hslPrimary.withValues(alpha: 0.12),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2500.ms, curve: Curves.easeInOut),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HSLColor.fromAHSL(1.0, 45.0, 1.0, 0.50).toColor().withValues(alpha: 0.06),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 3000.ms, curve: Curves.easeInOut),
          ),

          // Grid decorative pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.02,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                ),
                itemBuilder: (context, index) => const Icon(Icons.fastfood_rounded, color: Colors.black),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _animation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: hslPrimary.withValues(alpha: 0.12),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.shopping_bag_rounded, size: 120, color: hslPrimary),
                              Positioned(
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
                                    ],
                                  ),
                                  child: Icon(Icons.delivery_dining_rounded, size: 45, color: hslPrimary),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'طلباتي',
                    style: GoogleFonts.cairo(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0, duration: 600.ms),
                  const SizedBox(height: 16),
                  Text(
                    'أسرع تطبيق توصيل في السودان يربطك بمختلف المطاعم، المتاجر، الصيدليات، والسوبرماركت... بكل سهولة وأمان.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0, duration: 600.ms),
                  const SizedBox(height: 48),
                  
                  // Sleek Custom Linear Progress Indicator
                  Container(
                    width: 140,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        color: hslPrimary,
                      ),
                    ),
                  ).animate().fade(delay: 700.ms),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_rounded, color: hslPrimary, size: 18)
                    .animate(onPlay: (c) => c.repeat())
                    .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 800.ms, curve: Curves.easeInOut),
                const SizedBox(width: 8),
                Text(
                  'صُنع في السودان', 
                  style: GoogleFonts.cairo(
                    color: AppColors.textSecondary, 
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )
                ),
              ],
            ).animate().fade(delay: 800.ms),
          ),
        ],
      ),
    );
  }
}
