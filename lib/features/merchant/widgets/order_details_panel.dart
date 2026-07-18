import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/data_provider.dart';
import '../../../data/models/order_model.dart';
import '../../../core/widgets/status_chip.dart';

class OrderDetailsPanel extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsPanel({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderGray)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('طلب #${order.id.substring(0, 8)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                StatusChip(status: order.status),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentCream,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Builder(
                              builder: (context) {
                                List<String> opts = [];
                                item.selectedOptions.forEach((gid, oids) {
                                  final g = item.product.optionGroups.where((x) => x.id == gid).firstOrNull;
                                  if (g != null) {
                                    for (var oid in oids) {
                                      final o = g.options.where((x) => x.id == oid).firstOrNull;
                                      if (o != null) opts.add(o.name);
                                    }
                                  }
                                });
                                opts.addAll(item.selectedAddOns.map((a) => a.name));
                                if (opts.isEmpty) return const SizedBox();
                                return Text(opts.join('، '), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12));
                              }
                            ),
                          ],
                        ),
                      ),
                      Text('${item.totalPrice} ج.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),

          // Footer & Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.backgroundLight,
              border: Border(top: BorderSide(color: AppColors.borderGray)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الإجمالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${order.total} ج.س', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildActionButtons(context, dataProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DataProvider dataProvider) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => dataProvider.rejectOrder(order.id, 'مرفوض من التاجر'),
                child: const Text('رفض الطلب', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => dataProvider.acceptOrder(order.id),
                child: const Text('قبول الطلب', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        );
      
      case OrderStatus.acceptedByMerchant:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () => dataProvider.startPreparingOrder(order.id),
            child: const Text('بدء التجهيز (المطبخ)', style: TextStyle(fontSize: 18)),
          ),
        );

      case OrderStatus.preparing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => dataProvider.markOrderReady(order.id),
            child: const Text('جاهز للاستلام', style: TextStyle(fontSize: 18)),
          ),
        );

      case OrderStatus.readyForPickup:
      case OrderStatus.searchingCourier:
      case OrderStatus.assignedToCourier:
      case OrderStatus.courierGoingToStore:
      case OrderStatus.courierArrivedStore:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('في انتظار استلام المندوب', style: TextStyle(fontSize: 18)),
          ),
        );

      default:
        return const SizedBox();
    }
  }
}
