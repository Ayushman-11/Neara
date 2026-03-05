import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/models/worker.dart';

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warmCharcoal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mutedSteel, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: Avatar ─────────────────────────────
            Stack(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.elevatedGraphite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    worker.avatarInitials,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.saffronAmber,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (worker.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 11,
                      height: 11,
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

            // ── Right: Info ───────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name row
                  Text(
                    worker.name,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.brightIvory,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),

                  // Category
                  Text(
                    worker.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mutedFog,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),

                  // Badges
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (worker.isOnline)
                        _Badge(label: 'Online', color: AppColors.liveTeal),
                      if (isTopRated)
                        _Badge(label: '★ Top Rated', color: AppColors.saffronAmber),
                      if (isClosest && !isTopRated)
                        _Badge(label: 'Nearest', color: AppColors.softMoonlight),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Stats row
                  Row(
                    children: [
                      Flexible(
                        child: _StatPill(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.saffronAmber,
                          label: worker.rating.toStringAsFixed(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: _StatPill(
                          icon: Icons.near_me_rounded,
                          iconColor: AppColors.mutedFog,
                          label: '${worker.distanceKm} km',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: _StatPill(
                          icon: Icons.check_circle_rounded,
                          iconColor: AppColors.safeGreen,
                          label: '${worker.jobsCompleted} jobs',
                        ),
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Text(
        label,
        style: AppTextStyles.micro.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.softMoonlight),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
