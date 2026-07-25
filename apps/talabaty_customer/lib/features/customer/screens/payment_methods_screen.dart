import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            'طرق الدفع المعتمده',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: GoogleFonts.cairo().fontFamily,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Colors.black87,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'خيارات الدفع المتاحة',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: GoogleFonts.cairo().fontFamily,
                ),
              ).animate().fade(delay: 100.ms).slideX(begin: 0.1),
              const SizedBox(height: 16),

              // 1. Cash on Delivery Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.green.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.payments_rounded,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الدفع عند الاستلام (كاش)',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: GoogleFonts.cairo().fontFamily,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تسليم المبلغ نقداً للمندوب فور وصول الطلب',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontFamily: GoogleFonts.cairo().fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 20),

              // 2. Bankak Payment Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFF5722).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5722).withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFF5722,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFFFF5722),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تحويل تطبيق بنكك (Bankak)',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: GoogleFonts.cairo().fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'تحويل مباشر مالي وتدقيق يدوي عبر الإدارة',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontFamily: GoogleFonts.cairo().fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFFFF5722),
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Bankak Account Details Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              context,
                              label: 'رقم الحساب',
                              value: '2391651',
                              isCopyable: true,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              context,
                              label: 'اسم صاحب الحساب',
                              value: 'المدثر عامر الفاضل',
                              isCopyable: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'عند اختيار بنكك أثناء إتمام الطلب، يرجى إدخال آخر 4 أرقام من رقم عملية التحويل لتسهيل مراجعة الحسابات وتأكيد الطلب.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          height: 1.5,
                          fontFamily: GoogleFonts.cairo().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required bool isCopyable,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.cairo().fontFamily,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: const Color(0xFF111111),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ),
            if (isCopyable) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: Color(0xFFFF5722),
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ رقم الحساب بنجاح'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}
