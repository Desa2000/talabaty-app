import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/user_model.dart';
import '../../core/constants/enums.dart';

class AuthApiService {
  final ApiClient _apiClient = ApiClient();

  /// Map JSON to UserModel (parsing the backend structure)
  UserModel _parseUser(Map<String, dynamic> json) {
    // Parse role string to UserRole enum
    UserRole roleVal = UserRole.customer;
    final roleStr = json['role']?.toString().toUpperCase();
    if (roleStr == 'ADMIN') roleVal = UserRole.admin;
    if (roleStr == 'MERCHANT') roleVal = UserRole.merchant;
    if (roleStr == 'COURIER') roleVal = UserRole.courier;

    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      password: '', // Password is never returned
      role: roleVal,
      profileImage: json['profileImage'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.registerCustomer,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
        },
      );

      final user = _parseUser(response.data['user']);
      return {
        'user': user,
        'accessToken': response.data['accessToken'],
        'refreshToken': response.data['refreshToken'],
      };
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(message: e.message ?? 'فشلت عملية التسجيل');
    }
  }

  Future<Map<String, dynamic>> registerMerchant({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String businessName,
    required String businessDescription,
    required String businessArea,
    required String storeName,
    required String storeCategory,
    required String storeAddress,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.registerMerchant,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'businessName': businessName,
          'businessDescription': businessDescription,
          'businessArea': businessArea,
          'storeName': storeName,
          'storeCategory': storeCategory,
          'storeAddress': storeAddress,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      final user = _parseUser(response.data['user']);
      return {
        'user': user,
        'accessToken': response.data['accessToken'],
        'refreshToken': response.data['refreshToken'],
      };
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(message: e.message ?? 'فشلت عملية التسجيل');
    }
  }

  Future<Map<String, dynamic>> registerCourier({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String vehicleType,
    required String idNumber,
    required String licenseNumber,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.registerCourier,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'vehicleType': vehicleType,
          'idNumber': idNumber,
          'licenseNumber': licenseNumber,
        },
      );

      final user = _parseUser(response.data['user']);
      return {
        'user': user,
        'accessToken': response.data['accessToken'],
        'refreshToken': response.data['refreshToken'],
      };
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(message: e.message ?? 'فشلت عملية التسجيل');
    }
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      final user = _parseUser(response.data['user']);
      return {
        'user': user,
        'accessToken': response.data['accessToken'],
        'refreshToken': response.data['refreshToken'],
      };
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(message: e.message ?? 'فشل تسجيل الدخول');
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _apiClient.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.dio.post(
          ApiEndpoints.logout,
          data: {'refreshToken': refreshToken},
        );
      }
      await _apiClient.clearTokens();
    } catch (_) {
      await _apiClient.clearTokens();
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      return _parseUser(response.data);
    } catch (e) {
      return null;
    }
  }
}
