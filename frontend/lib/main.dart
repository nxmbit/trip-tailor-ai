import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/signin_screen.dart';
import 'package:frontend/screens/signup_screen.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/secure_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _authService = AuthService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trip Tailor',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const WelcomeScreen(),
        "/signin": (context) => const SignInScreen(),
        "/signup": (context) => const SignUpScreen(),
        "/home":
            (context) =>
                SecureRoute(authService: _authService, child: HomeScreen()),
      },
      initialRoute: "/",
    );
  }
}
