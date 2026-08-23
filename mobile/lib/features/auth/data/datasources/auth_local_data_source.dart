import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveToken(String token) async {
    try {
      await secureStorage.write(key: AppConstants.tokenKey, value: token);
    } catch (e) {
      throw CacheException(message: 'Failed to securely save token');
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
  Future<void> clearToken() async {
    try {
      await secureStorage.delete(key: AppConstants.tokenKey);
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
