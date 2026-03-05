import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Risk & Safety')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRiskHeader(),
            const SizedBox(height: 32),
            _buildSafetyRule(
              LucideIcons.shieldCheck,
              'Escrow Verification',
              'Never start work until the customer has deposited the advance into Neara Escrow.',
            ),
            _buildSafetyRule(
              LucideIcons.camera,
              'Photo Evidence',
              'For high-risk jobs, taking before and after photos is mandatory to protect your payment.',
            ),
            _buildSafetyRule(
              LucideIcons.mapPin,
              'Live Tracking',
              'Your location is shared with the Safety Hub during active jobs for your security.',
            ),
            const SizedBox(height: 48),
            Text('EMERGENCY CONTACTS', style: AppTextStyles.chipLabel),
            const SizedBox(height: 16),
            _buildContactTile(
              'Neara Safety Hub',
              '1800-NEARA-SAFE',
              LucideIcons.headphones,
            ),
            _buildContactTile('Local Police', '100', LucideIcons.shield),
            const SizedBox(height: 48),
            _buildAwarenessBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.midnightNavy, AppColors.warmCharcoal],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mutedSteel),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.shieldAlert,
            color: AppColors.saffronAmber,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text('Your Safety First', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Neara provides real-time risk assessment for every booking to ensure you serve with peace of mind.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyRule(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.liveTeal, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevatedGraphite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.saffronAmber, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                Text(
                  subtitle,
                  style: AppTextStyles.monoSmall.copyWith(
                    color: AppColors.saffronAmber,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.phoneIncoming,
            color: AppColors.liveTeal,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildAwarenessBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.saffronAmber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.saffronAmber.withOpacity(0.2)),
      ),
      child: Text(
        'Tip: Always communicate via the app to maintain a record for dispute resolution.',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.saffronAmber,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
