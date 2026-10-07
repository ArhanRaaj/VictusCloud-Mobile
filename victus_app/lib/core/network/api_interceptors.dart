import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  // Implementation of AuthInterceptor using secure storage or similar should be added here
  // For the sake of this file structure, we assume an abstract implementation

  final String Function() getPterodactylToken;
  final String Function() getPaymenterToken;
  final bool Function(RequestOptions) isPterodactylRequest;

  AuthInterceptor({
    required this.getPterodactylToken,
    required this.getPaymenterToken,
    required this.isPterodactylRequest,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String token = isPterodactylRequest(options) ? getPterodactylToken() : getPaymenterToken();
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;

  RetryInterceptor({required this.dio});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 429) {
      final retryAfter = err.response?.headers.value('retry-after');
      if (retryAfter != null) {
        final delay = int.tryParse(retryAfter) ?? 1;
        await Future.delayed(Duration(seconds: delay));
        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(err, handler);
        }
      }
    } else if (err.response != null && err.response!.statusCode! >= 500) {
      int retries = err.requestOptions.extra['retries'] ?? 0;
      if (retries < 3) {
        err.requestOptions.extra['retries'] = retries + 1;
        await Future.delayed(Duration(seconds: 1 << retries));
        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(err, handler);
        }
      }
    }
    super.onError(err, handler);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    // Avoid logging auth headers
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    super.onError(err, handler);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Map HTTP errors to AppException types
    // AppException is a custom exception type that can be defined elsewhere
    super.onError(err, handler);
  }
}
