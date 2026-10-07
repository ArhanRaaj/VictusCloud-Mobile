import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/errors/error_handler.dart';

class AuthRepository {
  final SupabaseClient _supabase;
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  AuthRepository(this._supabase, this._secureStorage, this._localAuth);

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (response.session != null) {
        await storeSessionSecurely(response.session!.accessToken);
      }
      return response;
    } catch (e) {
      throw ErrorHandler.mapException(e);
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email, 
        password: password,
        data: {'name': name},
      );
      if (response.session != null) {
        await storeSessionSecurely(response.session!.accessToken);
      }
      return response;
    } catch (e) {
      throw ErrorHandler.mapException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await clearStoredSession();
    } catch (e) {
      throw ErrorHandler.mapException(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw ErrorHandler.mapException(e);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      return await _supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      throw ErrorHandler.mapException(e);
    }
  }

  Future<bool> signInWithDiscord() async {
    try {
      return await _supabase.auth.signInWithOAuth(OAuthProvider.discord);
    } catch (e) {
      throw ErrorHandler.mapException(e);
    }
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  Stream<AuthState> get onAuthStateChange {
    return _supabase.auth.onAuthStateChange;
  }

  Future<void> updateProfile({String? name, String? avatar}) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatar != null) updates['avatar_url'] = avatar;
      await _supabase.auth.updateUser(UserAttributes(data: updates));
    } catch (e) {
      throw ErrorHandler.mapException(e);
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw ErrorHandler.mapException(e);
    }
  }

  Future<void> enableBiometric() async {
    await _secureStorage.write(key: 'biometricEnabled', value: 'true');
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics && await _localAuth.isDeviceSupported();
      if (!isAvailable) return false;
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access VictusCloud',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> storeSessionSecurely(String session) async {
    await _secureStorage.write(key: 'supabaseSession', value: session);
  }

  Future<String?> retrieveStoredSession() async {
    return await _secureStorage.read(key: 'supabaseSession');
  }

  Future<void> clearStoredSession() async {
    await _secureStorage.delete(key: 'supabaseSession');
  }
}
