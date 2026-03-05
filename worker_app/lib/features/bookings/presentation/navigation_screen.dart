import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';
import 'package:worker_app/features/bookings/presentation/service_progress_screen.dart';

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerState = ref.watch(workerProvider);
    final activeJob = workerState.activeJob!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8),
          child: CircleAvatar(
            backgroundColor: AppColors.warmCharcoal,
            child: IconButton(
              icon: const Icon(
                LucideIcons.chevronLeft,
                color: AppColors.brightIvory,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildMapPlaceholder(),
          _buildTopOverlay(context),
          _buildBottomOverlay(context, ref, activeJob),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: AppColors.elevatedGraphite,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.map,
              size: 64,
              color: AppColors.mutedFog.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Map Navigation Placeholder',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedFog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopOverlay(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 70, // Push down below AppBar
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warmCharcoal,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.navigation, color: AppColors.saffronAmber),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('800m • 4 mins', style: AppTextStyles.titleSmall),
                  Text(
                    'Turn right at Andheri Link Road',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(
    BuildContext context,
    WidgetRef ref,
    ActiveJob job,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.warmCharcoal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.elevatedGraphite,
                  child: const Icon(
                    LucideIcons.user,
                    color: AppColors.mutedFog,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.customerName, style: AppTextStyles.titleMedium),
                      Text(job.customerAddress, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.phone,
                    color: AppColors.liveTeal,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(workerProvider.notifier)
                          .updateJobStatus(JobStatus.arrived);
                      _showArrivalDialog(context, ref);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.saffronAmber,
                      foregroundColor: AppColors.midnightNavy,
                    ),
                    child: const Text('MARK ARRIVED'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showArrivalDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmCharcoal,
        title: Text('Start Service?', style: AppTextStyles.titleMedium),
        content: const Text(
          'Only start if you have physically arrived at the customer location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('WAIT'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(workerProvider.notifier)
                  .updateJobStatus(JobStatus.started);
              Navigator.pop(context);
              // Use push instead of pushReplacement
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServiceProgressScreen(),
                ),
              );
            },
            child: const Text('START SERVICE'),
          ),
        ],
      ),
    );
  }
}
