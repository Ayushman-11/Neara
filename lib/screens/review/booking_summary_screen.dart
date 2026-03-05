import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/status_chip.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Booking Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.safeGreen.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: AppColors.safeGreen, size: 36),
                    ).animate().scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 400.ms,
                        curve: Curves.elasticOut),
                    const SizedBox(height: 12),
                    Text('Booking Complete', style: AppTextStyles.titleMedium)
                        .animate()
                        .fadeIn(delay: 200.ms),
                    Text('SRQ-20240315-0042',
                        style: AppTextStyles.monoSmall
                            .copyWith(color: AppColors.saffronAmber))
                        .animate()
                        .fadeIn(delay: 250.ms),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warmCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Summary', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 16),
                    _Row(label: 'Service', value: 'Plumbing'),
                    const Divider(height: 16),
                    _Row(label: 'Worker', value: 'Ramesh Sharma'),
                    const Divider(height: 16),
                    _Row(label: 'Date', value: '15 Mar 2024'),
                    const Divider(height: 16),
                    _Row(label: 'Duration', value: '1h 25m'),
                    const Divider(height: 16),
                    _Row(
                        label: 'Total Paid',
                        value: '₹400',
                        valueColor: AppColors.saffronAmber),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status', style: AppTextStyles.bodySmall),
                        StatusChip(
                            label: 'Completed', type: StatusChipType.success),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Receipt'),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.replay_rounded, size: 16),
                      label: const Text('Rebook'),
                      onPressed: () {},
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home'),
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 24),
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
        Text(label, style: AppTextStyles.bodySmall),
        Text(value,
            style: AppTextStyles.label.copyWith(
                color: valueColor ?? AppColors.brightIvory)),
      ],
    );
  }
}
