import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/status_chip.dart';

class ServiceInProgressScreen extends StatelessWidget {
  const ServiceInProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Service in Progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/booking-live'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.saffronAmber.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.handyman_rounded,
                    color: AppColors.saffronAmber, size: 40),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.06, 1.06),
                      duration: 800.ms),
              const SizedBox(height: 16),
              StatusChip(label: 'In Progress', type: StatusChipType.warning),
              const SizedBox(height: 12),
              Text('Ramesh is working…', style: AppTextStyles.titleMedium)
                  .animate()
                  .fadeIn(delay: 100.ms),
              Text('Water leakage repair — kitchen sink',
                      style: AppTextStyles.bodyMedium)
                  .animate()
                  .fadeIn(delay: 150.ms),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warmCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Column(
                  children: [
                    _InfoRow(icon: Icons.access_time_rounded,
                        label: 'Started at', value: '11:34 AM'),
                    const Divider(height: 20),
                    _InfoRow(icon: Icons.attach_money_rounded,
                        label: 'Advance Paid', value: '₹200'),
                    const Divider(height: 20),
                    _InfoRow(icon: Icons.account_balance_rounded,
                        label: 'Held in Escrow', value: '₹200'),
                  ],
                ),
              ).animate().fadeIn(delay: 250.ms),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/completed'),
                child: const Text('Service Completed (Mock)'),
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.saffronAmber, size: 18),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Text(value,
            style: AppTextStyles.monoSmall
                .copyWith(color: AppColors.brightIvory)),
      ],
    );
  }
}
