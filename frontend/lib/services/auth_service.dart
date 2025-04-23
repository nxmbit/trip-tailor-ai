import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:frontend/interceptors/auth_interceptor.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _dio = Dio(
    BaseOptions(
      baseUrl: APIConstants.baseUrl,
      validateStatus: (status) {
        return status! < 201;
      },
    ),
  );
  AuthService() {
    _dio.interceptors.clear(); // Clear any existing interceptors
    _dio.interceptors.addAll([AuthInterceptor(this, _dio), LogInterceptor()]);
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _dio.post(
        APIConstants.registerEndpoint,
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
      final response = await _dio.post(
        APIConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final jwtToken = data['jwtToken'];
        final jwtExpirationTimestamp = data['jwtExpirationDate'] as int;
        final refreshToken = data['refreshToken'];
        final refreshExpirationTimestamp =
            data['refreshTokenExpirationDate'] as int;

        final jwtExpirationDateStr =
            DateTime.fromMillisecondsSinceEpoch(
              jwtExpirationTimestamp,
            ).toIso8601String();

        final refreshExpirationDateStr =
            DateTime.fromMillisecondsSinceEpoch(
              refreshExpirationTimestamp,
            ).toIso8601String();

        await _storage.write(key: 'jwtToken', value: jwtToken);
        await _storage.write(
          key: 'jwtTokenExpiration',
          value: jwtExpirationDateStr,
        );
        await _storage.write(key: 'refreshToken', value: refreshToken);
        await _storage.write(
          key: 'refreshTokenExpiration',
          value: refreshExpirationDateStr,
        );

        final isVerified = await verifyTokenStorage();
        if (!isVerified) {
          print('Warning: Token storage verification failed');
          await logout(notifyServer: false);
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout({bool notifyServer = true}) async {
    try {
      if (notifyServer) {
        try {
          await _dio.post(APIConstants.logoutEndpoint);
        } catch (e) {
          print('Server logout failed, proceeding with client logout: $e');
        }
      }

      // Client-side cleanup
      await _storage.deleteAll();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<bool> test() async {
    try {
      final response = await _dio.get(APIConstants.testEndpoint);
      if (response.statusCode == 200) {
        print('Test successful: ${response.data}');
        return true;
      } else {
        print('Test failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Test error: $e');
      return false;
    }
  }

  //TOKEN SECTION

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    final expiration = await getTokenExpiration();

    if (token == null || expiration == null) {
      return false;
    }

    final expirationDate = DateTime.parse(expiration);
    return expirationDate.isAfter(DateTime.now());
  }

  Future<bool> verifyTokenStorage() async {
    try {
      final token = await getToken();
      final expiration = await getTokenExpiration();
      final refreshToken = await getRefreshToken();
      final refreshExpiration = await getRefreshTokenExpiration();

      if (token == null ||
          expiration == null ||
          refreshToken == null ||
          refreshExpiration == null) {
        print(
          'Token verification failed: token, refresh token, or expiration is null',
        );
        return false;
      }

      try {
        final expirationDate = DateTime.parse(expiration);
        final refreshExpirationDate = DateTime.parse(refreshExpiration);

        print('Token verification successful:');
        print('- Token exists: ${token.isNotEmpty}');
        print('- Expiration date: $expirationDate');
        print('- Is expired: ${expirationDate.isBefore(DateTime.now())}');
        print('- Refresh token exists: ${refreshToken.isNotEmpty}');
        print('- Refresh expiration date: $refreshExpirationDate');
        print(
          '- Is refresh token expired: ${refreshExpirationDate.isBefore(DateTime.now())}',
        );

        return true;
      } catch (e) {
        print('Token verification failed: invalid expiration date format');
        return false;
      }
    } catch (e) {
      print('Token verification failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> refreshTokens() async {
    try {
      final refreshToken = await getRefreshToken();
      final refreshExpiration = await getRefreshTokenExpiration();

      if (refreshToken == null || refreshExpiration == null) {
        print('No refresh token or expiration available');
        return false;
      }

      final refreshExpirationDate = DateTime.parse(refreshExpiration);
      if (refreshExpirationDate.isBefore(DateTime.now())) {
        print('Refresh token has expired');
        return false;
      }

      final response = await _dio.post(
        APIConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await _saveTokens(response.data);
        return true;
      }

      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final jwtToken = data['jwtToken'];
    final jwtExpirationTimestamp = data['jwtExpirationDate'] as int;
    final refreshToken = data['refreshToken'];
    final refreshExpirationTimestamp =
        data['refreshTokenExpirationDate'] as int;

    final jwtExpirationDateStr =
        DateTime.fromMillisecondsSinceEpoch(
          jwtExpirationTimestamp,
        ).toIso8601String();

    final refreshExpirationDateStr =
        DateTime.fromMillisecondsSinceEpoch(
          refreshExpirationTimestamp,
        ).toIso8601String();

    await _storage.write(key: 'jwtToken', value: jwtToken);
    await _storage.write(
      key: 'jwtTokenExpiration',
      value: jwtExpirationDateStr,
    );
    await _storage.write(key: 'refreshToken', value: refreshToken);
    await _storage.write(
      key: 'refreshTokenExpiration',
      value: refreshExpirationDateStr,
    );
  }

  // Helper methods for token management
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwtToken');
  }

  Future<String?> getTokenExpiration() async {
    return await _storage.read(key: 'jwtTokenExpiration');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  Future<String?> getRefreshTokenExpiration() async {
    return await _storage.read(key: 'refreshTokenExpiration');
  }
}
