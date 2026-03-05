import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:worker_app/features/onboarding/presentation/kyc_verification_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';

class CategorySelectionScreen extends ConsumerStatefulWidget {
  final bool isEditing;
  const CategorySelectionScreen({super.key, this.isEditing = false});

  @override
  ConsumerState<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen> {
  late List<Map<String, dynamic>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = [
      {'name': 'Plumber', 'icon': LucideIcons.droplets, 'selected': false},
      {'name': 'Electrician', 'icon': LucideIcons.zap, 'selected': false},
      {'name': 'Mechanic', 'icon': LucideIcons.settings, 'selected': false},
      {'name': 'Handyman', 'icon': LucideIcons.hammer, 'selected': false},
      {'name': 'Cleaner', 'icon': LucideIcons.brush, 'selected': false},
      {'name': 'Painter', 'icon': LucideIcons.paintBucket, 'selected': false},
    ];

    // Initialize with current state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentCategories = ref.read(workerProvider).selectedCategories;
      setState(() {
        for (var cat in _categories) {
          cat['selected'] = currentCategories.contains(cat['name']);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Categories')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('What do you do?', style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Select one or more categories that match your skills',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          cat['selected'] = !cat['selected'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cat['selected']
                              ? AppColors.saffronGlow
                              : AppColors.elevatedGraphite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cat['selected']
                                ? AppColors.saffronAmber
                                : AppColors.mutedSteel,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              cat['icon'],
                              color: cat['selected']
                                  ? AppColors.saffronAmber
                                  : AppColors.mutedFog,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              cat['name'],
                              style: AppTextStyles.titleSmall.copyWith(
                                color: cat['selected']
                                    ? AppColors.saffronAmber
                                    : AppColors.brightIvory,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final selected = _categories
                      .where((c) => c['selected'] as bool)
                      .map((c) => c['name'] as String)
                      .toList();

                  ref.read(workerProvider.notifier).updateCategories(selected);

                  if (widget.isEditing) {
                    Navigator.pop(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KycVerificationScreen(),
                      ),
                    );
                  }
                },
                child: Text(widget.isEditing ? 'Save Changes' : 'Save & Next'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
