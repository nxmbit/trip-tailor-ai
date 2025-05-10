import 'package:dio/dio.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/domain/services/token_service.dart';
import 'package:frontend/data/api/endpoints.dart';

/// Intercepts 401 errors and attempts to refresh the token
class TokenRefreshInterceptor extends Interceptor {
  final TokenService _tokenService;
  final Dio _dio;
  final AuthService _authService;
  bool _isRefreshing = false;

  TokenRefreshInterceptor(this._tokenService, this._dio, this._authService);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _tokenService.getRefreshToken();
      final isValid = await _tokenService.isRefreshTokenValid();

      if (refreshToken == null || !isValid) {
        await _authService.logout();
        return handler.next(err);
      }

      // Try to refresh the token
      final refreshResponse = await Dio().post(
        '${APIConstants.baseUrl}${APIConstants.refreshTokenEndpoint}',
        data: {'refreshToken': refreshToken},
      );

      if (refreshResponse.statusCode == 200) {
        // Store new tokens
        await _tokenService.saveTokens(
          jwtToken: refreshResponse.data['jwtToken'],
          jwtExpirationTimestamp: refreshResponse.data['jwtExpirationDate'],
          refreshToken: refreshResponse.data['refreshToken'],
          refreshExpirationTimestamp:
              refreshResponse.data['refreshTokenExpirationDate'],
        );

        // Retry the original request
        final options = err.requestOptions;
        final token = await _tokenService.getToken();
        options.headers['Authorization'] = 'Bearer $token';

        final response = await _dio.fetch(options);
        return handler.resolve(response);
      } else {
        await _authService.logout();
        return handler.next(err);
      }
    } catch (e) {
      await _authService.logout();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
