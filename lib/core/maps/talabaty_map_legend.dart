import 'package:flutter/material.dart';

class TalabatyMapLegend extends StatelessWidget {
  const TalabatyMapLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D20).withOpacity(0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(const Color(0xFFFF5722), 'الخرطوم النشطة'),
          const SizedBox(width: 12),
          _buildLegendItem(const Color(0xFF2E7D32), 'متجر'),
          const SizedBox(width: 12),
          _buildLegendItem(const Color(0xFF42A5F5), 'المندوب'),
          const SizedBox(width: 12),
          _buildLegendItem(Colors.white, 'التوصيل'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
