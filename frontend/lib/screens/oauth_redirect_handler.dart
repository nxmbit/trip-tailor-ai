import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';

class OAuthRedirectHandler extends StatefulWidget {
  const OAuthRedirectHandler({Key? key}) : super(key: key);

  @override
  State<OAuthRedirectHandler> createState() => _OAuthRedirectHandlerState();
}

class _OAuthRedirectHandlerState extends State<OAuthRedirectHandler> {
  final AuthService _authService = AuthService();
  bool _isProcessing = true;
  String _message = "Processing authentication...";

  @override
  void initState() {
    super.initState();
    _processOAuthRedirect();
  }

  Future<void> _processOAuthRedirect() async {
    try {
      final success = await _authService.processSocialAuthCallback();
      
      if (success) {
        setState(() {
          _message = "Authentication successful! Redirecting...";
        });
        
        Future.delayed(const Duration(seconds: 1), () {
          print("Redirecting to home screen");
          Navigator.of(context).pushReplacementNamed('/home');
          
        });
      } else {
        setState(() {
          _isProcessing = false;
          _message = "Authentication failed. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _message = "Error during authentication: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing)
              const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(_message),
            if (!_isProcessing)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/signin'),
                child: const Text('Return to Login'),
              )
          ],
        ),
      ),
    );
  }
}