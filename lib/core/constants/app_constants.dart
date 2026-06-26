class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'LMS';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.example.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const String apiVersion = 'v1';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'cached_user';

  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;
}
