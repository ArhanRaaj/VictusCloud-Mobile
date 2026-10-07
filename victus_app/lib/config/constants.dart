class AppConstants {
  // App
  static const String appName = 'VictusCloud';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  // API Paths
  static const String apiV1 = '/api/v1';
  static const String pterodactylClientApi = '/api/client';
  
  // Cache Durations
  static const Duration maxCacheAge = Duration(hours: 24);
  static const Duration shortCacheAge = Duration(minutes: 5);

  // Hive Boxes
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';

  // Secure Storage Keys
  static const String tokenKey = 'secure_auth_token';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
}
