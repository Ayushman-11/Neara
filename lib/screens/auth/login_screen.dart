import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/di/locator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final fullPhone = '+91$phone';
      await locator<AuthService>().signInWithPhone(fullPhone);
      if (mounted) context.go('/otp', extra: fullPhone);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not send OTP. Please try again.'),
            backgroundColor: AppColors.emergencyCrimson,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 52),

              // Brand header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.saffronAmber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on_rounded,
                        color: AppColors.midnightNavy, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text('Neara',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.brightIvory)),
                ],
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 40),

              Text('Welcome back 👋',
                  style: AppTextStyles.titleLarge).animate().fadeIn(delay: 80.ms),
              const SizedBox(height: 6),
              Text('Find trusted workers near you in seconds.',
                  style: AppTextStyles.bodyMedium).animate().fadeIn(delay: 140.ms),
              const SizedBox(height: 36),

              // Phone field label
              Text('Mobile Number', style: AppTextStyles.label)
                  .animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 10),

              // Phone input row
              Container(
                decoration: BoxDecoration(
                  color: AppColors.elevatedGraphite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Row(
                  children: [
                    // Country code pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(color: AppColors.mutedSteel)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇮🇳',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text('+91',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.brightIvory)),
                        ],
                      ),
                    ),
                    // Number input
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _sendOtp(),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.brightIvory),
                        decoration: const InputDecoration(
                          hintText: '98765 43210',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 260.ms),
              const SizedBox(height: 28),

              // CTA
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.midnightNavy),
                      )
                    : const Text('Get OTP →'),
              ).animate().fadeIn(delay: 320.ms),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  'By continuing, you agree to our Terms & Privacy Policy.',
                  style: AppTextStyles.micro,
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 380.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
