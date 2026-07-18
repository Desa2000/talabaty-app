import 'package:talabaty_app/core/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/data_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../data/models/product_model.dart';

class MerchantMenuTab extends StatefulWidget {
  const MerchantMenuTab({super.key});

  @override
  State<MerchantMenuTab> createState() => _MerchantMenuTabState();
}

class _MerchantMenuTabState extends State<MerchantMenuTab> {
  // Local state to track fast toggles (in a real app, this syncs with the provider)
  final Map<String, bool> _stockStatus = {};

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) return const SizedBox();
    
    final dataProvider = context.watch<DataProvider>();
    
    final merchantId = auth.currentUser != null ? 'store_${auth.currentUser!.id}' : 's1'; 
    final products = dataProvider.products.where((p) => p.storeId == merchantId).toList();

    // Group products by category
    final Map<String, List<ProductModel>> groupedProducts = {};
    for (var p in products) {
      if (!groupedProducts.containsKey(p.category)) {
        groupedProducts[p.category] = [];
      }
      groupedProducts[p.category]!.add(p);
      
      // Initialize stock status if not present (default true for mock purposes)
      if (!_stockStatus.containsKey(p.id)) {
        _stockStatus[p.id] = p.stockQuantity > 0;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('إدارة المنيو والمخزون'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً: البحث في المنيو')));
            },
          )
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text('لا توجد منتجات', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Space for FAB
              itemCount: groupedProducts.keys.length,
              itemBuilder: (context, index) {
                final category = groupedProducts.keys.elementAt(index);
                final categoryProducts = groupedProducts[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.grey.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                      ),
                    ),
                    ...categoryProducts.map((p) => _buildProductCard(p)).toList(),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // In a full app, navigates to Add Product Screen
          context.push('/merchant/products/add');
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('منتج جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final inStock = _stockStatus[product.id] ?? true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
        border: !inStock ? Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1) : null,
      ),
      child: Row(
        children: [
          // Image with Grayscale effect if out of stock
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              inStock ? Colors.transparent : Colors.grey,
              BlendMode.saturation,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImage(
                imagePath: product.image,
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    decoration: !inStock ? TextDecoration.lineThrough : null,
                    color: !inStock ? AppColors.textSecondary : AppColors.textPrimary,
                  )
                ),
                const SizedBox(height: 4),
                Text('${product.price} ج.س', style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Toggle Switch & Edit Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(inStock ? 'متوفر' : 'نفد', style: TextStyle(color: inStock ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  Switch(
                    value: inStock,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        _stockStatus[product.id] = val;
                      });
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'تم إعادة المنتج للقائمة بنجاح' : 'تم إيقاف المنتج من الظهور للعملاء'),
                          backgroundColor: val ? Colors.green : Colors.red,
                          duration: const Duration(seconds: 2),
                        )
                      );
                    },
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
                onPressed: () {
                  context.push('/merchant/products/edit/${product.id}');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

