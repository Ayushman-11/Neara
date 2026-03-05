import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';
import 'package:worker_app/features/bookings/presentation/navigation_screen.dart';

class EscrowSigningScreen extends StatefulWidget {
  const EscrowSigningScreen({super.key});

  @override
  State<EscrowSigningScreen> createState() => _EscrowSigningScreenState();
}

class _EscrowSigningScreenState extends State<EscrowSigningScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Agreement')),
      body: Consumer(
        builder: (context, ref, child) {
          final workerState = ref.watch(workerProvider);
          final activeJob = workerState.activeJob!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(activeJob),
                      const SizedBox(height: 32),
                      _buildAgreementSection(),
                      const SizedBox(height: 32),
                      _buildSecurityBox(),
                    ],
                  ),
                ),
              ),
              _buildActionArea(context, ref),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ActiveJob job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.liveTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.liveTeal.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.checkCircle2,
                color: AppColors.liveTeal,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'ADVANCE SECURED',
                style: AppTextStyles.chipLabel.copyWith(
                  color: AppColors.liveTeal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Service Work Order', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Please review the terms and sign below to enable live tracking and start the job.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedFog),
        ),
      ],
    );
  }

  Widget _buildAgreementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.elevatedGraphite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mutedSteel),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgreementRow(LucideIcons.user, 'Customer', 'Amit Kumar'),
          _buildAgreementRow(
            LucideIcons.mapPin,
            'Location',
            'Andheri West, Mumbai',
          ),
          _buildAgreementRow(
            LucideIcons.wrench,
            'Service',
            'Emergency Plumbing',
          ),
          const Divider(color: AppColors.mutedSteel, height: 32),
          _buildAgreementRow(
            LucideIcons.indianRupee,
            'Total Amount',
            '₹850.00',
            isBold: true,
          ),
          _buildAgreementRow(
            LucideIcons.landmark,
            'Advance (Escrowed)',
            '₹170.00',
          ),
          _buildAgreementRow(LucideIcons.coins, 'Balance Due', '₹680.00'),
        ],
      ),
    );
  }

  Widget _buildAgreementRow(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.saffronAmber, size: 16),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodySmall),
          const Spacer(),
          Text(
            value,
            style: isBold ? AppTextStyles.titleSmall : AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.midnightNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mutedSteel),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.lock, color: AppColors.liveTeal, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Your payment is protected by Neara Escrow. Funds are released only after you complete the service and the customer confirms.',
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.warmCharcoal,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Row(
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (val) => setState(() => _agreed = val!),
                  activeColor: AppColors.saffronAmber,
                ),
                Expanded(
                  child: Text(
                    'I agree to perform the service as according to Neara safety standards.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _agreed ? () => _handleSign(context, ref) : null,
            child: const Text('SIGN & START JOB'),
          ),
        ],
      ),
    );
  }

  void _handleSign(BuildContext context, WidgetRef ref) {
    ref.read(workerProvider.notifier).updateJobStatus(JobStatus.coming);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NavigationScreen()),
    );
  }
}
