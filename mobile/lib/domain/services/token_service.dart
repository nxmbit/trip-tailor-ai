import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:frontend/data/api/endpoints.dart';

class TokenService {
  final FlutterSecureStorage? _secureStorage;
  final Dio _dio;

  TokenService({Dio? dio})
      : _secureStorage = kIsWeb ? null : const FlutterSecureStorage(),
        _dio = dio ?? Dio();

  // Store tokens
  Future<void> saveTokens({
    required String jwtToken,
    required int jwtExpirationTimestamp,
    required String refreshToken,
    required int refreshExpirationTimestamp,
  }) async {
    final jwtExpirationDateStr =
        DateTime.fromMillisecondsSinceEpoch(
          jwtExpirationTimestamp,
        ).toIso8601String();

    final refreshExpirationDateStr =
        DateTime.fromMillisecondsSinceEpoch(
          refreshExpirationTimestamp,
        ).toIso8601String();

      // Use secure storage for mobile
      await _secureStorage!.write(key: 'jwtToken', value: jwtToken);
      await _secureStorage!.write(key: 'jwtTokenExpiration', value: jwtExpirationDateStr);
      await _secureStorage!.write(key: 'refreshToken', value: refreshToken);
      await _secureStorage!.write(key: 'refreshTokenExpiration', value: refreshExpirationDateStr);
  }

  // Get tokens with platform check
  Future<String?> getToken() async {
      return await _secureStorage!.read(key: 'jwtToken');
  }

  Future<String?> getTokenExpiration() async {
      return await _secureStorage!.read(key: 'jwtTokenExpiration');
  }

  Future<String?> getRefreshToken() async {
    if (kIsWeb) {

    } else {
      return await _secureStorage!.read(key: 'refreshToken');
    }
  }

  Future<String?> getRefreshTokenExpiration() async {
    if (kIsWeb) {

    } else {
      return await _secureStorage!.read(key: 'refreshTokenExpiration');
    }
  }

  // Clear tokens
  Future<void> clearTokens() async {
    if (kIsWeb) {

    } else {
      await _secureStorage!.deleteAll();
    }
  }

  // Token validation
  Future<bool> isTokenValid() async {
    final expiration = await getTokenExpiration();
    if (expiration == null) return false;

    try {
      final expirationDate = DateTime.parse(expiration);
      return expirationDate.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  Future<bool> isRefreshTokenValid() async {
    final expiration = await getRefreshTokenExpiration();
    if (expiration == null) return false;

    try {
      final expirationDate = DateTime.parse(expiration);
      return expirationDate.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  // Refresh token logic
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      final response = await _dio.post(
        Endpoints.baseUrl+Endpoints.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await saveTokens(
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
      print('Token refresh error: $e');
      return false;
    }
  }
}
