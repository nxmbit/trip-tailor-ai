import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:frontend/data/api/endpoints.dart';

class TokenService {
  final _storage = const FlutterSecureStorage();
  final Dio _dio; // Add Dio for API requests

  TokenService({Dio? dio}) : _dio = dio ?? Dio();

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

  // Get tokens
  Future<String?> getToken() async => await _storage.read(key: 'jwtToken');
  Future<String?> getTokenExpiration() async =>
      await _storage.read(key: 'jwtTokenExpiration');
  Future<String?> getRefreshToken() async =>
      await _storage.read(key: 'refreshToken');
  Future<String?> getRefreshTokenExpiration() async =>
      await _storage.read(key: 'refreshTokenExpiration');

  // Clear tokens
  Future<void> clearTokens() async => await _storage.deleteAll();

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

  // Move refresh token logic here
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      final response = await _dio.post(
        APIConstants.refreshTokenEndpoint,
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
