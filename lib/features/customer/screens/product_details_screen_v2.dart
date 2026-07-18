import 'package:talabaty_app/core/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/data_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  final Map<String, List<String>> _selectedOptions = {};
  final List<ProductAddOn> _selectedAddOns = [];
  final _notesController = TextEditingController();

  final Color hslPrimary = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.50).toColor(); // Orange
  final Color hslGradientStart = HSLColor.fromAHSL(1.0, 25.0, 1.0, 0.55).toColor();
  final Color hslGradientEnd = HSLColor.fromAHSL(1.0, 12.0, 1.0, 0.50).toColor();
  final Color hslSoftGray = HSLColor.fromAHSL(1.0, 240.0, 0.05, 0.94).toColor();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDefaults();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  ProductModel _getProduct(BuildContext context, {bool listen = false}) {
    final dataProvider = listen ? context.watch<DataProvider>() : context.read<DataProvider>();
    final products = dataProvider.products;
    return products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => products.isNotEmpty
          ? products.first
          : ProductModel(
              id: widget.productId,
              storeId: '',
              name: 'المنتج غير متوفر',
              description: '',
              image: '',
              category: '',
              price: 0,
              stockQuantity: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );
  }

  void _initializeDefaults() {
    final product = _getProduct(context, listen: false);
    for (var group in product.optionGroups) {
      _selectedOptions[group.id] = [];
      if (group.isRequired && group.options.isNotEmpty) {
        _selectedOptions[group.id]!.add(group.options.first.id);
      }
    }
    setState(() {});
  }

  bool _validateRequiredOptions(ProductModel product) {
    for (var group in product.optionGroups) {
      if (group.isRequired) {
        final selected = _selectedOptions[group.id];
        if (selected == null || selected.length < group.minSelection || selected.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final product = _getProduct(context, listen: true);

    double basePrice = product.discountPrice ?? product.price;
    
    double optionsPrice = 0.0;
    for (var group in product.optionGroups) {
      final selectedIds = _selectedOptions[group.id] ?? [];
      for (var optId in selectedIds) {
        final opt = group.options.firstWhere(
          (o) => o.id == optId, 
          orElse: () => ProductOption(id: '', name: '', extraPrice: 0)
        );
        optionsPrice += opt.extraPrice;
      }
    }

    double addOnsPrice = _selectedAddOns.fold(0.0, (sum, addOn) => sum + addOn.price);
    double total = (basePrice + optionsPrice + addOnsPrice) * _quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.backgroundLight,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomImage(imagePath: product.image, fit: BoxFit.cover),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Container(
                transform: Matrix4.translationValues(0, -24, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: GoogleFonts.outfit(
                              fontSize: 26, 
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (product.discountPrice != null)
                              Text(
                                '${product.price.toInt()} ج.س', 
                                style: GoogleFonts.inter(
                                  fontSize: 14, 
                                  decoration: TextDecoration.lineThrough, 
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                            Text(
                              '${basePrice.toInt()} ج.س', 
                              style: GoogleFonts.inter(
                                  fontSize: 22, 
                                  fontWeight: FontWeight.w900, 
                                  color: hslPrimary
                              )
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description, 
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary, 
                        fontSize: 15,
                        height: 1.5,
                      )
                    ),
                    const SizedBox(height: 28),
                    
                    if (product.optionGroups.isNotEmpty)
                      ...product.optionGroups.map((group) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: hslSoftGray,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    group.name, 
                                    style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold)
                                  ),
                                  if (group.isRequired) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'مطلوب', 
                                        style: GoogleFonts.outfit(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold)
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 14),
                              ...group.options.map((option) {
                                final isSelected = (_selectedOptions[group.id] ?? []).contains(option.id);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedOptions[group.id] ??= [];
                                      if (!isSelected) {
                                        if (group.maxSelection == 1) {
                                          _selectedOptions[group.id]!.clear();
                                        }
                                        if (_selectedOptions[group.id]!.length < group.maxSelection) {
                                          _selectedOptions[group.id]!.add(option.id);
                                        }
                                      } else {
                                        if (group.isRequired && _selectedOptions[group.id]!.length <= 1) {
                                          return;
                                        }
                                        _selectedOptions[group.id]!.remove(option.id);
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected ? hslPrimary : Colors.transparent, 
                                        width: 1.5
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          option.name, 
                                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)
                                        ),
                                        Row(
                                          children: [
                                            if (option.extraPrice > 0)
                                              Text(
                                                '+${option.extraPrice.toInt()} ج.س ', 
                                                style: GoogleFonts.inter(color: hslPrimary, fontWeight: FontWeight.bold, fontSize: 13)
                                              ),
                                            Icon(
                                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                              color: isSelected ? hslPrimary : Colors.grey,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      }).toList(),

                    if (product.addOns.isNotEmpty) ...[
                      Text(
                        'إضافات (اختياري)', 
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900)
                      ),
                      const SizedBox(height: 12),
                      ...product.addOns.map((addOn) {
                        final isSelected = _selectedAddOns.contains(addOn);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.6)),
                          ),
                          child: CheckboxListTile(
                            title: Text(addOn.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('+${addOn.price.toInt()} ج.س', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                            value: isSelected,
                            onChanged: addOn.isAvailable ? (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedAddOns.add(addOn);
                                } else {
                                  _selectedAddOns.remove(addOn);
                                }
                              });
                            } : null,
                            activeColor: hslPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    if (product.allowCustomerNotes) ...[
                      Text(
                        'ملاحظات إضافية', 
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900)
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'مثال: بدون بصل، زيادة شطة، الطابق الثاني...',
                          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                          filled: true,
                          fillColor: hslSoftGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18), 
                            borderSide: BorderSide.none
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), 
                blurRadius: 20, 
                offset: const Offset(0, -8)
              )
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5), width: 1),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: hslSoftGray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_rounded, color: AppColors.textPrimary, size: 20), 
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        }
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Text(
                          '$_quantity', 
                          key: ValueKey<int>(_quantity),
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_rounded, color: hslPrimary, size: 20), 
                        onPressed: () => setState(() => _quantity++)
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: (product.isAvailable && product.stockQuantity > 0)
                          ? LinearGradient(
                              colors: [hslGradientStart, hslGradientEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: (product.isAvailable && product.stockQuantity > 0) ? null : Colors.grey.shade400,
                      boxShadow: (product.isAvailable && product.stockQuantity > 0)
                          ? [
                              BoxShadow(
                                color: hslPrimary.withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ]
                          : [],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: (product.isAvailable && product.stockQuantity > 0) ? () {
                        if (!_validateRequiredOptions(product)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('الرجاء اختيار الخيارات المطلوبة أولاً', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            )
                          );
                          return;
                        }

                        context.read<CartProvider>().addProduct(
                          product, 
                          quantity: _quantity, 
                          selectedOptions: Map.from(_selectedOptions), 
                          selectedAddOns: List.from(_selectedAddOns), 
                          notes: _notesController.text
                        );
                        final messenger = ScaffoldMessenger.of(context);
                        context.pop();
                        
                        messenger.showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('تمت إضافة المنتج بنجاح!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          )
                        );
                      } : null,
                      child: Text(
                        product.stockQuantity == 0 
                            ? 'غير متوفر حالياً' 
                            : 'إضافة بقيمة ${total.toInt()} ج.س',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
