import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/mock/mock_data.dart';

class ProposalScreen extends StatefulWidget {
  const ProposalScreen({super.key});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  int _secondsLeft = 522;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _secondsLeft > 0) {
        setState(() => _secondsLeft--);
        _tick();
      }
    });
  }

  String get _formattedTimer {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = MockData.mockProposal;
    final worker = MockData.workers.first;

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Service Proposal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/request-status'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worker mini card
              Container(
                padding: const EdgeInsets.all(12),
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
                      child: Text(worker.avatarInitials,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.saffronAmber)),
                    ),
                    const SizedBox(width: 10),
                    Text(worker.name,
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.brightIvory)),
                    const SizedBox(width: 8),
                    Text('·', style: AppTextStyles.bodySmall),
                    const SizedBox(width: 8),
                    Text(worker.category, style: AppTextStyles.bodySmall),
                  ],
                ),
              ).animate().fadeIn(delay: 50.ms),
              const SizedBox(height: 16),
              // Proposal card
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
                    _PriceRow(
                        label: 'INSPECTION FEE',
                        value: '₹${p.inspectionFee.toInt()}',
                        valueColor: AppColors.softMoonlight),
                    const Divider(height: 24),
                    _PriceRow(
                        label: 'ESTIMATED REPAIR',
                        value: '₹${p.estimatedRepair.toInt()}',
                        valueColor: AppColors.brightIvory),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ADVANCE REQUIRED',
                            style: AppTextStyles.micro),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warningAmber.withAlpha(30),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: AppColors.warningAmber.withAlpha(80)),
                          ),
                          child: Text('${p.advancePercent}%',
                              style: AppTextStyles.chipLabel
                                  .copyWith(color: AppColors.warningAmber)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.elevatedGraphite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ADVANCE TO PAY', style: AppTextStyles.micro),
                          const SizedBox(height: 6),
                          Text(
                            '₹${p.advanceAmount.toInt()}',
                            style: AppTextStyles.monoLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Balance after service: ₹${p.balanceAmount.toInt()}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Notes', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 6),
                    Text(p.notes,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontStyle: FontStyle.italic)),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 12),
              // Expiry timer
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_rounded,
                        color: AppColors.emergencyCrimson, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Proposal expires in $_formattedTimer',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.emergencyCrimson),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.push('/payment'),
                child: const Text('Accept & Pay Advance'),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/negotiation'),
                child: const Text('Negotiate'),
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text('Decline',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.mutedFog)),
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _PriceRow(
      {required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.micro),
        Text(value,
            style: AppTextStyles.monoMedium.copyWith(color: valueColor)),
      ],
    );
  }
}
