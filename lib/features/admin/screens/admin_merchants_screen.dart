import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/constants/enums.dart';

class AdminMerchantsScreen extends StatelessWidget {
  const AdminMerchantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final stores = dataProvider.stores;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المتاجر'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          IconData storeIcon = Icons.storefront;
          if (store.type == StoreType.restaurant) storeIcon = Icons.restaurant;
          if (store.type == StoreType.supermarket) storeIcon = Icons.shopping_cart;
          if (store.type == StoreType.pharmacy) storeIcon = Icons.local_pharmacy;

          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(storeIcon)),
              title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${store.type.name} | ${store.area}'),
              trailing: Chip(
                label: Text(store.status == 'active' ? 'نشط' : 'غير نشط'),
                backgroundColor: store.status == 'active' ? Colors.green.shade100 : Colors.red.shade100,
              ),
            ),
          );
        },
      ),
    );
  }
}
