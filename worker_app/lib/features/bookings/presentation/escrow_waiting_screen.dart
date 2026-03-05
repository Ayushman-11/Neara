import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';
import 'package:worker_app/features/bookings/presentation/escrow_signing_screen.dart';

class EscrowWaitingScreen extends ConsumerWidget {
  const EscrowWaitingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerState = ref.watch(workerProvider);
    final activeJob = workerState.activeJob!;
    final advanceAmount = activeJob.agreedAmount * activeJob.advancePercentage;

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Escrow Payment'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildAnimatedLogo(),
              const SizedBox(height: 40),
              Text(
                'Securing Advance Payment...',
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Waiting for ${activeJob.customerName} to deposit ₹${advanceAmount.toInt()} into Neara Secure Escrow.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedFog,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildStatusCard(activeJob, advanceAmount),
              const Spacer(),
              Text(
                'Work cannot start until escrow is funded.',
                style: AppTextStyles.monoSmall.copyWith(
                  color: AppColors.warningAmber,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Simulate payment received
                  ref
                      .read(workerProvider.notifier)
                      .updateJobStatus(JobStatus.escrowSigning);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EscrowSigningScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmCharcoal,
                  foregroundColor: AppColors.saffronAmber,
                ),
                child: const Text('SIMULATE PAYMENT RECEIVED'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.saffronAmber.withOpacity(0.3),
            ),
          ),
        ),
        const Icon(
          LucideIcons.shieldCheck,
          size: 64,
          color: AppColors.saffronAmber,
        ),
      ],
    );
  }

  Widget _buildStatusCard(ActiveJob job, double amount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.elevatedGraphite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mutedSteel),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Booking ID', style: AppTextStyles.bodySmall),
              Text(
                '#${job.id.padLeft(6, '0')}',
                style: AppTextStyles.monoSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.mutedSteel),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Agreed Total', style: AppTextStyles.bodyLarge),
              Text(
                '₹${job.agreedAmount.toInt()}',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Advance Required', style: AppTextStyles.bodySmall),
              Text(
                '₹${amount.toInt()}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.saffronAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
