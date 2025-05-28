import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import '../state/signup_state.dart';
import '../widgets/signup_form.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late SignUpState _signUpState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get services directly from the provider
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Create the sign-up state with injected dependencies
    _signUpState = SignUpState(
      authService: authService,
      userProvider: userProvider,
    );
  }

  @override
  void dispose() {
    _signUpState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400.0),
                child: SignUpForm(
                  state: _signUpState,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
