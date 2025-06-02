import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/presentation/state/providers/providers_setup.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(providers: getProviders(), child: MyApp()));
}

//TODO: ROZDZIELIC MOBILOWE
//COMMON WIDGETY< DODAC NEARBY PLACES DO HOME
//NAPRAWIC ZE PRZY ZMIANIE JEZYKA REFRESHUJE SIE KONTENT
//DODAĆ NA MOBILE I NA WEB EDYCJE PROFILU (USERNAME  I HASLO)
