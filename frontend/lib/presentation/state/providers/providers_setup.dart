import 'package:flutter/foundation.dart';
import 'package:frontend/presentation/state/providers/trip_plan_info_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/api/api_client.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/domain/services/token_service.dart';
import 'package:frontend/domain/services/user_service.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:frontend/presentation/state/providers/theme_provider.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../core/utils/map_util.dart';
import '../../../data/repositories/generate_travel_plan_repository.dart';
import '../../../data/repositories/trip_plan_info_repository.dart';
import '../../../data/repositories/trip_repository.dart';
import '../../../domain/services/generate_travel_plan_service..dart';
import '../../../domain/services/trip_plan_info_service.dart';
import '../../../domain/services/trip_service.dart';
import 'generate_travel_provider.dart';
import 'trip_plan_provider.dart';

/// Creates all providers for the app
List<SingleChildWidget> getProviders() {
  // Initialize language provider first to get initial language
  final languageProvider = LanguageProvider()..init();

  // Initialize Google Maps if on web platform
  if (kIsWeb) {
    initializeGoogleMapsWeb(
      initialLanguage: languageProvider.locale.languageCode,
    );
  }

  // Create services
  final tokenService = TokenService();
  final apiClient = ApiClient(tokenService: tokenService);
  final authService = AuthService(apiClient, tokenService);

  // Complete API client setup
  apiClient.setAuthService(authService);

  // Create repositories
  final userRepository = UserRepository(apiClient);
  final generateTravelRepository = GenerateTravelPlanRepository(apiClient);
  final tripRepository = TripRepository(apiClient);
  final tripPlanInfoRepository = TripPlanInfoRepository(apiClient);

  // Create service layer
  final userService = UserService(userRepository, authService);
  final generateTravelPlanService = GenerateTravelPlanService(
    generateTravelRepository,
  );
  final tripService = TripService(tripRepository);
  final tripPlanInfoService = TripPlanInfoService(tripPlanInfoRepository);
  // Return all providers
  return [
    // Core services
    Provider.value(value: tokenService),
    Provider.value(value: apiClient),
    Provider.value(value: authService),
    Provider.value(value: userService),
    Provider.value(value: generateTravelPlanService),
    Provider.value(value: tripService),
    Provider.value(value: tripPlanInfoService),

    // UI state providers
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider.value(value: languageProvider),
    ChangeNotifierProvider(
      create:
          (_) =>
              UserProvider(userService: userService, authService: authService),
    ),
    ChangeNotifierProvider(
      create: (_) => GenerateTravelProvider(service: generateTravelPlanService),
    ),
    ChangeNotifierProvider(
      create: (_) => TripPlanProvider(service: tripService),
    ),
    ChangeNotifierProvider(
      create: (_) => TripPlanInfoProvider(service: tripPlanInfoService),
    ),
  ];
}
