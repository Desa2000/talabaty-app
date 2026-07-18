import '../models/product_model.dart';
import '../../core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firebase_mapper.dart';
import 'package:flutter/foundation.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<ProductModel>> getProductsByStoreId(String storeId) async {
    try {
      final snapshot = await _db
          .collection('products')
          .where('storeId', isEqualTo: storeId)
          .get();
      
      return snapshot.docs.map((doc) => FirebaseMapper.productFromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting products by store id: $e');
      rethrow;
    }
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    await _firestoreService.saveProduct(product);
    return product;
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    await _firestoreService.saveProduct(product);
    return product;
  }

  Future<void> deleteProduct(String productId) async {
    await _firestoreService.deleteProduct(productId);
  }

  Future<void> toggleProductAvailability(String productId, bool isAvailable) async {
    await _db.collection('products').doc(productId).update({'isAvailable': isAvailable});
  }

  Future<void> updateStock(String productId, int newQuantity) async {
    await _db.collection('products').doc(productId).update({'stockQuantity': newQuantity});
  }
}
