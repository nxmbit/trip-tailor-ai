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

/// Creates all providers for the app
List<SingleChildWidget> getProviders() {
  // Create services
  final tokenService = TokenService();
  final apiClient = ApiClient(tokenService: tokenService);
  final authService = AuthService(apiClient, tokenService);

  // Complete API client setup
  apiClient.setAuthService(authService);

  // Create repositories
  final userRepository = UserRepository(apiClient);

  // Create service layer
  final userService = UserService(userRepository, authService);

  // Return all providers
  return [
    // Core services
    Provider.value(value: tokenService),
    Provider.value(value: apiClient),
    Provider.value(value: authService),
    Provider.value(value: userService),

    // UI state providers
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider.value(value: LanguageProvider()..init()),
    ChangeNotifierProvider(
      create: (_) => UserProvider(userService: userService),
    ),
  ];
}
