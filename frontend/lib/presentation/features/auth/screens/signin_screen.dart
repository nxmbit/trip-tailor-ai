import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import '../state/signin_state.dart';
import '../widgets/signin_form.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late SignInState _signInState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get services directly from the provider
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Create the sign-in state with injected dependencies
    _signInState = SignInState(
      authService: authService,
      userProvider: userProvider,
    );
  }

  @override
  void dispose() {
    _signInState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400.0),
                child: SignInForm(
                  state: _signInState,
                  colorScheme: colorScheme,
                  textTheme: Theme.of(context).textTheme,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
