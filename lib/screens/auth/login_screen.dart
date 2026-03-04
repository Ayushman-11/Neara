import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Logo row
              // Row(
              //   children: [
              //     Container(
              //       width: 36,
              //       height: 36,
              //       decoration: BoxDecoration(
              //         color: AppColors.saffronAmber,
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       child: const Icon(Icons.location_on_rounded,
              //           color: AppColors.midnightNavy, size: 20),
              //     ),
              //     const SizedBox(width: 10),
              //     Text('Neara', style: AppTextStyles.titleMedium),
              //   ],
              // ),
              const SizedBox(height: 48),
              // Phone illustration
              Center(
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.warmCharcoal,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.mutedSteel),
                  ),
                  // child: Stack(
                  //   alignment: Alignment.center,
                  //   children: [
                  //     Positioned(
                  //       left: 40,
                  //       child: _ServiceIcon(icon: Icons.plumbing_rounded, label: 'Plumber'),
                  //     ),
                  //     Positioned(
                  //       right: 40,
                  //       child: _ServiceIcon(icon: Icons.electrical_services_rounded, label: 'Electrician'),
                  //     ),
                  //     Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.all(18),
                  //           decoration: const BoxDecoration(
                  //             color: AppColors.saffronAmber,
                  //             shape: BoxShape.circle,
                  //           ),
                  //           child: const Icon(Icons.location_on_rounded,
                  //               color: AppColors.midnightNavy, size: 32),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Text('Find help near you', style: AppTextStyles.bodySmall),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
              const SizedBox(height: 40),
              Text('Enter your phone number',
                  style: AppTextStyles.titleLarge).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              Text(
                'We will send a 6-digit OTP to verify your identity.',
                style: AppTextStyles.bodyMedium,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 24),
              // Phone field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.elevatedGraphite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: AppColors.mutedSteel)),
                      ),
                      child: Row(
                        children: [
                          const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text('+91', style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.brightIvory)),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.mutedFog, size: 16),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brightIvory),
                        maxLength: 10,
                        decoration: const InputDecoration(
                          hintText: '98765 43210',
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),
              // CTA
              ElevatedButton(
                onPressed: () => context.go('/otp'),
                child: const Text('Send OTP'),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  style: AppTextStyles.micro,
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ServiceIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.elevatedGraphite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mutedSteel),
          ),
          child: Icon(icon, color: AppColors.saffronAmber, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.micro),
      ],
    );
  }
}
