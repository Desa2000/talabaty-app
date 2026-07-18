import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';
import '../../data/models/store_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/user_model.dart';
import '../utils/firebase_mapper.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream all active orders (for courier & merchant)
  Stream<List<OrderModel>> streamAllOrders() {
    return _db.collection('orders').snapshots().map((snapshot) {
      List<OrderModel> parsedOrders = [];
      for (var doc in snapshot.docs) {
        try {
          parsedOrders.add(FirebaseMapper.orderFromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing order ${doc.id}: $e');
        }
      }
      return parsedOrders;
    });
  }

  // Stream orders for a specific customer
  Stream<List<OrderModel>> streamCustomerOrders(String customerId) {
    return _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      List<OrderModel> parsedOrders = [];
      for (var doc in snapshot.docs) {
        try {
          parsedOrders.add(FirebaseMapper.orderFromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing customer order ${doc.id}: $e');
        }
      }
      return parsedOrders;
    });
  }

  // Add or update an order
  Future<void> saveOrder(OrderModel order) async {
    await _db.collection('orders').doc(order.id).set(FirebaseMapper.orderToJson(order));
  }

  // Delete an order (if needed)
  Future<void> deleteOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).delete();
  }

  // Stream all stores
  Stream<List<StoreModel>> streamStores() {
    return _db.collection('stores').snapshots().map((snapshot) {
      List<StoreModel> parsedStores = [];
      for (var doc in snapshot.docs) {
        try {
          parsedStores.add(FirebaseMapper.storeFromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing store ${doc.id}: $e');
        }
      }
      return parsedStores;
    });
  }

  Future<void> saveStore(StoreModel store) async {
    await _db.collection('stores').doc(store.id).set(FirebaseMapper.storeToJson(store));
  }

  // Stream all products
  Stream<List<ProductModel>> streamProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      List<ProductModel> parsedProducts = [];
      for (var doc in snapshot.docs) {
        try {
          parsedProducts.add(FirebaseMapper.productFromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing product ${doc.id}: $e');
        }
      }
      return parsedProducts;
    });
  }

  Future<void> saveProduct(ProductModel product) async {
    await _db.collection('products').doc(product.id).set(FirebaseMapper.productToJson(product));
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // --- Users Methods ---

  Future<void> updateStoreStatus(String storeId, String status) async {
    await _db.collection('stores').doc(storeId).update({'status': status});
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error getting user $uid: $e');
      rethrow;
    }
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      debugPrint('Error saving user ${user.id}: $e');
      rethrow;
    }
  }
}
