import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/user_model.dart';

class AddressApiService {
  final ApiClient _apiClient = ApiClient();

  AddressModel _parseAddress(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      label: json['title'] ?? 'البيت',
      area: json['area'] ?? '',
      street: json['street'] ?? '',
      landmark: json['landmark'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 15.5640,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 32.5840,
      phone: json['phone'] ?? '0912345678',
      isDefault: false,
    );
  }

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiClient.dio.get('/addresses');
      final List data = response.data as List;
      return data.map((json) => _parseAddress(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل جلب العناوين');
    }
  }

  Future<AddressModel> createAddress({
    required String title,
    required String area,
    required String street,
    String? landmark,
    required double latitude,
    required double longitude,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/addresses',
        data: {
          'title': title,
          'area': area,
          'street': street,
          'landmark': landmark,
          'latitude': latitude,
          'longitude': longitude,
          'phone': phone,
        },
      );
      return _parseAddress(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل حفظ العنوان');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _apiClient.dio.delete('/addresses/$id');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'فشل حذف العنوان');
    }
  }
}
