import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/utils/translation_helper.dart';
import '../state/signup_state.dart';
import 'back_to_welcome_button.dart';

class SignUpForm extends StatefulWidget {
  final SignUpState state;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const SignUpForm({
    super.key,
    required this.state,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  SignUpState get _state => widget.state;

  Future<void> _handleSignUp() async {
    setState(() => _state.setLoading(true));
    try {
      final success = await _state.signUp();

      if (!mounted) return;

      if (success) {
        context.go('/signin');
      } else {
        _showErrorMessage(tr(context, 'auth.signUpError'));
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('${tr(context, 'auth.errorMessage')} ${e.toString()}');
    } finally {
      if (mounted) setState(() => _state.setLoading(false));
    }
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
              _buildUsernameField(),
              const SizedBox(height: 16.0),
              _buildEmailField(),
              const SizedBox(height: 16.0),
              _buildPasswordField(),
              const SizedBox(height: 16.0),
              _buildConfirmPasswordField(),
              const SizedBox(height: 16.0),
              _buildSignUpButton(),
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
      tr(context, 'auth.signUp'),
      style: widget.textTheme.headlineMedium?.copyWith(
        color: widget.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _state.usernameController,
      decoration: InputDecoration(
        labelText: tr(context, 'auth.username'),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator:
          (value) => Validators.validateUsername(
            value,
            tr(context, 'auth.missingUsername'),
          ),
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
      textInputAction: TextInputAction.next,
      validator:
          (value) => Validators.validatePassword(
            value,
            tr(context, 'auth.missingPassword'),
            tr(context, 'auth.invalidPassword'),
          ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _state.confirmPasswordController,
      decoration: InputDecoration(
        labelText: tr(context, 'auth.confirmPassword'),
        prefixIcon: const Icon(Icons.lock_reset),
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSignUp(),
      validator:
          (value) => Validators.validateConfirmPassword(
            value,
            _state.passwordController.text,
            tr(context, 'auth.missingConfirmPassword'),
            tr(context, 'auth.invalidConfirmPassword'),
          ),
    );
  }

  Widget _buildSignUpButton() {
    return FilledButton(
      onPressed: _state.isLoading ? null : _handleSignUp,
      child:
          _state.isLoading
              ? const SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(),
              )
              : Text(tr(context, 'auth.signUp')),
    );
  }
}
