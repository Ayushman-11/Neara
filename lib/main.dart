import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dusgfqvvjtpdnstjwjvv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1c2dmcXZ2anRwZG5zdGp3anZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2ODA1NzQsImV4cCI6MjA4ODI1NjU3NH0.gt_xy2IVAEOhei1hwgO8EW6wC9q5nmjb5xZAKM_Jimk',
  );

  // Must come AFTER Supabase.initialize
  setupLocator();

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
