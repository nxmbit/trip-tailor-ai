import 'package:flutter/material.dart';
import '../widgets/welcome_content.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: WelcomeContent()));
  }
}
