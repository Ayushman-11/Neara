import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/mock/mock_data.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0;

  @override
  Widget build(BuildContext context) {
    final p = MockData.mockProposal;

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Secure Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/proposal'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.lock_rounded, color: AppColors.liveTeal, size: 20),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warmCharcoal,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(
                        label: 'Total Service Cost',
                        value: '₹${p.estimatedRepair.toInt()}',
                        valueStyle: AppTextStyles.monoMedium
                            .copyWith(color: AppColors.brightIvory)),
                    const Divider(height: 20),
                    _SummaryRow(
                        label: 'Advance (${p.advancePercent}%)',
                        value: '₹${p.advanceAmount.toInt()}',
                        valueStyle: AppTextStyles.monoLarge),
                    const Divider(height: 20),
                    _SummaryRow(
                        label: 'Balance after service',
                        value: '₹${p.balanceAmount.toInt()}',
                        valueStyle: AppTextStyles.monoSmall
                            .copyWith(color: AppColors.mutedFog)),
                    const SizedBox(height: 16),
                    // Escrow notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.liveTeal.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.liveTeal.withAlpha(60)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_rounded,
                              color: AppColors.liveTeal, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your payment is held securely in escrow until you confirm completion.',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.liveTeal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 24),
              Text('Payment Method', style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              // Payment methods
              ...[
                _PaymentMethod(
                    index: 0, icon: Icons.account_balance_wallet_rounded, label: 'UPI'),
                _PaymentMethod(
                    index: 1, icon: Icons.credit_card_rounded, label: 'Credit / Debit Card'),
                _PaymentMethod(
                    index: 2, icon: Icons.corporate_fare_rounded, label: 'Net Banking'),
              ].map((m) => GestureDetector(
                    onTap: () => setState(() => _selectedMethod = m.index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _selectedMethod == m.index
                            ? AppColors.saffronAmber.withAlpha(15)
                            : AppColors.warmCharcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMethod == m.index
                              ? AppColors.saffronAmber
                              : AppColors.mutedSteel,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(m.icon,
                              color: _selectedMethod == m.index
                                  ? AppColors.saffronAmber
                                  : AppColors.mutedFog,
                              size: 22),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Text(m.label,
                                  style: AppTextStyles.label.copyWith(
                                      color: _selectedMethod == m.index
                                          ? AppColors.brightIvory
                                          : AppColors.softMoonlight))),
                          if (_selectedMethod == m.index)
                            const Icon(Icons.radio_button_checked_rounded,
                                color: AppColors.saffronAmber, size: 18)
                          else
                            const Icon(Icons.radio_button_unchecked_rounded,
                                color: AppColors.mutedFog, size: 18),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (200 + m.index * 60).ms)),
              if (_selectedMethod == 0) ...[
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter UPI ID (e.g. ayush@upi)',
                    suffixText: 'Verify',
                    suffixStyle: TextStyle(color: AppColors.saffronAmber),
                  ),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.brightIvory),
                ).animate().fadeIn(),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/booking-live'),
                child: Text(
                    'Pay ₹${p.advanceAmount.toInt()} Securely'),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.mutedFog, size: 14),
                    const SizedBox(width: 6),
                    Text('Contact details revealed after payment',
                        style: AppTextStyles.micro),
                  ],
                ),
              ).animate().fadeIn(delay: 550.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value, style: valueStyle ?? AppTextStyles.monoMedium),
      ],
    );
  }
}

class _PaymentMethod {
  final int index;
  final IconData icon;
  final String label;
  const _PaymentMethod({required this.index, required this.icon, required this.label});
}
