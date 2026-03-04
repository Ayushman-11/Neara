import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/mock/mock_data.dart';

class ServiceRequestScreen extends StatelessWidget {
  const ServiceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final worker = MockData.workers.first;

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Service Request'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/worker/${worker.id}'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worker mini card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warmCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.elevatedGraphite,
                      child: Text(worker.avatarInitials,
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.saffronAmber)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(worker.name, style: AppTextStyles.label.copyWith(
                            color: AppColors.brightIvory)),
                        Text(worker.category, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),
              Text('Request Details', style: AppTextStyles.titleSmall),
              const SizedBox(height: 14),
              _DetailRow(label: 'Service', value: 'Plumber'),
              const Divider(height: 24),
              _DetailRow(
                  label: 'Location',
                  value: 'Flat 4B, Silver Oaks, Koregaon Park, Pune 411001'),
              const Divider(height: 24),
              _DetailRow(label: 'Problem', value: 'Water leakage in kitchen sink'),
              const Divider(height: 24),
              _DetailRow(label: 'Urgency', value: 'Normal'),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.liveTeal.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.liveTeal.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_rounded,
                        color: AppColors.liveTeal, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your contact details will be visible to the worker only after payment.',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.liveTeal),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/request-status'),
                child: const Text('Send Request to Ramesh'),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(value,
              style: AppTextStyles.label.copyWith(color: AppColors.brightIvory)),
        ),
      ],
    );
  }
}
