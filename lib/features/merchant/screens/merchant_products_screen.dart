import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';

class MerchantProductsScreen extends StatelessWidget {
  const MerchantProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final merchantId = auth.currentUser?.id ?? 'm1';
    final storeIds = dataProvider.stores.where((s) => s.ownerId == merchantId).map((s) => s.id).toList();
    final products = dataProvider.products.where((p) => storeIds.contains(p.storeId)).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade200,
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
              title: Text(product.name),
              subtitle: Text('${product.price} ج.س - المخزون: ${product.stockQuantity}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                onPressed: () {
                  context.push('/merchant/products/edit/${product.id}');
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/merchant/products/add');
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
