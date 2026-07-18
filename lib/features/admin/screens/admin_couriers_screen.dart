import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/constants/enums.dart';

class AdminCouriersScreen extends StatelessWidget {
  const AdminCouriersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final couriers = dataProvider.couriers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المناديب'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: couriers.length,
        itemBuilder: (context, index) {
          final courier = couriers[index];
          final courierUser = dataProvider.users.firstWhere((u) => u.id == courier.userId, orElse: () => dataProvider.users.first);
          final isAvailable = courier.status == CourierStatus.available;
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.motorcycle)),
              title: Text(courierUser.name),
              subtitle: Text('المركبة: ${courier.vehicleType.name}\nأرباح اليوم: ${courier.todayEarnings} ج.س'),
              trailing: Chip(
                label: Text(isAvailable ? 'متاح' : 'مشغول/غير متصل'),
                backgroundColor: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
              ),
            ),
          );
        },
      ),
    );
  }
}
