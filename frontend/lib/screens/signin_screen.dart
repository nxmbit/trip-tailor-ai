import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/form_validators.dart';
import 'package:frontend/widgets/welcome_scaffold.dart';
import 'package:frontend/widgets/oauth_buttons.dart';
import 'package:frontend/constants/ui_constants.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        _navigateToHome();
      } else {
        _showErrorMessage('Invalid credentials. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
              child: _buildSignInCard(colorScheme, textTheme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInCard(ColorScheme colorScheme, TextTheme textTheme) {
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
              _buildEmailField(),
              const SizedBox(height: UIConstants.defaultSpacing),
              _buildPasswordField(),
              const SizedBox(height: UIConstants.defaultSpacing),
              _buildSignInButton(),
              const SizedBox(height: UIConstants.defaultSpacing),
              const Divider(),
              const SizedBox(height: UIConstants.defaultSpacing),
              _buildSocialAuthSection(textTheme, colorScheme),
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
      "Sign In",
      style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
      textAlign: TextAlign.center,
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
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSignIn(),
      validator: Validators.validatePassword,
    );
  }

  Widget _buildSignInButton() {
    return FilledButton(
      onPressed: _isLoading ? null : _handleSignIn,
      child:
          _isLoading
              ? const SizedBox(
                height: UIConstants.loadingIndicatorSize,
                width: UIConstants.loadingIndicatorSize,
                child: CircularProgressIndicator(),
              )
              : const Text('Sign In'),
    );
  }

  Widget _buildSocialAuthSection(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          'Or sign in with',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: UIConstants.defaultSpacing),
        SocialAuthButtons(),
      ],
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
