import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MerchantPOSScreen extends StatelessWidget {
  const MerchantPOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('نقطة البيع (POS)')),
      body: const Center(child: Text('جاري برمجة شاشة نقاط البيع...')),
    );
  }
}
