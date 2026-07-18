import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'tabs/courier_jobs_tab.dart';
import 'tabs/courier_earnings_tab.dart';
import 'tabs/courier_profile_tab.dart';

class CourierMainScreen extends StatefulWidget {
  const CourierMainScreen({super.key});

  @override
  State<CourierMainScreen> createState() => _CourierMainScreenState();
}

class _CourierMainScreenState extends State<CourierMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    CourierJobsTab(),
    CourierEarningsTab(),
    CourierProfileTab(),
  ];

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final primaryColor = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.50).toColor(); // Orange HSL
    
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: 250.ms,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    color: isSelected ? primaryColor : Colors.grey.shade500,
                    size: 22,
                  ).animate(target: isSelected ? 1.0 : 0.0)
                   .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 200.ms, curve: Curves.easeOutBack),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ).animate().fade(duration: 150.ms).slideX(begin: 0.1, end: 0, duration: 150.ms),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom > 24 ? 12 : MediaQuery.of(context).padding.bottom,
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderGray, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.radar_rounded, Icons.radar_outlined, 'الطلبات'),
                _buildNavItem(1, Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'المحفظة'),
                _buildNavItem(2, Icons.person_rounded, Icons.person_outline_rounded, 'حسابي'),
              ],
            ),
          ),
        ),
      ).animate().slideY(begin: 1.0, end: 0, duration: 600.ms, curve: Curves.easeOutExpo),
    );
  }
}

