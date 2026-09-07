import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class DioClient {
  final FlutterSecureStorage secureStorage;
  late final Dio dio;
  late final Dio _tokenDio; // Dedicated Dio instance for refresh calls to avoid interceptor loops

  DioClient({required this.secureStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _tokenDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await secureStorage.read(key: AppConstants.tokenKey);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // Ignore if unable to read token
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If 401 Unauthorized occurs on normal endpoints (excluding login/register/refresh)
          final isAuthPath = error.requestOptions.path.contains('/auth/login') ||
              error.requestOptions.path.contains('/auth/register') ||
              error.requestOptions.path.contains('/auth/refresh-token');

          if (error.response?.statusCode == 401 && !isAuthPath) {
            try {
              final refreshToken = await secureStorage.read(key: AppConstants.refreshTokenKey);
              if (refreshToken != null && refreshToken.isNotEmpty) {
                // Perform Refresh Token Rotation
                final refreshResponse = await _tokenDio.post(
                  ApiConstants.refreshToken,
                  data: {'refresh_token': refreshToken},
                );

                if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
                  final newAccessToken = refreshResponse.data['access_token'] as String;
                  final newRefreshToken = refreshResponse.data['refresh_token'] as String;

                  // Save the rotated new token pair
                  await secureStorage.write(key: AppConstants.tokenKey, value: newAccessToken);
                  await secureStorage.write(key: AppConstants.refreshTokenKey, value: newRefreshToken);

                  // Retry the original request with new access token
                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newAccessToken';

                  final retryResponse = await dio.fetch(options);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (refreshErr) {
              // Refresh failed or reuse detected -> clear tokens
              await secureStorage.delete(key: AppConstants.tokenKey);
              await secureStorage.delete(key: AppConstants.refreshTokenKey);
              await secureStorage.delete(key: AppConstants.userKey);
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }
}

