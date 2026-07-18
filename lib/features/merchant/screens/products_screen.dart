import 'package:talabaty_app/core/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/product_provider.dart';
import '../../../data/models/product_model.dart';

class MerchantProductsScreen extends StatefulWidget {
  const MerchantProductsScreen({super.key});

  @override
  State<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends State<MerchantProductsScreen> {
  String _selectedCategory = 'الكل';
  String _selectedAvailability = 'الكل';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['الكل', 'وجبات رئيسية', 'مشويات', 'سندوتشات', 'بيتزا', 'إضافات', 'المشروبات'];
  final List<String> _availabilities = ['الكل', 'متاح', 'غير متاح', 'مخزون منخفض'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('المنتجات', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/merchant/products/add'),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('إضافة منتج', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    style: GoogleFonts.cairo(),
                    decoration: InputDecoration(
                      hintText: 'البحث عن منتج...',
                      hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          style: GoogleFonts.cairo(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'التصنيف',
                            labelStyle: GoogleFonts.cairo(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey.withValues(alpha: 0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedAvailability,
                          style: GoogleFonts.cairo(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'التوفر',
                            labelStyle: GoogleFonts.cairo(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey.withValues(alpha: 0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          items: _availabilities.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedAvailability = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                  }

                  final filteredProducts = provider.filterProducts(_selectedCategory, _selectedAvailability, _searchController.text);

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300).animate().scale(duration: 400.ms),
                          const SizedBox(height: 16),
                          Text('لا توجد منتجات', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('جرب تغيير الفلتر أو أضف منتجات جديدة', style: GoogleFonts.cairo(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ProductCard(product: product).animate().fade(duration: 400.ms, delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.05, end: 0);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = product.stockQuantity > 0 && product.stockQuantity <= product.lowStockThreshold;
    final bool isOutOfStock = product.stockQuantity == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomImage(imagePath: product.image, fit: BoxFit.cover, width: 80, height: 80),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(product.category, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${product.price}', style: GoogleFonts.outfit(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('المخزون: ${product.stockQuantity}', style: GoogleFonts.cairo(color: isOutOfStock ? Colors.red : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderGray, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isOutOfStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text('غير متوفر', style: GoogleFonts.cairo(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    else if (isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text('مخزون منخفض', style: GoogleFonts.cairo(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text('متاح', style: GoogleFonts.cairo(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Switch(
                      value: product.isAvailable,
                      activeColor: AppColors.primaryColor,
                      onChanged: (val) {
                        context.read<ProductProvider>().toggleAvailability(product.id, val);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                      onPressed: () {
                         context.push('/merchant/products/edit/${product.id}');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      onPressed: () {
                        context.read<ProductProvider>().deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

