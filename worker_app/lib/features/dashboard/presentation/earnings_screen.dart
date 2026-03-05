import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerState = ref.watch(workerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWalletCard(context, ref, workerState.walletBalance),
          const SizedBox(height: 32),
          _buildSectionHeader('WEEKLY ANALYTICS'),
          const SizedBox(height: 16),
          _buildWeeklyChart(),
          const SizedBox(height: 32),
          _buildSectionHeader('RECENT TRANSACTIONS'),
          const SizedBox(height: 16),
          _buildTransactionTile(
            'Job Payment: Emergency Plumbing',
            '+ ₹850.00',
            'Today, 4:15 PM',
            LucideIcons.arrowDownLeft,
            AppColors.liveTeal,
          ),
          _buildTransactionTile(
            'Payout to HDFC Bank',
            '- ₹5,000.00',
            'Yesterday, 11:30 AM',
            LucideIcons.externalLink,
            AppColors.mutedFog,
          ),
          _buildTransactionTile(
            'Job Payment: Fan Installation',
            '+ ₹600.00',
            '2 Mar, 6:45 PM',
            LucideIcons.arrowDownLeft,
            AppColors.liveTeal,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, WidgetRef ref, double balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.saffronAmber,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffronAmber.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AVAILABLE BALANCE',
                style: AppTextStyles.chipLabel.copyWith(
                  color: AppColors.midnightNavy.withOpacity(0.6),
                ),
              ),
              const Icon(
                LucideIcons.wallet,
                color: AppColors.midnightNavy,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${balance.toStringAsFixed(2)}',
            style: AppTextStyles.heroAmount.copyWith(
              color: AppColors.midnightNavy,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleWithdrawal(context, ref, balance),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.midnightNavy,
                    foregroundColor: AppColors.saffronAmber,
                    elevation: 0,
                  ),
                  child: const Text('Withdraw to Bank'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.chipLabel.copyWith(color: AppColors.mutedFog),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmCharcoal,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mutedSteel),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net: ₹4,250', style: AppTextStyles.titleSmall),
              Text('Last 7 Days', style: AppTextStyles.bodySmall),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('M', 40),
              _buildChartBar('T', 70),
              _buildChartBar('W', 50),
              _buildChartBar('T', 90, isHighlight: true),
              _buildChartBar('F', 30),
              _buildChartBar('S', 60),
              _buildChartBar('S', 45),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(
    String day,
    double heightFactor, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Container(
          width: 12,
          height: heightFactor,
          decoration: BoxDecoration(
            color: isHighlight
                ? AppColors.saffronAmber
                : AppColors.elevatedGraphite,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: AppTextStyles.monoSmall.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildTransactionTile(
    String title,
    String amount,
    String date,
    IconData icon,
    Color amountColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevatedGraphite.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.midnightNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: amountColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.brightIvory,
                    fontSize: 13,
                  ),
                ),
                Text(date, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.monoMedium.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }

  void _handleWithdrawal(BuildContext context, WidgetRef ref, double balance) {
    if (balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance for withdrawal')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmCharcoal,
        title: Text('Withdraw Funds', style: AppTextStyles.titleMedium),
        content: Text(
          'Withdraw ₹${balance.toStringAsFixed(2)} to your linked HDFC Bank account ending in 4242?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(workerProvider.notifier).withdrawFunds(balance);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Payout initiated! Expect funds in 24-48 hours.',
                  ),
                  backgroundColor: AppColors.safeGreen,
                ),
              );
            },
            child: const Text('WITHDRAW'),
          ),
        ],
      ),
    );
  }
}
