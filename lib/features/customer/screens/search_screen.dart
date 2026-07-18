import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/data_provider.dart';
import '../../../core/services/delivery_fee_service.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/product_model.dart';
import '../../../core/widgets/custom_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<StoreModel> _allStores = [];
  List<StoreModel> _filteredStores = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _searchHistory = [];
  
  String _activeFilter = 'all'; // all, restaurant, supermarket, pharmacy
  String _sortBy = 'rating'; // rating, distance, delivery
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dp = context.read<DataProvider>();
      setState(() { _allStores = dp.stores; });
    });
    _loadHistory();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _searchHistory = prefs.getStringList('search_history') ?? []; });
  }

  Future<void> _addToHistory(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('search_history') ?? [];
    list.remove(query);
    list.insert(0, query);
    if (list.length > 10) list.removeLast();
    await prefs.setStringList('search_history', list);
    setState(() { _searchHistory = list; });
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() { _searchHistory = []; });
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() { _isSearching = false; _filteredStores = []; _filteredProducts = []; });
      return;
    }
    final dp = context.read<DataProvider>();
    final lq = query.toLowerCase().trim();
    setState(() {
      _isSearching = true;
      _filteredStores = _allStores.where((s) {
        final matchFilter = _activeFilter == 'all' || s.type.toString().contains(_activeFilter);
        return matchFilter && (s.name.toLowerCase().contains(lq) || s.area.toLowerCase().contains(lq));
      }).toList();
      _filteredProducts = dp.products.where((p) =>
        p.name.toLowerCase().contains(lq) || p.description.toLowerCase().contains(lq)
      ).toList();
      _applySort();
    });
  }

  void _applySort() {
    if (_sortBy == 'rating') {
      _filteredStores.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'delivery') {
      _filteredStores.sort((a, b) => a.deliveryFee.compareTo(b.deliveryFee));
    }
  }

  void _searchFor(String q) {
    _searchController.text = q;
    _onSearchChanged(q);
    _addToHistory(q);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              // ===== HEADER WITH SEARCH =====
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF111111)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن مطعم أو منتج...',
                            hintStyle: const TextStyle(fontFamily: 'Cairo', color: Color(0xFFAAAAAA), fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryColor, size: 22),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF888888)),
                                    onPressed: () { _searchController.clear(); _onSearchChanged(''); },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                          ),
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Color(0xFF111111)),
                          onChanged: _onSearchChanged,
                          onSubmitted: (q) { _addToHistory(q); },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== FILTERS =====
              if (_isSearching)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      // Category filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip('all', '🍽️ الكل'),
                            _filterChip('restaurant', '🍔 مطاعم'),
                            _filterChip('supermarket', '🛒 سوبرماركت'),
                            _filterChip('pharmacy', '💊 صيدليات'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Sort options
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text('ترتيب: ', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888), fontSize: 13)),
                            _sortChip('rating', '⭐ الأعلى تقييماً'),
                            _sortChip('delivery', '🚀 أقل رسوم توصيل'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              Expanded(
                child: _isSearching ? _buildResults() : _buildBrowse(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final active = _activeFilter == key;
    return GestureDetector(
      onTap: () { setState(() => _activeFilter = key); _onSearchChanged(_searchController.text); },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryColor : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : const Color(0xFF555555))),
      ),
    );
  }

  Widget _sortChip(String key, String label) {
    final active = _sortBy == key;
    return GestureDetector(
      onTap: () { setState(() { _sortBy = key; _applySort(); }); },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primaryColor : const Color(0xFFDDDDDD)),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: active ? AppColors.primaryColor : const Color(0xFF666666))),
      ),
    );
  }

  Widget _buildBrowse() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search history
        if (_searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('عمليات البحث الأخيرة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF111111))),
              GestureDetector(
                onTap: _clearHistory,
                child: const Text('مسح الكل', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primaryColor, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _searchHistory.take(8).map((h) => GestureDetector(
              onTap: () => _searchFor(h),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 14, color: Color(0xFF888888)),
                    const SizedBox(width: 6),
                    Text(h, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF333333))),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Popular categories
        const Text('الأقسام الشائعة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF111111))),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.0,
          children: [
            _categoryBox('🍔 برجر', 'burger', const Color(0xFFFF6B00)),
            _categoryBox('🍕 بيتزا', 'pizza', const Color(0xFFE91E63)),
            _categoryBox('🌯 شاورما', 'شاورما', const Color(0xFF9C27B0)),
            _categoryBox('🍗 فراخ', 'chicken', const Color(0xFF4CAF50)),
            _categoryBox('🛒 سوبرماركت', 'supermarket', const Color(0xFF2196F3)),
            _categoryBox('💊 صيدلية', 'pharmacy', const Color(0xFF009688)),
          ],
        ),
      ],
    );
  }

  Widget _categoryBox(String label, String query, Color color) {
    return GestureDetector(
      onTap: () => _searchFor(query),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 15, color: color)),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_filteredStores.isEmpty && _filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 16),
            const Text('لا توجد نتائج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF333333))),
            const SizedBox(height: 8),
            Text('جرب كلمة بحث مختلفة', style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888), fontSize: 14)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_filteredStores.isNotEmpty) ...[
          Text('المطاعم والمتاجر (${_filteredStores.length})', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF111111))),
          const SizedBox(height: 12),
          ..._filteredStores.asMap().entries.map((e) =>
            _storeResultCard(e.value).animate().fade(duration: 250.ms, delay: Duration(milliseconds: e.key * 50)).slideY(begin: 0.05, end: 0)),
        ],
        if (_filteredProducts.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('المنتجات (${_filteredProducts.length})', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF111111))),
          const SizedBox(height: 12),
          ..._filteredProducts.take(20).toList().asMap().entries.map((e) => _productResultCard(e.value)),
        ],
      ],
    );
  }

  Widget _storeResultCard(StoreModel store) {
    final statusColor = store.status == 'active' ? Colors.green : Colors.red;
    return GestureDetector(
      onTap: () { _addToHistory(_searchController.text); context.push('/customer/store/${store.id}'); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 68, height: 68,
                child: CustomImage(imagePath: store.logo ?? '', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF111111))),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    Text('${store.rating}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF555555))),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_outlined, color: Color(0xFF888888), size: 13),
                    Text(store.area, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888), fontSize: 12)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.delivery_dining_rounded, color: Color(0xFF888888), size: 13),
                    const SizedBox(width: 3),
                    Text('توصيل ${store.deliveryFee.toStringAsFixed(0)} ج.س', style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888), fontSize: 12)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(store.status == 'active' ? 'مفتوح' : 'مغلق', style: TextStyle(fontFamily: 'Cairo', color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  Widget _productResultCard(ProductModel product) {
    return GestureDetector(
      onTap: () { _addToHistory(_searchController.text); context.push('/customer/product/${product.id}'); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(width: 56, height: 56, child: CustomImage(imagePath: product.image, fit: BoxFit.cover)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(product.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF888888), fontSize: 12)),
                ],
              ),
            ),
            Text('${product.price.toStringAsFixed(0)} ج.س', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: AppColors.primaryColor, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
