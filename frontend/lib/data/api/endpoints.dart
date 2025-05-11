import 'package:frontend/core/config/environment_config.dart';

// This file contains the API constants used in the application.
class APIConstants {
  static final String baseUrl = EnvironmentConfig.baseUrl;

  // Authentication endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String tokensEndpoint = '/auth/tokens';
  static const String testEndpoint = '/test';
  static const String oauth2Endpoint = '/oauth2/authorization/';

  // User endpoints
  static const String currentUserEndpoint = '/api/users/profile';
}