import 'package:dio/dio.dart';
import 'package:frontend/domain/services/token_service.dart';

/// Interceptor to add the authorization token to requests
class AuthTokenInterceptor extends Interceptor {
  final TokenService _tokenService;

  AuthTokenInterceptor(this._tokenService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token for auth endpoints
    final publicEndpoints = ['/signin', '/signup', '/'];
    if (publicEndpoints.contains(options.path)) {
      return handler.next(options);
    }

    // Add token to authorized requests
    final token = await _tokenService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }
}
