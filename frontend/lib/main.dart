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

//TODO:
// DODAC NEARBY PLACES DO HOME
// NA TABLECIE ROZwala SIE WELCOME SECTION Z HOME
//welcome screen fade in photos using transparent package (NA master branch)
