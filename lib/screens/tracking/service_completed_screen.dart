import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class ServiceCompletedScreen extends StatelessWidget {
  const ServiceCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Service Complete'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/in-progress'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.safeGreen.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.safeGreen),
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.safeGreen, size: 44),
              ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 500.ms,
                  curve: Curves.elasticOut),
              const SizedBox(height: 20),
              Text('Service Complete! 🎉',
                  style: AppTextStyles.titleMedium).animate().fadeIn(delay: 300.ms),
              Text('Ramesh has marked the job done.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),
              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warmCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Column(
                  children: [
                    _Row(label: 'Total Cost', value: '₹400'),
                    const Divider(height: 20),
                    _Row(label: 'Advance Paid', value: '₹200'),
                    const Divider(height: 20),
                    _Row(
                        label: 'Balance Due',
                        value: '₹200',
                        highlight: true),
                  ],
                ),
              ).animate().fadeIn(delay: 450.ms),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/final-payment'),
                child: const Text('Pay Balance ₹200'),
              ).animate().fadeIn(delay: 550.ms),
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
  final bool highlight;

  const _Row({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value,
            style: AppTextStyles.monoMedium.copyWith(
                color: highlight ? AppColors.saffronAmber : AppColors.brightIvory)),
      ],
    );
  }
}
