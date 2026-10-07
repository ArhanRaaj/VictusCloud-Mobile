import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Env.supabaseAnonKey;

  @EnviedField(varName: 'PTERODACTYL_URL')
  static const String pterodactylUrl = _Env.pterodactylUrl;

  @EnviedField(varName: 'PAYMENTER_URL')
  static const String paymenterUrl = _Env.paymenterUrl;

  @EnviedField(varName: 'FCM_SENDER_ID')
  static const String fcmSenderId = _Env.fcmSenderId;
}
