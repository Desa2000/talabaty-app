import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class OrderApiService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> validateCart({
    required String storeId,
    required List<Map<String, dynamic>> items,
    double? deliveryLat,
    double? deliveryLng,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/cart/validate',
        data: {
          'storeId': storeId,
          'items': items,
          'deliveryLatitude': deliveryLat,
          'deliveryLongitude': deliveryLng,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل حساب السلة');
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required String storeId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required double deliveryLatitude,
    required double deliveryLongitude,
    required String paymentMethod,
    String? customerNotes,
    String? bankakProofImage,
    String? bankakTxnRef,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/orders',
        data: {
          'storeId': storeId,
          'items': items,
          'deliveryAddress': deliveryAddress,
          'deliveryLatitude': deliveryLatitude,
          'deliveryLongitude': deliveryLongitude,
          'paymentMethod': paymentMethod,
          'customerNotes': customerNotes,
          'bankakProofImage': bankakProofImage,
          'bankakTxnRef': bankakTxnRef,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل إنشاء الطلب');
    }
  }

  Future<List<dynamic>> getMyOrders() async {
    try {
      final response = await _apiClient.dio.get('/orders/my');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل جلب الطلبات');
    }
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await _apiClient.dio.get('/orders/$orderId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل جلب تفاصيل الطلب');
    }
  }

  // Merchant actions
  Future<Map<String, dynamic>> merchantAcceptOrder(String orderId) async {
    final response = await _apiClient.dio.post('/orders/$orderId/merchant/accept');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> merchantRejectOrder(String orderId, String? reason) async {
    final response = await _apiClient.dio.post('/orders/$orderId/merchant/reject', data: {'note': reason});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> merchantStartPreparing(String orderId) async {
    final response = await _apiClient.dio.post('/orders/$orderId/preparing');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> merchantReadyForPickup(String orderId) async {
    final response = await _apiClient.dio.post('/orders/$orderId/ready');
    return response.data as Map<String, dynamic>;
  }

  // Courier actions
  Future<Map<String, dynamic>> courierAcceptOrder(String orderId) async {
    final response = await _apiClient.dio.post('/orders/$orderId/courier/accept');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> courierPickupOrder(String orderId) async {
    final response = await _apiClient.dio.post('/orders/$orderId/picked-up');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> courierOnTheWay(String orderId) async {
    final response = await _apiClient.dio.post('/orders/$orderId/on-the-way');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> courierArrived(String orderId) async {
    final response = await _apiClient.dio.post('/orders/$orderId/arrived');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> courierDelivered(String orderId) async {
    final response = await _apiClient.dio.post('/orders/$orderId/delivered');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> customerCancelOrder(String orderId) async {
    final response = await _apiClient.dio.post('/orders/$orderId/cancel');
    return response.data as Map<String, dynamic>;
  }
}
