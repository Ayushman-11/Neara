import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:worker_app/features/dashboard/presentation/worker_dashboard_screen.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Verify your identity', style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Required to build trust with customers',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),
              _buildKycStep(
                'ID Proof (Aadhar/PAN)',
                'Upload a clear photo of your ID',
                LucideIcons.fileText,
                true,
              ),
              const SizedBox(height: 16),
              _buildKycStep(
                'Bank Account Details',
                'Where you will receive payments',
                LucideIcons.landmark,
                false,
              ),
              const SizedBox(height: 16),
              _buildKycStep(
                'Profile Verification Photo',
                'A selfie for verification',
                LucideIcons.userCheck,
                false,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.saffronGlow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.saffronAmber.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.info,
                      color: AppColors.saffronAmber,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verification typically takes 24-48 hours',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.saffronAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Mock submission
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkerDashboardScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Submit for Verification'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKycStep(
    String title,
    String subtitle,
    IconData icon,
    bool completed,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevatedGraphite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mutedSteel),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.midnightNavy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.saffronAmber, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Icon(
            completed ? LucideIcons.checkCircle2 : LucideIcons.upload,
            color: completed ? AppColors.safeGreen : AppColors.mutedFog,
            size: 20,
          ),
        ],
      ),
    );
  }
}
