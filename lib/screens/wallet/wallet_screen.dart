import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  final List<Map<String, dynamic>> _transactions = const [
    {'label': 'Advance - Plumbing', 'amount': -200, 'date': '15 Mar'},
    {'label': 'Balance - Plumbing', 'amount': -200, 'date': '15 Mar'},
    {'label': 'Cashback Reward', 'amount': 15, 'date': '14 Mar'},
    {'label': 'Top Up', 'amount': 500, 'date': '10 Mar'},
    {'label': 'Advance - Electrician', 'amount': -150, 'date': '8 Mar'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Balance card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.saffronAmber.withAlpha(40),
                      AppColors.warmCharcoal,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.saffronAmber.withAlpha(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Neara Wallet', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    Text('₹ 865.00',
                        style: AppTextStyles.heroAmount),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Money'),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('Withdraw'),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
            // Transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions',
                      style: AppTextStyles.titleSmall),
                  TextButton(
                    onPressed: () {},
                    child: Text('View all',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.saffronAmber)),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _transactions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final t = _transactions[i];
                  final isCredit = (t['amount'] as int) > 0;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? AppColors.safeGreen.withAlpha(20)
                            : AppColors.elevatedGraphite,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCredit
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: isCredit
                            ? AppColors.safeGreen
                            : AppColors.mutedFog,
                        size: 16,
                      ),
                    ),
                    title: Text(t['label'] as String,
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.brightIvory)),
                    subtitle: Text(t['date'] as String,
                        style: AppTextStyles.micro),
                    trailing: Text(
                      '${isCredit ? '+' : ''}₹${(t['amount'] as int).abs()}',
                      style: AppTextStyles.monoSmall.copyWith(
                        color: isCredit
                            ? AppColors.safeGreen
                            : AppColors.brightIvory,
                      ),
                    ),
                  ).animate().fadeIn(delay: (250 + i * 50).ms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
