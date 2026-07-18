import 'package:flutter/foundation.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  final FirestoreService _firestore = FirestoreService();
  
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
  int get availableProducts => _products.where((p) => p.isAvailable && p.stockQuantity > 0).length;
  int get outOfStockProducts => _products.where((p) => p.stockQuantity == 0).length;
  int get lowStockProducts => _products.where((p) => p.stockQuantity > 0 && p.stockQuantity <= p.lowStockThreshold).length;

  Future<void> loadMerchantProducts(String storeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final productsList = await _repository.getProductsByStoreId(storeId);
      if (_isDisposed) return;
      _products = productsList;
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
      await _firestore.saveProduct(product);
      if (_isDisposed) return;
      // We don't strictly need to add it to _products because DataProvider streams all products,
      // but keeping it here for the merchant dashboard local state
      _products.insert(0, product);
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

  Future<void> updateProduct(ProductModel product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestore.saveProduct(product);
      if (_isDisposed) return;
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
      }
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

  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestore.deleteProduct(productId);
      if (_isDisposed) return;
      _products.removeWhere((p) => p.id == productId);
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

  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    _error = null;
    try {
      await _repository.toggleProductAvailability(productId, isAvailable);
      if (_isDisposed) return;
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(isAvailable: isAvailable);
        notifyListeners();
      }
    } catch (e) {
      if (_isDisposed) return;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateStock(String productId, int quantityChange) async {
    _error = null;
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        int newQuantity = _products[index].stockQuantity + quantityChange;
        if (newQuantity < 0) newQuantity = 0;
        await _repository.updateStock(productId, newQuantity);
        if (_isDisposed) return;
        _products[index] = _products[index].copyWith(stockQuantity: newQuantity);
        notifyListeners();
      }
    } catch (e) {
      if (_isDisposed) return;
      _error = e.toString();
      notifyListeners();
    }
  }

  List<ProductModel> filterProducts(String category, String availability, String searchText) {
    return _products.where((p) {
      bool matchesCategory = category == 'الكل' || p.category == category;
      bool matchesSearch = searchText.isEmpty || p.name.contains(searchText);
      bool matchesAvailability = true;
      if (availability == 'متاح') matchesAvailability = p.isAvailable && p.stockQuantity > 0;
      if (availability == 'غير متاح') matchesAvailability = !p.isAvailable || p.stockQuantity == 0;
      if (availability == 'مخزون منخفض') matchesAvailability = p.stockQuantity > 0 && p.stockQuantity <= p.lowStockThreshold;
      
      return matchesCategory && matchesSearch && matchesAvailability;
    }).toList();
  }
}
