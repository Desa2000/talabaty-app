import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/data_provider.dart';

class AdminStoresScreen extends StatelessWidget {
  const AdminStoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final stores = dataProvider.stores;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.store)),
            title: Text(store.name),
            subtitle: Text('${store.area} - ${store.street}'),
            trailing: Switch(
              value: true,
              onChanged: (val) {
                // Toggle active status logic
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث حالة المتجر')));
              },
            ),
          ),
        );
      },
    );
  }
}
