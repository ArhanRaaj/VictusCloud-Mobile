import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/secure_storage_service.dart';

class ApiClient {
  late Dio _dio;
  final SecureStorageService _secureStorageService = SecureStorageService();

  ApiClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      // Set to force HTTPS
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorageService.getToken('supabaseSession');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle retries
        if (e.response?.statusCode == 429 || (e.response?.statusCode != null && e.response!.statusCode! >= 500)) {
           // Retry logic could go here
        }
        return handler.next(e);
      }
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        responseHeader: true,
        requestBody: true,
        responseBody: true,
        logPrint: (log) {
          final strLog = log.toString();
          if (!strLog.contains('Bearer ')) {
            print(strLog);
          }
        }
      ));
    }
  }

  Dio get dio => _dio;
}
