import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:8080/auth';
  final _storage = const FlutterSecureStorage();
  Timer? _logoutTimer;
  final _logoutController = StreamController<void>.broadcast();
  Stream<void> get onLogout => _logoutController.stream;

  void _setLogoutTimer(String expirationDateStr) {
    _logoutTimer?.cancel();
    final expirationDate = DateTime.parse(expirationDateStr);
    final timeToExpiry = expirationDate.difference(DateTime.now());

    print('Setting logout timer for: ${timeToExpiry.inSeconds} seconds');

    if (timeToExpiry.isNegative) {
      print('Token already expired, logging out immediately');
      logout();
      return;
    }

    _logoutTimer = Timer(timeToExpiry, () {
      print('Timer expired, logging out user');
      logout();
    });
  }

  void dispose() {
    _logoutTimer?.cancel();
    _logoutController.close();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final expirationTimestamp = data['expirationDate'] as int;

        // Convert timestamp to ISO8601 string for storage and timer
        final expirationDateStr =
            DateTime.fromMillisecondsSinceEpoch(
              expirationTimestamp,
            ).toIso8601String();

        // Store token and expiration date securely
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'tokenExpiration', value: expirationDateStr);

        final isVerified = await verifyTokenStorage();
        if (!isVerified) {
          print('Warning: Token storage verification failed');
          await logout();
          return false;
        }

        print('Login successful, setting up logout timer');
        _setLogoutTimer(expirationDateStr);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> signInWithProvider(String provider) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$provider'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Handle successful OAuth authentication
        return true;
      }
      return false;
    } catch (e) {
      print('Error during $provider authentication: $e');
      return false;
    }
  }

  // Helper methods for token management
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<String?> getTokenExpiration() async {
    return await _storage.read(key: 'tokenExpiration');
  }

  Future<void> logout() async {
    _logoutTimer?.cancel();
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'tokenExpiration');
    _logoutController.add(null);
    print('User logged out and token cleared');
  }

  Future<bool> isLoggedIn() async {
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

      if (token == null || expiration == null) {
        print('Token verification failed: token or expiration is null');
        return false;
      }

      // Verify expiration date format
      try {
        final expirationDate = DateTime.parse(expiration);
        print('Token verification successful:');
        print('- Token exists: ${token.isNotEmpty}');
        print('- Expiration date: $expirationDate');
        print('- Is expired: ${expirationDate.isBefore(DateTime.now())}');
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

  Future<bool> test() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/test'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
      );
      print('Test response status: ${response.statusCode}');
      print('Test response body: ${response.body}');
      await verifyTokenStorage();
      return response.statusCode == 200;
    } catch (e) {
      print('Test error: $e');
      return false;
    }
  }
}
