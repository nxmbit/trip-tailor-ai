// import 'dart:js' as js;
// import 'package:flutter/foundation.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
//
// /// Initial setup with language parameter
// void initializeGoogleMapsWeb({String initialLanguage = 'en'}) {
//   if (kIsWeb) {
//     // Register the view factory - this should only happen ONCE
//     final mapApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
//
//     // This registers the Google Maps view factory
//     final registrar = webPluginRegistrar;
//     GoogleMapsPlugin.registerWith(registrar);
//
//     // Set the API key in the global JS context
//     js.context['googleMapsApiKey'] = mapApiKey;
//
//     // Set initial language
//     js.context['mapLanguage'] = initialLanguage;
//   }
// }
//
// /// Update just the language - can be called multiple times
// void updateGoogleMapsLanguage(String language) {
//   if (kIsWeb) {
//     // Just update the language variable
//     js.context['mapLanguage'] = language;
//   }
// }