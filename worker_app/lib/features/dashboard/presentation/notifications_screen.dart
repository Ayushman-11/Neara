import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Withdrawal Successful',
        'body': '₹5,000 has been credited to your HDFC Bank account.',
        'time': '2 hours ago',
        'icon': LucideIcons.checkCircle2,
        'color': AppColors.safeGreen,
      },
      {
        'title': 'KYC Verified',
        'body':
            'Your profile is now verified. You can start receiving higher-limit jobs.',
        'time': 'Yesterday',
        'icon': LucideIcons.shieldCheck,
        'color': AppColors.liveTeal,
      },
      {
        'title': 'Safety Alert',
        'body':
            'High demand for electricians in your area. Go online to earn more.',
        'time': '2 days ago',
        'icon': LucideIcons.zap,
        'color': AppColors.saffronAmber,
      },
      {
        'title': 'Policy Update',
        'body':
            'We have updated our terms of service regarding escrow release.',
        'time': '3 days ago',
        'icon': LucideIcons.fileText,
        'color': AppColors.mutedFog,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warmCharcoal,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.mutedSteel),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.midnightNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(n['icon'], color: n['color'], size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(n['title'], style: AppTextStyles.titleSmall),
                          Text(
                            n['time'],
                            style: AppTextStyles.monoSmall.copyWith(
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(n['body'], style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
