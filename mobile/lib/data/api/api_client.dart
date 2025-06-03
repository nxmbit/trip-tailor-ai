import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/data/api/endpoints.dart';
import 'package:frontend/data/api/interceptors/auth_token_interceptor.dart';
import 'package:frontend/data/api/interceptors/token_refresh_interceptor.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/domain/services/token_service.dart';

class ApiClient {
  late final Dio dio;
  final TokenService tokenService;

  // This will be set after AuthService is created
  AuthService? _authService;

  ApiClient({required this.tokenService}) {
    dio = _createDio();
    // Add interceptors that don't depend on auth service
    _setupBaseInterceptors();
  }

  // Set auth service after it's created (to avoid circular dependency)
  void setAuthService(AuthService authService) {
    _authService = authService;
    _setupAuthInterceptors();
  }

  Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        validateStatus: (status) => status! <= 204,
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  // Setup interceptors that don't depend on auth service
  void _setupBaseInterceptors() {
    dio.interceptors.clear();

    // Add auth token interceptor
    dio.interceptors.add(AuthTokenInterceptor(tokenService));

    // Add logging in debug mode
    // if (kDebugMode) {
    //   dio.interceptors.add(
    //     LogInterceptor(requestBody: true, responseBody: true),
    //   );
    // }
  }

  // Setup interceptors that depend on auth service
  void _setupAuthInterceptors() {
    // Add token refresh interceptor if auth service is available
    if (_authService != null) {
      dio.interceptors.add(
        TokenRefreshInterceptor(tokenService, dio, _authService!),
      );
    }
  }
}
