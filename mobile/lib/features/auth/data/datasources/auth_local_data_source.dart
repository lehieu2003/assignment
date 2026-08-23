import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveToken(String token) async {
    try {
      await sharedPreferences.setString(AppConstants.tokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Failed to cache token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString(AppConstants.tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve cached token');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await sharedPreferences.remove(AppConstants.tokenKey);
      await sharedPreferences.remove(AppConstants.userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear token');
    }
  }

  @override
  Future<bool> hasToken() async {
    final token = sharedPreferences.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }
}
