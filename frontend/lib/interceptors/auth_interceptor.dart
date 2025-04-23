import 'package:dio/dio.dart';
import 'package:frontend/services/auth_service.dart';

/// Interceptor to send the bearer access token
class AuthInterceptor extends Interceptor {
  final AuthService _authService;
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._authService, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // create a list of the endpoints where you don't need to pass a token.
    final listOfPaths = <String>['/', '/signin', '/signup'];

    // Check if the requested endpoint match in the
    if (listOfPaths.contains(options.path.toString())) {
      // if the endpoint is matched then skip adding the token.
      return handler.next(options);
    }

    // Load your token here and pass to the header
    var token = (await _authService.getToken()) ?? '';
    options.headers.addAll({'Authorization': "Bearer $token"});
    return handler.next(options);
  }

  // You can also perform some actions in the response or onError.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('onError called with status code: ${err.response?.statusCode}');

    if (err.response?.statusCode != 401 || _isRefreshing) {
      print('Error is not 401 or already refreshing. Passing to next handler.');
      return handler.next(err);
    }

    print('401 error detected. Starting token refresh process.');
    _isRefreshing = true;

    try {
      final refreshSuccess = await _authService.refreshTokens();
      print('Token refresh success: $refreshSuccess');

      if (!refreshSuccess) {
        print('Token refresh failed. Logging out.');
        await _authService.logout(notifyServer: false);
        return handler.next(err);
      }

      // Retry the original request with new token
      final token = await _authService.getToken();
      print('New token acquired: $token');

      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $token';

      print('Retrying original request with new token.');
      final response = await _dio.fetch(options);
      print('Request retried successfully.');
      return handler.resolve(response);
    } catch (e) {
      print('Error during token refresh: $e');
      await _authService.logout(notifyServer: true);
      return handler.next(err);
    } finally {
      print('Resetting _isRefreshing flag.');
      _isRefreshing = false;
    }
  }
}
