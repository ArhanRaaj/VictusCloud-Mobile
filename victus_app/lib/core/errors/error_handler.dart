import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'app_exception.dart';

class ErrorHandler {
  static AppException mapException(dynamic error) {
    if (error is AppException) return error;

    if (error is AuthException) {
       return error; // supabase auth exception? wait, let's check Supabase types
    }
    
    if (error is AuthException) {
       // Wait, my AuthException is different from Supabase AuthException.
    }
    
    if (error is AuthException || error is PostgrestException) {
       if (error is supabase_flutter.AuthException) {
           return _mapSupabaseAuthException(error);
       }
    }

    if (error is DioException) {
      return _mapDioException(error);
    }

    if (error is PlatformException) {
      return AppException(error.message ?? 'A platform error occurred', code: error.code, originalError: error);
    }

    return AppException(error.toString(), code: 'UNKNOWN_ERROR', originalError: error);
  }

  static AuthException _mapSupabaseAuthException(dynamic error) {
      final msg = error.message.toString().toLowerCase();
      AuthErrorType type = AuthErrorType.unknown;
      if (msg.contains('invalid login credentials')) {
        type = AuthErrorType.invalidCredentials;
      } else if (msg.contains('email not confirmed')) {
        type = AuthErrorType.emailNotVerified;
      } else if (msg.contains('already registered')) {
        type = AuthErrorType.emailInUse;
      } else if (msg.contains('password should be at least')) {
        type = AuthErrorType.weakPassword;
      }

      return AuthException(error.message, type: type, originalError: error);
  }

  static AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timed out', originalError: error);
      case DioExceptionType.badResponse:
        return ApiException(
          error.response?.statusMessage ?? 'Bad response',
          statusCode: error.response?.statusCode ?? 500,
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection', originalError: error);
      default:
        return NetworkException('Network error occurred', originalError: error);
    }
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
      return 'Server error occurred. Please try again later.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
