import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'app_exception.dart';

class ErrorHandler {
  static AppException mapException(dynamic error) {
    if (error is AppException) return error;

    if (error is sb.AuthException) {
      return _mapSupabaseAuthException(error);
    }

    if (error is DioException) {
      return _mapDioException(error);
    }

    if (error is PlatformException) {
      return NetworkException(error.message ?? 'A platform error occurred', originalError: error);
    }

    return NetworkException(error.toString(), originalError: error);
  }

  static AuthException _mapSupabaseAuthException(sb.AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials') || message.contains('invalid credentials')) {
      return const AuthException('Invalid email or password.', type: AuthErrorType.invalidCredentials);
    }
    if (message.contains('email not confirmed')) {
      return const AuthException('Email not confirmed. Please check your inbox.', type: AuthErrorType.emailNotVerified);
    }
    if (message.contains('user already registered')) {
      return const AuthException('This email is already registered.', type: AuthErrorType.emailInUse);
    }
    if (message.contains('password')) {
      return const AuthException('Password does not meet security requirements.', type: AuthErrorType.weakPassword);
    }
    return AuthException(error.message, type: AuthErrorType.unknown);
  }

  static AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException('Connection timed out. Please try again.');
    }
    if (error.response != null) {
      return ApiException(
        error.response?.data?['errors']?[0]?['detail'] ?? error.message ?? 'Server error',
        statusCode: error.response?.statusCode ?? 500,
        originalError: error,
      );
    }
    return NetworkException(error.message ?? 'Network connection failed', originalError: error);
  }

  static String getUserMessage(AppException exception) {
    if (exception is AuthException) {
      switch (exception.type) {
        case AuthErrorType.invalidCredentials:
          return 'Invalid email or password.';
        case AuthErrorType.emailNotVerified:
          return 'Please verify your email address.';
        case AuthErrorType.emailInUse:
          return 'This email is already registered.';
        case AuthErrorType.weakPassword:
          return 'Your password is too weak.';
        case AuthErrorType.accountDisabled:
          return 'This account has been disabled.';
        default:
          return exception.message;
      }
    } else if (exception is NetworkException) {
      return 'Please check your internet connection and try again.';
    } else if (exception is TimeoutException) {
      return 'The request timed out. Please try again.';
    } else if (exception is ApiException) {
      return exception.message;
    }
    return exception.message.isNotEmpty ? exception.message : 'An unexpected error occurred. Please try again.';
  }
}
