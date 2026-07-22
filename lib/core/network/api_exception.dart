import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException dioException) {
    String message = 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
    int? statusCode = dioException.response?.statusCode;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'فشلت عملية الاتصال بالخادم (انتهت المهلة). يرجى التحقق من اتصال الإنترنت.';
        break;
      case DioExceptionType.badResponse:
        final data = dioException.response?.data;
        if (data is Map && data.containsKey('error')) {
          message = data['error'].toString();
        } else {
          message = 'خطأ في الاستجابة من الخادم: $statusCode';
        }
        break;
      case DioExceptionType.cancel:
        message = 'تم إلغاء طلب الاتصال بالخادم';
        break;
      case DioExceptionType.connectionError:
        message = 'لا يوجد اتصال بالإنترنت أو الخادم غير متاح حالياً. يرجى التأكد من تشغيل السيرفر والشبكة.';
        break;
      case DioExceptionType.unknown:
      default:
        if (dioException.error != null && dioException.error.toString().contains('SocketException')) {
          message = 'تعذر الاتصال بالخادم. يرجى التأكد من تشغيل السيرفر وصحة عنوان الـ IP المكوّن.';
        } else {
          message = dioException.message ?? message;
        }
        break;
    }

    return ApiException(message: message, statusCode: statusCode);
  }

  @override
  String toString() => message;
}
