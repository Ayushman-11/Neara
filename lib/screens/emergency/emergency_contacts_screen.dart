import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/mock/mock_data.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add_rounded,
                color: AppColors.saffronAmber, size: 18),
            label: Text('Add',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.saffronAmber)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.emergencyCrimson.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.emergencyCrimson.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded,
                      color: AppColors.emergencyCrimson, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These contacts will be notified with live location upon SOS activation.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.emergencyCrimson),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: MockData.emergencyContacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final contact = MockData.emergencyContacts[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warmCharcoal,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mutedSteel),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.elevatedGraphite,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: AppColors.saffronAmber, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contact['name'] as String,
                                style: AppTextStyles.label
                                    .copyWith(color: AppColors.brightIvory)),
                            Text(contact['relation'] as String,
                                style: AppTextStyles.bodySmall),
                            Text(contact['phone'] as String,
                                style: AppTextStyles.monoSmall
                                    .copyWith(color: AppColors.mutedFog)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_rounded,
                            color: AppColors.safeGreen, size: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.emergencyCrimson, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (100 + i * 60).ms).slideY(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    );
  }
}
