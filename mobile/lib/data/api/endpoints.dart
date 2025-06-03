import 'package:frontend/core/config/environment_config.dart';

// This file contains the API constants used in the application.
class Endpoints {
  static final String baseUrl = EnvironmentConfig.baseUrl;

  // Authentication endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String tokensEndpoint = '/auth/tokens';
  static const String testEndpoint = '/test';
  static const String oauth2Endpoint = '/oauth2/authorization/';
  static const String firebaseTokenEndpoint = '/auth/fcm-token';
  // User endpoints
  static const String currentUserEndpoint = '/api/users/profile';
  static const String imageChangeEndpoint = '/api/users/profile/image';
  static const String imageResetEndpoint = '/api/users/profile/image-reset';
  static const String usernameChangeEndpoint = '/api/users/profile/username';
  static const String passwordChangeEndpoint = '/api/users/profile/password';

  // Travel plan endpoints

  static const String tripPlanEndpoint = "/api/travel-plans/";
  static const String tripPlansEndpoint = "/api/travel-plans/plans";
  static const String generateTravelPlanEndpoint = "/api/travel-plans/generate";
  static const String nearbySummaryEndpoint = "/api/travel-plans/nearby-summary";
}