import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:lms/core/constants/app_constants.dart';

class SocialAuthResult {

  const SocialAuthResult({
    this.accessToken,
    this.refreshToken,
    this.tempToken,
  });
  final String? accessToken;
  final String? refreshToken;
  final String? tempToken;

  bool get isComplete => accessToken != null;
  bool get needsRegistration => tempToken != null;
}

class SocialAuthService {
  SocialAuthService();

  final String _callbackScheme = 'lmsapp';

  String getGoogleAuthUrl({
    String role = 'learner',
    String client = 'mobile',
  }) {
    return '${AppConstants.baseUrl}/auth/google?role=$role&client=$client';
  }

  String getFacebookAuthUrl({
    String role = 'learner',
    String client = 'mobile',
  }) {
    return '${AppConstants.baseUrl}/auth/facebook?role=$role&client=$client';
  }

  Future<SocialAuthResult> signInWithGoogle({
    String role = 'learner',
    String client = 'mobile',
  }) async {
    final url = getGoogleAuthUrl(role: role, client: client);
    return _authenticate(url);
  }

  Future<SocialAuthResult> signInWithFacebook({
    String role = 'learner',
    String client = 'mobile',
  }) async {
    final url = getFacebookAuthUrl(role: role, client: client);
    return _authenticate(url);
  }

  Future<SocialAuthResult> _authenticate(String url) async {
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: _callbackScheme,
      );

      return _parseCallbackResult(result);
    } catch (e) {
      // User cancelled or an error occurred
      throw SocialAuthException(e.toString());
    }
  }

  SocialAuthResult _parseCallbackResult(String callbackUrl) {
    final uri = Uri.parse(callbackUrl);

    final accessToken = uri.queryParameters['accessToken']
        ?? uri.queryParameters['access_token'];
    final refreshToken = uri.queryParameters['refreshToken']
        ?? uri.queryParameters['refresh_token'];
    final tempToken = uri.queryParameters['tempToken']
        ?? uri.queryParameters['temp_token'];

    if (accessToken != null && refreshToken != null) {
      return SocialAuthResult(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    if (tempToken != null) {
      return SocialAuthResult(tempToken: tempToken);
    }

    // If no tokens found in query, check the fragment
    if (uri.fragment.isNotEmpty) {
      final fragmentParams = Uri.splitQueryString(uri.fragment);
      final fragAccessToken = fragmentParams['accessToken']
          ?? fragmentParams['access_token'];
      final fragRefreshToken = fragmentParams['refreshToken']
          ?? fragmentParams['refresh_token'];
      final fragTempToken = fragmentParams['tempToken']
          ?? fragmentParams['temp_token'];

      if (fragAccessToken != null && fragRefreshToken != null) {
        return SocialAuthResult(
          accessToken: fragAccessToken,
          refreshToken: fragRefreshToken,
        );
      }

      if (fragTempToken != null) {
        return SocialAuthResult(tempToken: fragTempToken);
      }
    }

    throw const SocialAuthException('No auth data found in callback');
  }
}

class SocialAuthException implements Exception {
  const SocialAuthException(this.message);
  final String message;

  @override
  String toString() => 'SocialAuthException: $message';
}
