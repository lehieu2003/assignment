import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<void> clearToken();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    try {
      await secureStorage.write(key: AppConstants.tokenKey, value: accessToken);
      await secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw CacheException(message: 'Failed to securely save tokens');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: AppConstants.tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve securely saved token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await secureStorage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve securely saved refresh token');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await secureStorage.delete(key: AppConstants.tokenKey);
      await secureStorage.delete(key: AppConstants.refreshTokenKey);
      await secureStorage.delete(key: AppConstants.userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear secure token');
    }
  }

  @override
  Future<bool> hasToken() async {
    try {
      return await secureStorage.containsKey(key: AppConstants.tokenKey);
    } catch (e) {
      return false;
    }
  }
}

