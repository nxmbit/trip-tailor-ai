import 'package:flutter/material.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/presentation/state/providers/providers_setup.dart';
import 'package:provider/provider.dart';

void main() {
  // This ensures Flutter bindings are initialized before using platform channels
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-initialize the language provider
  // final languageProvider = LanguageProvider();
  // languageProvider.init();

  runApp(
    MultiProvider(
      providers: getProviders(),
      // providers: [
      //   ChangeNotifierProvider(create: (_) => ThemeProvider()),
      //   ChangeNotifierProvider.value(value: languageProvider),
      // ],
      child: MyApp(),
    ),
  );
}
