import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';

class JobSummaryScreen extends ConsumerWidget {
  const JobSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerState = ref.watch(workerProvider);
    final activeJob = workerState.activeJob!;

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Job Summary'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildSuccessIcon(),
              const SizedBox(height: 24),
              Text('Job Completed!', style: AppTextStyles.titleLarge),
              Text(
                'Service Closed Successfully',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedFog,
                ),
              ),
              const SizedBox(height: 48),
              _buildEarningsCard(activeJob),
              const SizedBox(height: 32),
              _buildFeedbackSection(),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  ref.read(workerProvider.notifier).resetJob();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('BACK TO DASHBOARD'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.liveTeal,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        LucideIcons.check,
        color: AppColors.midnightNavy,
        size: 40,
      ),
    );
  }

  Widget _buildEarningsCard(ActiveJob job) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.warmCharcoal,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mutedSteel),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Service Fee', '₹${job.agreedAmount.toInt()}'),
          _buildSummaryRow('Platform Fee (0%)', '₹0'),
          const Divider(color: AppColors.mutedSteel, height: 32),
          _buildSummaryRow(
            'Total Earned',
            '₹${job.agreedAmount.toInt()}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.titleSmall
                : AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.titleLarge.copyWith(color: AppColors.liveTeal)
                : AppTextStyles.monoMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.elevatedGraphite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('CUSTOMER RATING', style: AppTextStyles.chipLabel),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => const Icon(
                LucideIcons.star,
                color: AppColors.saffronAmber,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"Excellent and fast service! Rajesh resolved the leak within 20 mins of arrival."',
            style: AppTextStyles.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
