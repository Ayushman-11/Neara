import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:worker_app/features/onboarding/presentation/category_selection_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';

class WorkerRegistrationScreen extends ConsumerStatefulWidget {
  const WorkerRegistrationScreen({super.key});

  @override
  ConsumerState<WorkerRegistrationScreen> createState() =>
      _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState
    extends ConsumerState<WorkerRegistrationScreen> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final workerState = ref.watch(workerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.elevatedGraphite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.mutedSteel,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.user,
                        size: 40,
                        color: AppColors.mutedFog,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.saffronAmber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.camera,
                          size: 16,
                          color: AppColors.midnightNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text('Full Name', style: AppTextStyles.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                ),
              ),
              const SizedBox(height: 24),
              Text('Service Area Radius', style: AppTextStyles.titleSmall),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () =>
                    _showRadiusDialog(context, ref, workerState.serviceRadius),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.elevatedGraphite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mutedSteel),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        color: AppColors.saffronAmber,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discovery Radius',
                              style: AppTextStyles.label,
                            ),
                            Text(
                              '${workerState.serviceRadius.toInt()} km',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: AppColors.mutedFog,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategorySelectionScreen(),
                    ),
                  );
                },
                child: const Text('Next: Select Categories'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showRadiusDialog(
    BuildContext context,
    WidgetRef ref,
    double currentRadius,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        double radius = currentRadius;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.warmCharcoal,
              title: Text(
                'Adjust Service Radius',
                style: AppTextStyles.titleMedium,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${radius.toInt()} km', style: AppTextStyles.heroAmount),
                  Slider(
                    value: radius,
                    min: 1,
                    max: 50,
                    activeColor: AppColors.saffronAmber,
                    onChanged: (value) => setDialogState(() => radius = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(workerProvider.notifier).updateRadius(radius);
                    Navigator.pop(context);
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
