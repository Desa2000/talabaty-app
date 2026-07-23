import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class CourierApiService {
  final ApiClient _apiClient = ApiClient();

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? orderId,
    double? heading,
    double? speed,
  }) async {
    try {
      await _apiClient.dio.post(
        '/courier/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'orderId': orderId,
          'heading': heading ?? 0.0,
          'speed': speed ?? 0.0,
        },
      );
    } on DioException catch (e) {
      // Non-blocking location error logging
    }
  }

  Future<void> updateStatus(String status) async {
    try {
      await _apiClient.dio.post(
        '/courier/status',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل تحديث حالة المندوب');
    }
  }
}
