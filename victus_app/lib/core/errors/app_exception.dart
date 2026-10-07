abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

class NetworkException extends AppException {
  const NetworkException(String message, {dynamic originalError})
      : super(message, code: 'NETWORK_ERROR', originalError: originalError);
}

class AuthException extends AppException {
  final AuthErrorType type;

  const AuthException(String message, {required this.type, dynamic originalError})
      : super(message, code: type.name, originalError: originalError);
}

enum AuthErrorType {
  invalidCredentials,
  emailNotVerified,
  accountDisabled,
  weakPassword,
  emailInUse,
  unknown
}

class ApiException extends AppException {
  final int statusCode;

  const ApiException(String message, {required this.statusCode, dynamic originalError})
      : super(message, code: 'API_ERROR_$statusCode', originalError: originalError);
}

class CacheException extends AppException {
  const CacheException(String message, {dynamic originalError})
      : super(message, code: 'CACHE_ERROR', originalError: originalError);
}

class TimeoutException extends AppException {
  const TimeoutException(String message, {dynamic originalError})
      : super(message, code: 'TIMEOUT_ERROR', originalError: originalError);
}
