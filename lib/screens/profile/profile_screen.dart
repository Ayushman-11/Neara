import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/mock/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar + info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warmCharcoal,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.elevatedGraphite,
                          child: Text('A',
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: AppColors.saffronAmber)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.saffronAmber,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.warmCharcoal, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                size: 12, color: AppColors.midnightNavy),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Ayush Gupta',
                        style: AppTextStyles.titleSmall),
                    Text('+91 98765 43210',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.safeGreen.withAlpha(20),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: AppColors.safeGreen.withAlpha(80)),
                      ),
                      child: Text('✓ Verified',
                          style: AppTextStyles.chipLabel
                              .copyWith(color: AppColors.safeGreen)),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),
              // Stats
              const Row(
                children: [
                  Expanded(
                    child: _StatCard(label: 'Bookings', value: '4'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: 'Reviews', value: '3'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: 'Savings', value: '₹45'),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 20),
              // Menu items
              ...[
                {'icon': Icons.person_rounded, 'label': 'Edit Profile', 'onTap': () {}},
                {
                  'icon': Icons.contacts_rounded,
                  'label': 'Emergency Contacts',
                  'onTap': () => context.go('/emergency-contacts')
                },
                {
                  'icon': Icons.account_balance_wallet_rounded,
                  'label': 'Wallet',
                  'onTap': () => context.go('/wallet')
                },
                {'icon': Icons.notifications_rounded, 'label': 'Notifications', 'onTap': () {}},
                {'icon': Icons.lock_rounded, 'label': 'Privacy', 'onTap': () {}},
                {'icon': Icons.help_rounded, 'label': 'Help & Support', 'onTap': () {}},
                {
                  'icon': Icons.logout_rounded,
                  'label': 'Logout',
                  'onTap': () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false);
                    if (context.mounted) context.go('/login');
                  }
                },
              ].asMap().entries.map((e) {
                final item = e.value;
                final isLast = e.key == 6;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warmCharcoal,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mutedSteel),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: isLast
                          ? AppColors.emergencyCrimson
                          : AppColors.saffronAmber,
                      size: 20,
                    ),
                    title: Text(
                      item['label'] as String,
                      style: AppTextStyles.label.copyWith(
                        color: isLast
                            ? AppColors.emergencyCrimson
                            : AppColors.brightIvory,
                      ),
                    ),
                    trailing: isLast
                        ? null
                        : const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.mutedFog, size: 14),
                    onTap: item['onTap'] as void Function(),
                  ),
                ).animate().fadeIn(delay: (300 + e.key * 40).ms);
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.elevatedGraphite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mutedSteel),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.monoSmall
                  .copyWith(color: AppColors.saffronAmber)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.micro),
        ],
      ),
    );
  }
}
