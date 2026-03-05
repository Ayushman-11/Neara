import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/status_chip.dart';

class IntentConfirmationScreen extends StatelessWidget {
  final String transcript;
  final String category;
  final String urgency;

  const IntentConfirmationScreen({
    super.key,
    required this.transcript,
    required this.category,
    required this.urgency,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumber':
        return Icons.plumbing_rounded;
      case 'electrician':
        return Icons.electrical_services_rounded;
      case 'mechanic':
        return Icons.build_rounded;
      case 'ac technician':
      case 'ac repair':
        return Icons.ac_unit_rounded;
      case 'carpenter':
        return Icons.chair_alt_rounded;
      case 'painter':
        return Icons.format_paint_rounded;
      case 'cleaner':
        return Icons.cleaning_services_rounded;
      case 'pest control':
        return Icons.pest_control_rounded;
      case 'appliance repair':
        return Icons.home_repair_service_rounded;
      case 'gardener':
        return Icons.park_rounded;
      default:
        return Icons.handyman_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('We understood this'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/voice'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // AI detection card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warmCharcoal,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Stack(
                  children: [
                    // Saffron left border strip
                    Positioned(
                      left: -20,
                      top: -20,
                      bottom: -20,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: AppColors.saffronAmber,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded,
                                color: AppColors.saffronAmber, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'AI DETECTED SERVICE',
                              style: AppTextStyles.micro
                                  .copyWith(color: AppColors.saffronAmber),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(_getCategoryIcon(category),
                                color: AppColors.saffronAmber, size: 28),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(category,
                                    style: AppTextStyles.titleMedium),
                                StatusChip(
                                    label: urgency,
                                    type: urgency.toLowerCase().contains('high')
                                        ? StatusChipType.error
                                        : StatusChipType.warning),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Detected Problem:',
                            style: AppTextStyles.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          transcript,
                          style: AppTextStyles.titleSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),
              // User transcript
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.elevatedGraphite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You said:', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      '"$transcript"',
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.softMoonlight),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Is this correct?',
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Our AI detects services from what you describe.',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 350.ms),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/workers', extra: category),
                child: const Text('Yes, find workers →'),
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/voice'),
                child: const Text('No, try again'),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
