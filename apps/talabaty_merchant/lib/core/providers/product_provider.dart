import 'package:flutter/foundation.dart';
import '../../data/models/product_model.dart';
import '../../data/services/store_api_service.dart';

/// ProductProvider manages local product state for the Merchant dashboard.
/// All persistence uses the backend REST API via [StoreApiService].
/// Firestore has been fully removed.
class ProductProvider extends ChangeNotifier {
  final StoreApiService _storeApiService = StoreApiService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Merchant Dashboard Stats
  int get totalProducts => _products.length;
  int get availableProducts =>
      _products.where((p) => p.isAvailable && p.stockQuantity > 0).length;
  int get outOfStockProducts =>
      _products.where((p) => p.stockQuantity == 0).length;
  int get lowStockProducts => _products
      .where(
        (p) => p.stockQuantity > 0 && p.stockQuantity <= p.lowStockThreshold,
      )
      .length;

  /// Set products list directly (called by DataProvider after fetching store details)
  void setProducts(List<ProductModel> products) {
    _products = products;
    if (!_isDisposed) notifyListeners();
  }

  Future<void> loadMerchantProducts(String storeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _storeApiService.fetchStoreDetails(storeId);
      if (_isDisposed) return;
      _products = (result['products'] as List<ProductModel>?) ?? [];
    } catch (e) {
      if (_isDisposed) return;
      _error = e.toString();
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> addProduct(ProductModel product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final saved = await _storeApiService.createProduct(product);
      if (_isDisposed) return;
      _products.insert(0, saved);
    } catch (e) {
      if (_isDisposed) return;
      _error = e.toString();
      rethrow;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final saved = await _storeApiService.updateProduct(product);
      if (_isDisposed) return;
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = saved;
      }
    } catch (e) {
      if (_isDisposed) return;
      _error = e.toString();
      rethrow;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _storeApiService.deleteProduct(productId);
      if (_isDisposed) return;
      _products.removeWhere((p) => p.id == productId);
    } catch (e) {
      if (_isDisposed) return;
      _error = e.toString();
      rethrow;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    _error = null;
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) return;
      final updated = _products[index].copyWith(isAvailable: isAvailable);
      final saved = await _storeApiService.updateProduct(updated);
      if (_isDisposed) return;
      _products[index] = saved;
      notifyListeners();
    } catch (e) {
      if (_isDisposed) return;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStock(String productId, int quantityChange) async {
    _error = null;
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) return;
      var newQuantity = _products[index].stockQuantity + quantityChange;
      if (newQuantity < 0) newQuantity = 0;
      final updated = _products[index].copyWith(stockQuantity: newQuantity);
      final saved = await _storeApiService.updateProduct(updated);
      if (_isDisposed) return;
      _products[index] = saved;
      notifyListeners();
    } catch (e) {
      if (_isDisposed) return;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<ProductModel> filterProducts(
    String category,
    String availability,
    String searchText,
  ) {
    return _products.where((p) {
      bool matchesCategory = category == 'الكل' || p.category == category;
      bool matchesSearch = searchText.isEmpty || p.name.contains(searchText);
      bool matchesAvailability = true;
      if (availability == 'متاح') {
        matchesAvailability = p.isAvailable && p.stockQuantity > 0;
      }
      if (availability == 'غير متاح') {
        matchesAvailability = !p.isAvailable || p.stockQuantity == 0;
      }
      if (availability == 'مخزون منخفض') {
        matchesAvailability =
            p.stockQuantity > 0 && p.stockQuantity <= p.lowStockThreshold;
      }

      return matchesCategory && matchesSearch && matchesAvailability;
    }).toList();
  }
}
