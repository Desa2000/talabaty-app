import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/data_provider.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final orders = dataProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع الطلبات'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            child: ListTile(
              title: Text('طلب #${order.id.substring(0, 5)}'),
              subtitle: Text('${order.items.length} منتجات | ${order.total} ج.س\nتاريخ الطلب: ${order.createdAt.toString().substring(0, 16)}'),
              trailing: Text(order.status.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
          );
        },
      ),
    );
  }
}
