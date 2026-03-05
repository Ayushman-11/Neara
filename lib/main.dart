import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env in background to avoid blocking the splash screen / main UI thread
  unawaited(dotenv.load(fileName: ".env").catchError((e) {
    debugPrint("Warning: Could not load .env file: $e");
  }));

  runApp(const NearaApp());
}

class NearaApp extends StatelessWidget {
  const NearaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Neara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
