import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/status_chip.dart';

class RequestStatusScreen extends StatelessWidget {
  const RequestStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Request Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/request'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Animated waiting icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.warningAmber.withAlpha(80)),
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    color: AppColors.warningAmber, size: 40),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1),
                      duration: 900.ms),
              const SizedBox(height: 20),
              Text('Waiting for Ramesh…',
                  style: AppTextStyles.titleMedium).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              Text('Request sent. The worker will accept or send a proposal.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),
              // Status timeline
              _StatusStep(
                  icon: Icons.send_rounded,
                  label: 'Request sent',
                  isComplete: true),
              _StatusStep(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Worker accepted',
                  isComplete: false),
              _StatusStep(
                  icon: Icons.description_rounded,
                  label: 'Proposal received',
                  isComplete: false),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warmCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.elevatedGraphite,
                      child: Text('RS',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.saffronAmber)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ramesh Sharma',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.brightIvory)),
                        Text('Plumber · 4.7 ⭐',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const Spacer(),
                    StatusChip(label: 'Pending', type: StatusChipType.warning),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/proposal'),
                child: const Text('View Proposal (Mock)'),
              ).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Cancel Request'),
              ).animate().fadeIn(delay: 750.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isComplete;

  const _StatusStep(
      {required this.icon, required this.label, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.safeGreen.withAlpha(20)
                  : AppColors.elevatedGraphite,
              shape: BoxShape.circle,
              border: Border.all(
                color: isComplete ? AppColors.safeGreen : AppColors.mutedSteel,
              ),
            ),
            child: Icon(icon,
                color: isComplete ? AppColors.safeGreen : AppColors.mutedFog,
                size: 18),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: AppTextStyles.label.copyWith(
                color: isComplete ? AppColors.brightIvory : AppColors.mutedFog,
              )),
          const Spacer(),
          if (isComplete)
            const Icon(Icons.check_rounded,
                color: AppColors.safeGreen, size: 16),
        ],
      ),
    );
  }
}
