import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/store_model.dart';
import '../models/product_model.dart';
import '../../core/constants/enums.dart';

class StoreApiService {
  final ApiClient _apiClient = ApiClient();

  StoreType _parseStoreType(String? category) {
    if (category == 'SUPERMARKET') return StoreType.supermarket;
    if (category == 'PHARMACY') return StoreType.pharmacy;
    return StoreType.restaurant;
  }

  StoreModel _parseStore(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? '',
      ownerId: json['merchantId'] ?? '',
      name: json['name'] ?? '',
      type: _parseStoreType(json['category']?.toString()),
      logo: json['logoUrl'] ?? 'assets/images/logo.png',
      coverImage: json['coverUrl'] ?? 'assets/images/placeholder_cover.png',
      phone: json['phone'] ?? '0912345678',
      area: json['address'] ?? 'الخرطوم',
      street: json['address'] ?? 'الخرطوم',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 15.5640,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 32.5840,
      openingTime: '08:00 AM',
      closingTime: '11:00 PM',
      preparationTime: '${json['estimatedPrepTime'] ?? 20} دقيقة',
      minimumOrder: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 500.0,
      status: (json['isOpen'] ?? true) ? StoreStatus.open : StoreStatus.closed,
      rating: 4.8,
      ratingCount: 120,
    );
  }

  ProductModel _parseProduct(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      name: json['nameAr'] ?? json['nameEn'] ?? json['name'] ?? '',
      description:
          json['descriptionAr'] ??
          json['descriptionEn'] ??
          json['description'] ??
          '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      image: json['imageUrl'] ?? 'assets/images/placeholder_product.png',
      category:
          json['category']?['nameAr'] ?? json['category']?['nameEn'] ?? 'أخرى',
      isAvailable: json['isAvailable'] ?? true,
      stockQuantity: json['stock'] ?? 100,
    );
  }

  Future<List<StoreModel>> fetchStores({
    String? category,
    double? lat,
    double? lng,
    String? q,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (lat != null) queryParams['lat'] = lat;
      if (lng != null) queryParams['lng'] = lng;
      if (q != null && q.isNotEmpty) queryParams['q'] = q;

      final response = await _apiClient.dio.get(
        '/stores',
        queryParameters: queryParams,
      );

      final List data = response.data as List;
      return data
          .map((json) => _parseStore(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشلت عملية جلب المتاجر');
    }
  }

  Future<Map<String, dynamic>> fetchStoreDetails(String storeId) async {
    try {
      final response = await _apiClient.dio.get('/stores/$storeId');
      final json = response.data as Map<String, dynamic>;
      final store = _parseStore(json);

      final List productsJson = json['products'] ?? [];
      final products = productsJson
          .map((p) => _parseProduct(p as Map<String, dynamic>))
          .toList();

      return {'store': store, 'products': products};
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشلت عملية جلب تفاصيل المتجر');
    }
  }

  /// Update store open/closed status via backend
  Future<void> updateStoreStatus(String storeId, bool isOpen) async {
    try {
      await _apiClient.dio.put('/merchant/stores/$storeId', data: {'isOpen': isOpen});
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل تحديث حالة المتجر');
    }
  }

  /// Update store profile fields via backend
  Future<void> updateStore(StoreModel store) async {
    try {
      await _apiClient.dio.put(
        '/merchant/stores/${store.id}',
        data: {
          'name': store.name,
          'latitude': store.latitude,
          'longitude': store.longitude,
          'deliveryFee': store.deliveryFee,
          'minOrderAmount': store.minimumOrder,
          'estimatedPrepTime':
              int.tryParse(
                store.preparationTime.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              20,
          'isOpen': store.status == StoreStatus.open,
        },
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل تحديث بيانات المتجر');
    }
  }


  Map<String, dynamic> _productPayload(ProductModel product) {
    final data = <String, dynamic>{
      'storeId': product.storeId,
      'categoryName': product.category,
      'nameAr': product.name,
      'descriptionAr': product.description,
      'price': product.price,
      'isAvailable': product.isAvailable,
      'stock': product.stockQuantity,
      'unit': 'piece',
      'preparationNotes':
          'زمن التحضير التقريبي: ${product.preparationTimeMinutes} دقيقة',
    };

    if (product.discountPrice != null && product.discountPrice! > 0) {
      data['discountPrice'] = product.discountPrice;
    }

    if (product.image.startsWith('http://') ||
        product.image.startsWith('https://')) {
      data['imageUrl'] = product.image;
    }

    return data;
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _apiClient.dio.post(
        '/merchant/products',
        data: _productPayload(product),
      );
      final saved = _parseProduct(response.data as Map<String, dynamic>);
      return saved.copyWith(
        category: product.category,
        lowStockThreshold: product.lowStockThreshold,
        preparationTimeMinutes: product.preparationTimeMinutes,
        isFeatured: product.isFeatured,
        allowCustomerNotes: product.allowCustomerNotes,
        optionGroups: product.optionGroups,
        addOns: product.addOns,
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل إضافة المنتج');
    }
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final response = await _apiClient.dio.put(
        '/merchant/products/${product.id}',
        data: _productPayload(product),
      );
      final saved = _parseProduct(response.data as Map<String, dynamic>);
      return saved.copyWith(
        category: product.category,
        lowStockThreshold: product.lowStockThreshold,
        preparationTimeMinutes: product.preparationTimeMinutes,
        isFeatured: product.isFeatured,
        allowCustomerNotes: product.allowCustomerNotes,
        optionGroups: product.optionGroups,
        addOns: product.addOns,
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل تعديل المنتج');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _apiClient.dio.delete('/merchant/products/$productId');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل حذف المنتج');
    }
  }

  /// Upload a product image to backend and return the hosted URL
  Future<String> uploadProductImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: 'product.jpg'),
      });
      final response = await _apiClient.dio.post('/upload', data: formData);
      return (response.data as Map<String, dynamic>)['url'] as String? ?? '';
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل رفع الصورة');
    }
  }
}
