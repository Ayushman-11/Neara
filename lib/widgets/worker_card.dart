import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/models/worker.dart';
import 'status_chip.dart';

class WorkerCard extends StatelessWidget {
  final Worker worker;
  final bool isTopRated;
  final bool isClosest;
  final VoidCallback? onTap;

  const WorkerCard({
    super.key,
    required this.worker,
    this.isTopRated = false,
    this.isClosest = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warmCharcoal,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mutedSteel, width: 1),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.elevatedGraphite,
                  child: Text(
                    worker.avatarInitials,
                    style: AppTextStyles.titleSmall.copyWith(color: AppColors.saffronAmber),
                  ),
                ),
                if (worker.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.liveTeal,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.warmCharcoal, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        worker.name,
                        style: AppTextStyles.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 6),
                      if (isTopRated)
                        StatusChip(label: 'Top Rated', type: StatusChipType.accent),
                      if (isClosest && !isTopRated)
                        StatusChip(label: 'Closest', type: StatusChipType.online),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(worker.category, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _StatPill(
                        icon: Icons.star_rounded,
                        iconColor: AppColors.saffronAmber,
                        label: worker.rating.toStringAsFixed(1),
                      ),
                      _StatPill(
                        icon: Icons.location_on_rounded,
                        iconColor: AppColors.softMoonlight,
                        label: '${worker.distanceKm} km',
                      ),
                      _StatPill(
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: AppColors.safeGreen,
                        label: '${worker.jobsCompleted} jobs',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatPill({required this.icon, required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
