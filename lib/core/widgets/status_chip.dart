import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/enums.dart';

class StatusChip extends StatelessWidget {
  final OrderStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    Color bgColor;

    label = status.arabicLabel;
    
    // Quick heuristic for colors
    if (status == OrderStatus.delivered) {
      color = Colors.green;
    } else if (status == OrderStatus.cancelled || status == OrderStatus.rejectedByMerchant) {
      color = Colors.red;
    } else if (status == OrderStatus.onTheWay) {
      color = AppColors.primaryColor;
    } else {
      color = Colors.blue;
    }
    bgColor = color.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
