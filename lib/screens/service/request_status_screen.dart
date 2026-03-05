import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/status_chip.dart';

class RequestStatusScreen extends StatelessWidget {
  final Map<String, dynamic>? requestData;
  const RequestStatusScreen({super.key, this.requestData});

  @override
  Widget build(BuildContext context) {
    final workerName = requestData?['workerName'] as String? ?? 'the worker';
    final workerInitials = requestData?['workerInitials'] as String? ?? '?';
    final category = requestData?['category'] as String? ?? 'Service';
    final problem = requestData?['problem'] as String? ?? '';
    final urgency = requestData?['urgency'] as String? ?? 'normal';
    final address = requestData?['address'] as String? ?? '';

    Color urgencyColor;
    String urgencyLabel;
    switch (urgency) {
      case 'urgent':
        urgencyColor = AppColors.saffronAmber;
        urgencyLabel = 'Urgent';
        break;
      case 'emergency':
        urgencyColor = AppColors.emergencyCrimson;
        urgencyLabel = 'Emergency';
        break;
      default:
        urgencyColor = AppColors.liveTeal;
        urgencyLabel = 'Normal';
    }

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Request Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
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
                  .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 900.ms),
              const SizedBox(height: 20),
              Text('Waiting for ${workerName.split(' ').first}…',
                  style: AppTextStyles.titleMedium)
                  .animate()
                  .fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              Text(
                'Request sent. The worker will accept or send a proposal.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
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
              const SizedBox(height: 24),

              // Worker + request details card
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.saffronAmber.withAlpha(30),
                          child: Text(workerInitials,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.saffronAmber)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(workerName,
                                style: AppTextStyles.label
                                    .copyWith(color: AppColors.brightIvory)),
                            Text(category, style: AppTextStyles.bodySmall),
                          ],
                        ),
                        const Spacer(),
                        StatusChip(label: 'Pending', type: StatusChipType.warning),
                      ],
                    ),
                    if (problem.isNotEmpty) ...[
                      const Divider(height: 20),
                      Text('Problem', style: AppTextStyles.micro),
                      const SizedBox(height: 4),
                      Text(problem,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.softMoonlight)),
                      if (address.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text('Location', style: AppTextStyles.micro),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: AppColors.saffronAmber, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(address,
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.softMoonlight)),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Urgency: ', style: AppTextStyles.micro),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: urgencyColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(urgencyLabel,
                                style: AppTextStyles.micro
                                    .copyWith(color: urgencyColor)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),

              const Spacer(),
              OutlinedButton(
                onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                child: const Text('Back to Home'),
              ).animate().fadeIn(delay: 700.ms),
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
