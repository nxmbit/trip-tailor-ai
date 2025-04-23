// This file contains the API constants used in the application.
class APIConstants {
  static const String baseUrl = 'http://localhost:8080/';
  static const String registerEndpoint = 'auth/register';
  static const String loginEndpoint = 'auth/login';
  static const String refreshTokenEndpoint = 'auth/refresh-token';
  static const String logoutEndpoint = 'auth/logout';
  static const String tokensEndpoint = 'auth/tokens';
  static const String testEndpoint = 'test';
  static const String oauth2Endpoint = 'oauth2/authorization/';
  static const String oauth2CallbackUrl =
      'http://localhost:3000/oauth2/redirect';
}
