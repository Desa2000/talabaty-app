import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/enums.dart';

class CourierStatusChip extends StatelessWidget {
  final CourierStatus status;

  const CourierStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    Color bgColor;

    switch (status) {
      case CourierStatus.available:
        label = 'متاح';
        color = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
        break;
      case CourierStatus.busy:
        label = 'مشغول';
        color = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        break;
      case CourierStatus.offline:
        label = 'غير متصل';
        color = Colors.grey;
        bgColor = Colors.grey.withValues(alpha: 0.1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
