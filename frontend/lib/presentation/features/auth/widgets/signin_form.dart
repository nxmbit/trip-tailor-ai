import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/utils/translation_helper.dart';
import '../state/signin_state.dart';
import 'oauth_buttons.dart';
import 'back_to_welcome_button.dart';

class SignInForm extends StatefulWidget {
  final SignInState state;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const SignInForm({
    super.key,
    required this.state,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  SignInState get _state => widget.state;

  Future<void> _handleSignIn() async {
    setState(() => _state.setLoading(true));
    //TODO change way of showing error message
    try {
      final success = await _state.signIn();

      if (!mounted) return;

      if (success) {
        _navigateToHome();
      } else {
        _showErrorMessage(tr(context, 'auth.signInError'));
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('${tr(context, 'auth.errorMessage')} ${e.toString()}');
    } finally {
      if (mounted) setState(() => _state.setLoading(false));
    }
  }

  void _navigateToHome() {
    context.go('/home');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: widget.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Form(
          key: _state.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 16.0),
              _buildEmailField(),
              const SizedBox(height: 16.0),
              _buildPasswordField(),
              const SizedBox(height: 16.0),
              _buildSignInButton(),
              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 16.0),
              _buildSocialAuthSection(),
              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 16.0),
              const BackToWelcomeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      tr(context, 'auth.signIn'),
      style: widget.textTheme.headlineMedium?.copyWith(
        color: widget.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _state.emailController,
      decoration: InputDecoration(
        labelText: tr(context, 'auth.email'),
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator:
          (value) => Validators.validateEmail(
            value,
            tr(context, 'auth.missingEmail'),
            tr(context, 'auth.invalidEmail'),
          ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _state.passwordController,
      decoration: InputDecoration(
        labelText: tr(context, 'auth.password'),
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSignIn(),
      validator:
          (value) => Validators.validatePassword(
            value,
            tr(context, 'auth.missingPassword'),
            tr(context, 'auth.invalidPassword'),
          ),
    );
  }

  Widget _buildSignInButton() {
    return FilledButton(
      onPressed: _state.isLoading ? null : _handleSignIn,
      child:
          _state.isLoading
              ? const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(),
              )
              : Text(tr(context, 'auth.signIn')),
    );
  }

  Widget _buildSocialAuthSection() {
    return Column(
      children: [
        Text(
          tr(context, 'auth.providerSignIn'),
          textAlign: TextAlign.center,
          style: widget.textTheme.headlineSmall?.copyWith(
            color: widget.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16.0),
        SocialAuthButtons(),
      ],
    );
  }
}
