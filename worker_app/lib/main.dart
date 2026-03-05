import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:worker_app/features/auth/presentation/auth_state.dart';
import 'package:worker_app/features/auth/presentation/login_screen.dart';
import 'package:worker_app/features/dashboard/presentation/worker_dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: NearaWorkerApp()));
}

class NearaWorkerApp extends ConsumerWidget {
  const NearaWorkerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    Widget home;
    if (authState.status == AuthStatus.initial) {
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (authState.status == AuthStatus.authenticated) {
      home = const WorkerDashboardScreen();
    } else {
      home = const LoginScreen();
    }

    return MaterialApp(
      title: 'Neara Worker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: home,
    );
  }
}
