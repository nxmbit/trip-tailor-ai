import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/data/api/api_client.dart';
import 'package:frontend/data/api/endpoints.dart';
import 'package:frontend/domain/services/token_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  AuthService(this._apiClient, this._tokenService) {
    // Complete the initialization of API client with this service
    _apiClient.setAuthService(this);
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        Endpoints.registerEndpoint,
        data: {'email': email, 'password': password, 'username': username},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.dio.post(
        Endpoints.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint('Token response: ${response.data}');
        await _tokenService.saveTokens(
          jwtToken: response.data['jwtToken'],
          jwtExpirationTimestamp: response.data['jwtExpirationDate'],
          refreshToken: response.data['refreshToken'],
          refreshExpirationTimestamp:
              response.data['refreshTokenExpirationDate'],
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> logout({bool notifyServer = true}) async {
    try {
      if (notifyServer) {
        try {
          final token = await _tokenService.getToken();
          if (token != null) {
            await _apiClient.dio.post(Endpoints.logoutEndpoint);
          }
        } catch (e) {
          print('Server logout failed: $e');
        }
      }

      await _tokenService.clearTokens();
      return true;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  // Improved isAuthenticated function
  Future<bool> isAuthenticated() async {
    // First check if access token is valid
    bool isTokenValid = await _tokenService.isTokenValid();

    if (isTokenValid) {
      return true;
    }

    // If access token is not valid, check if refresh token is valid
    bool isRefreshTokenValid = await _tokenService.isRefreshTokenValid();

    // If refresh token is valid, try to refresh the access token
    if (isRefreshTokenValid) {
      return await _tokenService.refreshToken();
    }

    // If neither token is valid, user is not authenticated
    return false;
  }

  Future<bool> handleSocialAuth(String provider) async {
    try {
      final authUrl =
          '${Endpoints.baseUrl}${Endpoints.oauth2Endpoint}$provider';

      // Launch the URL in the browser
      final Uri uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          webOnlyWindowName: '_self', // Prevents opening in new tab
          mode: LaunchMode.platformDefault,
        );
        return true;
      } else {
        debugPrint('Could not launch OAuth URL: $authUrl');
        return false;
      }
    } catch (e) {
      debugPrint('Social auth error: $e');
      return false;
    }
  }

  // Process the callback from social auth providers
  Future<bool> processSocialAuthCallback() async {
    try {
      Dio tempDio = Dio();
      // Call endpoint to exchange cookies for tokens
      final response = await tempDio.get(
        '${Endpoints.baseUrl}${Endpoints.tokensEndpoint}',
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Use tokenService to save the tokens
        await _tokenService.saveTokens(
          jwtToken: response.data['jwtToken'],
          jwtExpirationTimestamp: response.data['jwtExpirationDate'],
          refreshToken: response.data['refreshToken'],
          refreshExpirationTimestamp:
              response.data['refreshTokenExpirationDate'],
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Social auth callback error: $e');
      return false;
    }
  }
}
