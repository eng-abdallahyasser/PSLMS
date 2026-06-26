import 'dart:convert';
import 'package:lms/core/constants/app_constants.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
  Future<String?> getRefreshToken();
  Future<void> saveRefreshToken(String token);
  Future<void> clearRefreshToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {

  AuthLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = sharedPreferences.getString(AppConstants.userKey);
      if (userJson != null) {
        return UserModel.fromJson(
          json.decode(userJson) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await sharedPreferences.setString(
        AppConstants.userKey,
        json.encode(user.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(AppConstants.userKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString(AppConstants.tokenKey);
    } catch (e) {
      throw CacheException('Failed to get token: $e');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await sharedPreferences.setString(AppConstants.tokenKey, token);
    } catch (e) {
      throw CacheException('Failed to save token: $e');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await sharedPreferences.remove(AppConstants.tokenKey);
    } catch (e) {
      throw CacheException('Failed to clear token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return sharedPreferences.getString(AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to get refresh token: $e');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await sharedPreferences.setString(AppConstants.refreshTokenKey, token);
    } catch (e) {
      throw CacheException('Failed to save refresh token: $e');
    }
  }

  @override
  Future<void> clearRefreshToken() async {
    try {
      await sharedPreferences.remove(AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to clear refresh token: $e');
    }
  }
}
