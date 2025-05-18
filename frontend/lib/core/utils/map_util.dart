import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Initial setup - only called once in main.dart
void initializeGoogleMapsWeb() {
  if (kIsWeb) {
    // Register the view factory - this should only happen ONCE
    final mapApiKey = dotenv.env['GOOGLE_PLACES_KEY'] ?? '';

    // This registers the Google Maps view factory
    final registrar = webPluginRegistrar;
    GoogleMapsPlugin.registerWith(registrar);

    // Set the API key in the global JS context
    js.context['googleMapsApiKey'] = mapApiKey;

    // Default language
    js.context['mapLanguage'] = 'en';
  }
}

/// Update just the language - can be called multiple times
void updateGoogleMapsLanguage(String language) {
  if (kIsWeb) {
    // Just update the language variable
    js.context['mapLanguage'] = language;
  }
}
