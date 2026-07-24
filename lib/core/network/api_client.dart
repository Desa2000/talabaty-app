import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Callback to notify the app (like AuthProvider) when the session expires
  VoidCallback? onSessionExpired;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Public auth endpoints must not send Authorization header
          final path = options.path;
          final isPublicAuth = path.contains('/api/auth/login') ||
              path.contains('/api/auth/register') ||
              path.contains('/api/auth/otp-login') ||
              path.contains('/api/auth/refresh');

          if (!isPublicAuth) {
            final token = await _secureStorage.read(key: 'accessToken');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException err, handler) async {
          // Wrap DioException error with structured ApiException
          final apiException = ApiException.fromDioException(err);
          final errWithApiEx = DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: err.type,
            error: apiException,
          );

          // If 401 (Unauthorized) on a protected route, attempt token refresh
          if (err.response?.statusCode == 401) {
            final requestOptions = err.requestOptions;

            // Avoid infinite loops if auth endpoints themselves return 401
            if (requestOptions.path.contains(ApiEndpoints.refresh) ||
                requestOptions.path.contains(ApiEndpoints.login) ||
                requestOptions.path.contains('/api/auth/')) {
              return handler.next(errWithApiEx);
            }

            try {
              final refreshToken = await _secureStorage.read(key: 'refreshToken');
              if (refreshToken == null) {
                _handleSessionExpiry();
                return handler.next(errWithApiEx);
              }

              // Perform token refresh using a clean Dio instance
              final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
              final response = await refreshDio.post(
                ApiEndpoints.refresh,
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200 && response.data != null) {
                final newAccessToken = response.data['accessToken'];
                await _secureStorage.write(key: 'accessToken', value: newAccessToken);

                // Update Authorization header and retry the request
                requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final cloneReq = await dio.fetch(requestOptions);
                return handler.resolve(cloneReq);
              }
            } catch (refreshErr) {
              debugPrint('Token refresh failed: $refreshErr');
              _handleSessionExpiry();
              return handler.next(errWithApiEx);
            }
          }

          return handler.next(errWithApiEx);
        },
      ),
    );
  }

  Future<void> _handleSessionExpiry() async {
    await clearTokens();
    if (onSessionExpired != null) {
      onSessionExpired!();
    }
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _secureStorage.write(key: 'accessToken', value: accessToken);
    await _secureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refreshToken');
  }
}
