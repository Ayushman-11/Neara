import 'package:flutter/material.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isValidPhone = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        _isValidPhone = _phoneController.text.length == 10;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'Neara Worker',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.saffronAmber,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Empowering Hyperlocal Service Providers',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 60),
              Text('Login with Phone', style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              Text(
                'We will send a 6-digit OTP to verify your number',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.monoMedium,
                decoration: const InputDecoration(
                  hintText: 'Enter Phone Number',
                  prefixIcon: Icon(
                    Icons.phone_iphone,
                    color: AppColors.mutedFog,
                  ),
                  prefixText: '+91 ',
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isValidPhone
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OtpScreen(phoneNumber: _phoneController.text),
                          ),
                        );
                      }
                    : null,
                child: const Text('Send OTP'),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'By continuing, you agree to Neara\'s Terms of Service',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
