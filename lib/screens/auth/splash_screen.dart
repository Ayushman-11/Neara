import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Stack(
        children: [
          // Radial saffron glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.saffronAmber.withAlpha(50),
                    AppColors.midnightNavy.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.saffronAmber,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.saffronGlow,
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.midnightNavy,
                    size: 40,
                  ),
                ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
                const SizedBox(height: 24),
                Text(
                  'Neara',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 36,
                    color: AppColors.brightIvory,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Help is always near.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softMoonlight),
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                const Spacer(flex: 2),
                // Loading bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      backgroundColor: AppColors.mutedSteel,
                      color: AppColors.saffronAmber,
                      minHeight: 3,
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                const SizedBox(height: 32),
                Text(
                  'Made for Bharat 🇮🇳',
                  style: AppTextStyles.micro.copyWith(color: AppColors.mutedFog),
                ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
