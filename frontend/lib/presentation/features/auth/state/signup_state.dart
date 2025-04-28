import 'package:flutter/material.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';

class SignUpState {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Services should be injected rather than created here
  final AuthService authService;
  final UserProvider userProvider;

  bool isLoading = false;
  String? errorMessage;

  // Dependency injection via constructor
  SignUpState({required this.authService, required this.userProvider});

  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  void setLoading(bool loading) {
    isLoading = loading;
  }

  void setError(String? message) {
    errorMessage = message;
  }

  Future<bool> signUp() async {
    if (!formKey.currentState!.validate()) return false;

    setLoading(true);
    setError(null);

    try {
      final success = await authService.register(
        email: emailController.text,
        password: passwordController.text,
        username: usernameController.text,
      );

      if (success) {
        // Auto-login after registration
        final loginSuccess = await authService.login(
          email: emailController.text,
          password: passwordController.text,
        );

        if (loginSuccess) {
          // If login successful, refresh user data
          await userProvider.refreshUser();
        }

        return loginSuccess;
      } else {
        setError('Registration failed. Please try again.');
        setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }
}
