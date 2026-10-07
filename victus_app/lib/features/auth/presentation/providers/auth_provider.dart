import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../data/repositories/auth_repository.dart';
import '../domain/entities/auth_state.dart';
import '../data/models/user_model.dart';
import '../../../core/errors/error_handler.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());
final localAuthProvider = Provider<LocalAuthentication>((ref) => LocalAuthentication());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(secureStorageProvider),
    ref.watch(localAuthProvider),
  );
});

final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(localAuthProvider);
  return await auth.canCheckBiometrics && await auth.isDeviceSupported();
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AppAuthState>((ref) {
  return AuthStateNotifier(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final state = ref.watch(authStateProvider);
  if (state is Authenticated) return state.user;
  if (state is NeedsPanelLink) return state.user;
  return null;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider) is Authenticated;
});

class AuthStateNotifier extends StateNotifier<AppAuthState> {
  final AuthRepository _repository;

  AuthStateNotifier(this._repository) : super(const AuthInitial()) {
    _initAuthListener();
  }

  void _initAuthListener() {
    _repository.onAuthStateChange.listen((event) {
      if (event.session != null && event.user != null) {
        final userModel = UserModel.fromSupabaseUser(event.user!);
        if (!userModel.panelLinked) {
          state = NeedsPanelLink(userModel);
        } else {
          state = Authenticated(userModel);
        }
      } else {
        state = const Unauthenticated();
      }
    });
  }

  Future<void> checkSession() async {
    state = const AuthLoading();
    final user = _repository.getCurrentUser();
    if (user != null) {
      final userModel = UserModel.fromSupabaseUser(user);
      state = userModel.panelLinked ? Authenticated(userModel) : NeedsPanelLink(userModel);
    } else {
      state = const Unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      await _repository.signInWithEmail(email, password);
      // state updated by listener
    } catch (e) {
      state = AuthErrorState(ErrorHandler.getUserMessage(ErrorHandler.mapException(e)));
    }
  }

  Future<void> signup(String email, String password, String name) async {
    state = const AuthLoading();
    try {
      await _repository.signUpWithEmail(email, password, name);
    } catch (e) {
      state = AuthErrorState(ErrorHandler.getUserMessage(ErrorHandler.mapException(e)));
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _repository.signOut();
    } catch (e) {
      state = AuthErrorState(ErrorHandler.getUserMessage(ErrorHandler.mapException(e)));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _repository.resetPassword(email);
    } catch (e) {
      state = AuthErrorState(ErrorHandler.getUserMessage(ErrorHandler.mapException(e)));
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AuthLoading();
    try {
      await _repository.signInWithGoogle();
    } catch (e) {
      state = AuthErrorState(ErrorHandler.getUserMessage(ErrorHandler.mapException(e)));
    }
  }

  Future<void> loginWithDiscord() async {
    state = const AuthLoading();
    try {
      await _repository.signInWithDiscord();
    } catch (e) {
      state = AuthErrorState(ErrorHandler.getUserMessage(ErrorHandler.mapException(e)));
    }
  }

  Future<void> enableBiometric() async {
    await _repository.enableBiometric();
  }

  Future<bool> loginWithBiometric() async {
    final success = await _repository.authenticateWithBiometric();
    if (success) {
      await checkSession();
    }
    return success;
  }
}
