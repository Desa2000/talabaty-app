import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:talabaty_app/core/providers/data_provider.dart';
import 'package:talabaty_app/core/providers/cart_provider.dart';
import 'package:talabaty_app/core/constants/app_colors.dart';
import 'package:talabaty_app/core/constants/enums.dart';
import 'package:talabaty_app/data/models/store_model.dart';

class StoreDetailsScreen extends StatefulWidget {
  final String storeId;
  const StoreDetailsScreen({super.key, required this.storeId});

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _selectedCategory = '';
  bool _isFavorite = false;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final store = dataProvider.stores.firstWhere(
      (s) => s.id == widget.storeId,
      orElse: () => dataProvider.stores.isNotEmpty
          ? dataProvider.stores.first
          : StoreModel(
              id: widget.storeId,
              ownerId: '',
              name: 'المحل غير متوفر',
              type: StoreType.restaurant,
              logo: '',
              coverImage: '',
              phone: '',
              area: '',
              street: '',
              landmark: '',
              latitude: 0,
              longitude: 0,
              openingTime: '',
              closingTime: '',
              preparationTime: '',
              minimumOrder: 0,
              deliveryFee: 0,
            ),
    );
    final products = dataProvider.products.where((p) => p.storeId == widget.storeId).toList();

    final List<String> categories = products.map((p) => p.category).toSet().toList();
    
    if (categories.isNotEmpty) {
      if (_tabController == null || _tabController!.length != categories.length) {
        _tabController?.dispose();
        _tabController = TabController(length: categories.length, vsync: this);
        _selectedCategory = categories.first;
        _tabController!.addListener(() {
          if (_tabController!.indexIsChanging || _selectedCategory != categories[_tabController!.index]) {
            setState(() {
              _selectedCategory = categories[_tabController!.index];
            });
          }
        });
      }
    } else {
      _tabController?.dispose();
      _tabController = null;
      _selectedCategory = '';
    }

    final filteredProducts = products.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Sleek Cover Image with Premium Back/Action buttons
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => context.pop(),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20), // RTL back arrow
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'store_image_${store.id}',
                      child: Image.network(
                        store.coverImage ?? store.logo ?? 'https://via.placeholder.com/150', 
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.primaryColor),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                        color: _isFavorite ? Colors.red : Colors.white, 
                        size: 20
                      ),
                      onPressed: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isFavorite ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة'), 
                            behavior: SnackBarBehavior.floating
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('قريباً: مشاركة المطعم'), behavior: SnackBarBehavior.floating),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // 2. Premium Restaurant Info Card
            SliverToBoxAdapter(
              child: Container(
                transform: Matrix4.translationValues(0, -30, 0),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111111),
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${store.rating}  •  ${store.area}',
                          style: const TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoColumn(Icons.access_time_rounded, store.preparationTime, 'وقت التحضير', AppColors.primaryColor),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          _buildInfoColumn(Icons.delivery_dining_rounded, '${store.deliveryFee.toInt()} ج.س', 'التوصيل', Colors.blue.shade600),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          _buildInfoColumn(Icons.shopping_bag_outlined, '${store.minimumOrder.toInt()} ج.س', 'الحد الأدنى', Colors.green.shade600),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Sticky Categories — Vibrant Pill Chip TabBar
            if (categories.isNotEmpty)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.transparent,
                    dividerColor: Colors.transparent,
                    indicator: const BoxDecoration(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    physics: const BouncingScrollPhysics(),
                    onTap: (index) {
                      setState(() {
                        _selectedCategory = categories[index];
                      });
                    },
                    tabs: categories.asMap().entries.map((entry) {
                      final isSelected = _selectedCategory == entry.value;
                      return _PillTab(
                        label: entry.value,
                        isSelected: isSelected,
                      );
                    }).toList(),
                  ),
                ),
              ),

            // 4. Products List
            if (filteredProducts.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'لا توجد منتجات في هذا القسم',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 16, fontFamily: 'Cairo'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(bottom: 120), // padding for floating cart
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = filteredProducts[index];
                      return GestureDetector(
                        onTap: () => context.push('/customer/product/${p.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              // Product Image (RTL -> Right side)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  p.image, 
                                  fit: BoxFit.cover,
                                  width: 110,
                                  height: 110,
                                  errorBuilder: (_, __, ___) => Container(width: 110, height: 110, color: Colors.grey.shade200),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Product Details (RTL -> Left side)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 17,
                                        color: Color(0xFF111111),
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      p.description,
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 13,
                                        fontFamily: 'Cairo',
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Price
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${p.discountPrice ?? p.price} ج.س',
                                              style: const TextStyle(
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                            if (p.discountPrice != null) ...[
                                              const SizedBox(width: 8),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 2),
                                                child: Text(
                                                  '${p.price}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    decoration: TextDecoration.lineThrough,
                                                    fontFamily: 'Cairo',
                                                  ),
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                        // Add Button
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.add_rounded, color: AppColors.primaryColor, size: 20),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredProducts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      // 5. Stunning Premium Floating Cart Bottom Bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return cart.items.isNotEmpty
              ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => context.push('/customer/checkout'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '${cart.items.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                            const Text(
                              'عرض السلة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            Text(
                              '${cart.totalPrice} ج.س',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String title, String subtitle, Color iconColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: Color(0xFF111111),
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 16.0;

  @override
  double get maxExtent => _tabBar.preferredSize.height + 16.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: _tabBar.preferredSize.height + 16.0,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: _tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return true;
  }
}

/// Vibrant pill-shaped tab chip
class _PillTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _PillTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: isSelected ? AppColors.primaryColor : Colors.white,
        border: isSelected ? null : Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          fontSize: 15,
          color: isSelected ? Colors.white : const Color(0xFF555555),
        ),
      ),
    );
  }
}
