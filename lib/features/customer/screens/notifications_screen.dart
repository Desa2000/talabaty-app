import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'الإشعارات',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontFamily: GoogleFonts.cairo().fontFamily,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton.icon(
                onPressed: () {
                  notificationProvider.clearAll();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح جميع الإشعارات')));
                },
                icon: Icon(Icons.clear_all_rounded, color: Colors.red.shade400, size: 20),
                label: Text('مسح الكل', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.cairo().fontFamily)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryColor.withValues(alpha: 0.1), blurRadius: 40)
                      ]
                    ),
                    child: Icon(Icons.notifications_active_outlined, size: 80, color: AppColors.primaryColor.withValues(alpha: 0.5)),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 32),
                  Text(
                    'لا توجد إشعارات حالياً',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: GoogleFonts.cairo().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ستصلك إشعارات عند تحديث حالة طلباتك',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontFamily: GoogleFonts.cairo().fontFamily,
                    ),
                  ),
                ],
              ).animate().fade(),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        // Might mark as read
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                notification.icon ?? Icons.notifications_active_rounded,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.title,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily: GoogleFonts.cairo().fontFamily,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'الآن', // Can format time if notification model has timestamp
                                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    notification.body,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      height: 1.4,
                                      fontFamily: GoogleFonts.cairo().fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fade(delay: (50 * index).ms).slideY(begin: 0.1);
              },
            ),
    );
  }
}
