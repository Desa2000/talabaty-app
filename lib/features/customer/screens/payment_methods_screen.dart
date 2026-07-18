import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/payment_provider.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    final cards = paymentProvider.cards;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'طرق الدفع',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البطاقات المحفوظة',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ).animate().fade(delay: 100.ms).slideX(begin: 0.1),
            const SizedBox(height: 16),
            
            if (cards.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.credit_card_off_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد بطاقات محفوظة',
                      style: TextStyle(color: AppColors.textSecondary, fontFamily: GoogleFonts.cairo().fontFamily),
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  final isSelected = paymentProvider.selectedCardId == card.id;
                  
                  return _buildCreditCard(context, card, isSelected).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1);
                },
              ),
            
            const SizedBox(height: 32),
            Text(
              'طرق أخرى',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ).animate().fade(delay: 300.ms).slideX(begin: 0.1),
            const SizedBox(height: 16),
            
            // Cash on Delivery Option
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: paymentProvider.selectedCardId == null || paymentProvider.selectedCardId!.isEmpty ? AppColors.primaryColor : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    paymentProvider.selectCard('');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.payments_rounded, color: AppColors.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الدفع عند الاستلام',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: GoogleFonts.cairo().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الدفع نقداً للمندوب عند وصول الطلب',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontFamily: GoogleFonts.cairo().fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (paymentProvider.selectedCardId == null || paymentProvider.selectedCardId!.isEmpty)
                          const Icon(Icons.check_circle_rounded, color: AppColors.primaryColor, size: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
            
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: () => _showAddCardBottomSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            shadowColor: AppColors.primaryColor.withValues(alpha: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'إضافة بطاقة جديدة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: GoogleFonts.cairo().fontFamily,
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 500.ms).slideY(begin: 0.5),
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, PaymentCard card, bool isSelected) {
    final isVisa = card.cardType == 'VISA';
    final gradient = isVisa 
        ? const LinearGradient(
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return GestureDetector(
      onTap: () => context.read<PaymentProvider>().selectCard(card.id),
      child: Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: gradient,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : Border.all(color: Colors.transparent, width: 3),
          boxShadow: [
            BoxShadow(
              color: (isVisa ? const Color(0xFF26D0CE) : const Color(0xFF141E30)).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.credit_card_rounded, color: Colors.white, size: 32),
                    if (isSelected) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('الافتراضية', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ]
                  ],
                ),
                Text(
                  card.cardType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            Text(
              '**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                letterSpacing: 4,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اسم حامل البطاقة',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontFamily: GoogleFonts.cairo().fontFamily),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.holderName,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: GoogleFonts.cairo().fontFamily),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الانتهاء',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontFamily: GoogleFonts.cairo().fontFamily),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.expiryDate,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
                  onPressed: () {
                    context.read<PaymentProvider>().removeCard(card.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف البطاقة')));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'إضافة بطاقة جديدة',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: 'رقم البطاقة',
                prefixIcon: const Icon(Icons.credit_card_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'تاريخ الانتهاء (MM/YY)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'CVC',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'اسم حامل البطاقة',
                prefixIcon: const Icon(Icons.person_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final provider = context.read<PaymentProvider>();
                final newId = DateTime.now().millisecondsSinceEpoch.toString();
                provider.addCard(PaymentCard(
                  id: newId,
                  cardNumber: '**** **** **** 1234',
                  holderName: 'محمد أحمد',
                  expiryDate: '12/28',
                  cvv: '123',
                  cardType: 'VISA',
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة البطاقة بنجاح')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'حفظ البطاقة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: GoogleFonts.cairo().fontFamily,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
