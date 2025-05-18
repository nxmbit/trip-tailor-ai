import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/presentation/state/providers/providers_setup.dart';
import 'package:provider/provider.dart';

import 'core/utils/map_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (kIsWeb) {
    initializeGoogleMapsWeb();
  }
  runApp(MultiProvider(providers: getProviders(), child: MyApp()));
}
