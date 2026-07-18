import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/data_provider.dart';

class RateOrderScreen extends StatefulWidget {
  final String orderId;
  final String storeId;

  const RateOrderScreen({super.key, required this.orderId, required this.storeId});

  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitRating() async {
    setState(() => _isLoading = true);
    try {
      final dataProvider = context.read<DataProvider>();
      await dataProvider.rateStore(widget.storeId, _rating.toDouble());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تقييم الطلب بنجاح، شكراً لك!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'تقييم الطلب',
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
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.amber.withValues(alpha: 0.2), blurRadius: 40)
                ]
              ),
              child: const Icon(Icons.star_rounded, size: 80, color: Colors.amber),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            Text(
              'كيف كانت تجربتك؟',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
            const SizedBox(height: 8),
            Text(
              'رأيك يهمنا لتحسين جودة الخدمة',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    child: AnimatedScale(
                      scale: _rating > index ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _rating > index ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: _rating > index ? Colors.amber : Colors.grey.shade300,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'شاركنا تفاصيل أكثر (اختياري)...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: GoogleFonts.cairo().fontFamily),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'إرسال التقييم',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.cairo().fontFamily,
                      ),
                    ),
            ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}
