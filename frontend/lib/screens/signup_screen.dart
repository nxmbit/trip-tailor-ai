import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/form_validators.dart';
import 'package:frontend/constants/ui_constants.dart';
import 'package:frontend/widgets/welcome_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacementNamed('/signin');
      } else {
        _showErrorMessage('Registration failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WelcomeScaffold(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: UIConstants.screenPadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: UIConstants.maxFormWidth,
              ),
              child: _buildSignUpCard(colorScheme, textTheme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      child: Padding(
        padding: UIConstants.cardPadding,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(textTheme, colorScheme),
              const SizedBox(height: UIConstants.defaultSpacing),
              _buildUsernameField(),
              const SizedBox(height: UIConstants.defaultSpacing),
              _buildEmailField(),
              const SizedBox(height: UIConstants.defaultSpacing),
              _buildPasswordField(),
              const SizedBox(height: UIConstants.defaultSpacing),
              _buildConfirmPasswordField(),
              const SizedBox(height: UIConstants.defaultSpacing),
              _buildSignInButton(),
              const SizedBox(height: UIConstants.defaultSpacing),
              const Divider(),
              const SizedBox(height: UIConstants.defaultSpacing),
              const _BackToWelcomeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      "Sign up",
      style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(Icons.person_outline),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: Validators.validateUsername,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: Validators.validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline),
      ),
      obscureText: true,
      textInputAction: TextInputAction.next,
      validator: Validators.validatePassword,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: const InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: Icon(Icons.lock_reset),
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSignUp(),
      validator:
          (value) => Validators.validateConfirmPassword(
            value,
            _passwordController.text,
          ),
    );
  }

  Widget _buildSignInButton() {
    return FilledButton(
      onPressed: _isLoading ? null : _handleSignUp,
      child:
          _isLoading
              ? const SizedBox(
                height: UIConstants.loadingIndicatorSize,
                width: UIConstants.loadingIndicatorSize,
                child: CircularProgressIndicator(),
              )
              : const Text('Sign Up'),
    );
  }
}

class _BackToWelcomeButton extends StatelessWidget {
  const _BackToWelcomeButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
      child: const Text('Back to Welcome'),
    );
  }
}
