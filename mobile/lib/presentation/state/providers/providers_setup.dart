import 'package:frontend/data/repositories/nearby_places_repository.dart';
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
import '../../../data/repositories/trip_repository.dart';
import '../../../domain/services/nearby_places_service.dart';
import '../../../domain/services/notification_service.dart';
import '../../../domain/services/trip_service.dart';
import 'nearby_places_provider.dart';
import 'trip_plan_provider.dart';

/// Creates all providers for the app
List<SingleChildWidget> getProviders() {
  // Initialize language provider first to get initial language
  final languageProvider = LanguageProvider()..init();

  // Create services
  final tokenService = TokenService();
  final apiClient = ApiClient(tokenService: tokenService);
  final authService = AuthService(apiClient, tokenService);

  // Complete API client setup
  apiClient.setAuthService(authService);
  NotificationService.instance.setApiClient(apiClient);

  // Create repositories
  final userRepository = UserRepository(apiClient);
  final tripRepository = TripRepository(apiClient);
  final nearbyPlacesRepository = NearbyPlacesRepository(apiClient);

  // Create service layer
  final userService = UserService(userRepository, authService);
  final tripService = TripService(tripRepository);
  final nearbyPlacesService = NearbyPlacesService(nearbyPlacesRepository);
  // Return all providers
  return [
    // Core services
    Provider.value(value: tokenService),
    Provider.value(value: apiClient),
    Provider.value(value: authService),
    Provider.value(value: userService),
    Provider.value(value: tripService),
    Provider.value(value: nearbyPlacesService),

    // UI state providers
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider.value(value: languageProvider),
    ChangeNotifierProvider(
      create:
          (_) =>
          UserProvider(userService: userService, authService: authService),
    ),
    ChangeNotifierProvider(
      create: (_) => TripPlanProvider(service: tripService),
    ),
    ChangeNotifierProvider(
      create: (_) => NearbyPlacesProvider(service: nearbyPlacesService),
    ),
  ];
}
