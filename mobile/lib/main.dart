import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/presentation/state/providers/providers_setup.dart';
import 'package:provider/provider.dart';
import 'domain/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(providers: getProviders(), child: MyApp()));
}
