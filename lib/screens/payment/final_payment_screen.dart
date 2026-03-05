import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class FinalPaymentScreen extends StatelessWidget {
  const FinalPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Final Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/completed'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warmCharcoal,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Summary', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 16),
                    _Row(label: 'Total Service Cost', value: '₹400'),
                    const Divider(height: 20),
                    _Row(label: 'Advance Paid', value: '₹200',
                        valueColor: AppColors.safeGreen),
                    const Divider(height: 20),
                    _Row(label: 'Balance Due',
                        value: '₹200', valueColor: AppColors.saffronAmber),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.safeGreen.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.safeGreen.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded,
                        color: AppColors.safeGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Once you pay, Ramesh receives the full amount from escrow.',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.safeGreen),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/review'),
                child: const Text('Pay ₹200 & Complete'),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value,
            style: AppTextStyles.monoMedium
                .copyWith(color: valueColor ?? AppColors.brightIvory)),
      ],
    );
  }
}
