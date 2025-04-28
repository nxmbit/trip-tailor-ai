import 'package:flutter/material.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';

class SignInState {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Services should be injected rather than created here
  final AuthService authService;
  final UserProvider userProvider;

  bool isLoading = false;
  String? errorMessage;

  // Dependency injection via constructor
  SignInState({required this.authService, required this.userProvider});

  // Clean up resources
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  // Updates the loading state
  void setLoading(bool loading) {
    isLoading = loading;
  }

  // Set error message
  void setError(String? message) {
    errorMessage = message;
  }

  // Sign in logic
  Future<bool> signIn() async {
    if (!formKey.currentState!.validate()) return false;

    setLoading(true);
    setError(null);

    try {
      final success = await authService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (success) {
        // After successful login, refresh user data
        await userProvider.refreshUser();
      } else {
        setError('Invalid email or password');
      }

      setLoading(false);
      return success;
    } catch (e) {
      debugPrint('Login error: $e');
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }
}
