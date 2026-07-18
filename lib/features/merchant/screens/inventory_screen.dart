import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/product_provider.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('إدارة المخزون')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final products = provider.products;
          
          if (products.isEmpty) {
            return const Center(child: Text('لا توجد منتجات.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(product.image),
                    backgroundColor: Colors.transparent,
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الكمية الحالية: ${product.stockQuantity}', 
                    style: TextStyle(
                      color: product.stockQuantity == 0 ? Colors.red : 
                            (product.stockQuantity <= product.lowStockThreshold ? Colors.orange : Colors.grey)
                    )
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          _showStockDialog(context, product.id, false);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          _showStockDialog(context, product.id, true);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showStockDialog(BuildContext context, String productId, bool isAdding) {
    int quantity = 1;
    String reason = isAdding ? 'شراء جديد' : 'تلف';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isAdding ? 'إضافة للمخزون' : 'خصم من المخزون'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الكمية', border: OutlineInputBorder()),
                    onChanged: (v) {
                      final parsed = int.tryParse(v);
                      if (parsed != null) quantity = parsed;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: reason,
                    decoration: const InputDecoration(labelText: 'السبب', border: OutlineInputBorder()),
                    items: (isAdding ? ['شراء جديد', 'تعديل يدوي'] : ['تلف', 'بيع مباشر', 'تعديل يدوي'])
                        .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setState(() => reason = v!),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (quantity > 0) {
                      context.read<ProductProvider>().updateStock(productId, isAdding ? quantity : -quantity);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          }
        );
      }
    );
  }
}
