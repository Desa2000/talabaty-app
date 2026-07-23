import 'package:flutter/foundation.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _currentStoreId;

  List<CartItem> get items => _items;
  String? get currentStoreId => _currentStoreId;

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if product belongs to a different store
  bool isFromDifferentStore(ProductModel product) {
    if (_items.isEmpty || _currentStoreId == null) return false;
    return _currentStoreId != product.storeId;
  }

  /// Returns true if added successfully, false if store mismatch (requiring confirmation)
  bool addProduct(
    ProductModel product, {
    int quantity = 1,
    Map<String, List<String>> selectedOptions = const {},
    List<ProductAddOn> selectedAddOns = const [],
    String notes = '',
    bool forceClearStoreMismatch = false,
  }) {
    if (isFromDifferentStore(product)) {
      if (!forceClearStoreMismatch) {
        return false; // Signals caller to ask for user confirmation
      }
      clearCart();
    }

    _currentStoreId = product.storeId;

    final existingIndex = _items.indexWhere((item) =>
        item.product.id == product.id &&
        _areOptionsEqual(item.selectedOptions, selectedOptions) &&
        _areAddOnsEqual(item.selectedAddOns, selectedAddOns));

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        selectedOptions: selectedOptions,
        selectedAddOns: selectedAddOns,
        notes: notes,
      ));
    }

    notifyListeners();
    return true;
  }

  bool _areOptionsEqual(Map<String, List<String>> map1, Map<String, List<String>> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      final list1 = map1[key]!;
      final list2 = map2[key]!;
      if (list1.length != list2.length) return false;
      if (!list1.toSet().containsAll(list2.toSet())) return false;
    }
    return true;
  }

  bool _areAddOnsEqual(List<ProductAddOn> list1, List<ProductAddOn> list2) {
    if (list1.length != list2.length) return false;
    final ids1 = list1.map((e) => e.id).toSet();
    final ids2 = list2.map((e) => e.id).toSet();
    return ids1.containsAll(ids2);
  }

  void removeProduct(CartItem itemToRemove) {
    _items.remove(itemToRemove);
    if (_items.isEmpty) {
      _currentStoreId = null;
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    final index = _items.indexOf(item);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
        if (_items.isEmpty) {
          _currentStoreId = null;
        }
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _currentStoreId = null;
    notifyListeners();
  }
}
