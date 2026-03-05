import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/bookings/presentation/proposal_screen.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';

class RequestDetailsScreen extends ConsumerWidget {
  final ServiceRequest request;

  const RequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMapMock(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.emergencyCrimson.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          request.tag,
                          style: AppTextStyles.chipLabel.copyWith(
                            color: AppColors.emergencyCrimson,
                          ),
                        ),
                      ),
                      Text(request.distance, style: AppTextStyles.monoSmall),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(request.title, style: AppTextStyles.displayLarge),
                  const SizedBox(height: 8),
                  Text(
                    request.category,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.saffronAmber,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Problem Description'),
                  const SizedBox(height: 8),
                  Text(
                    'The kitchen tap is leaking significantly from the base. It requires immediate attention to prevent water wastage and potential cabinet damage.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Customer Info'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.elevatedGraphite,
                        child: Icon(
                          LucideIcons.user,
                          color: AppColors.mutedFog,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Amit Kumar', style: AppTextStyles.titleSmall),
                          Text(
                            'Verified Customer • 4.9★',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Risk Assessment'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.elevatedGraphite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.mutedSteel),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.shieldCheck,
                          color: AppColors.liveTeal,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Low Risk Area',
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.liveTeal,
                                ),
                              ),
                              Text(
                                'Community verified location.',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProposalScreen(request: request),
                        ),
                      );
                    },
                    child: const Text('Create Proposal'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(workerProvider.notifier)
                          .ignoreRequest(request.id);
                      Navigator.pop(context);
                    },
                    child: const Text('Decline Request'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapMock() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.elevatedGraphite,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            LucideIcons.map,
            size: 48,
            color: AppColors.mutedSteel.withOpacity(0.5),
          ),
          const Icon(
            LucideIcons.mapPin,
            color: AppColors.emergencyCrimson,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.chipLabel.copyWith(color: AppColors.mutedFog),
    );
  }
}
