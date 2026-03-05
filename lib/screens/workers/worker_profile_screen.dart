import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/supabase_service.dart';
import '../../core/models/worker.dart';
import '../../core/di/locator.dart';
import '../../widgets/status_chip.dart';

class WorkerProfileScreen extends StatelessWidget {
  final String workerId;
  const WorkerProfileScreen({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Worker>>(
      future: locator<SupabaseService>().getNearbyWorkers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.midnightNavy,
            body: Center(child: CircularProgressIndicator(color: AppColors.saffronAmber)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.midnightNavy,
            appBar: AppBar(title: const Text('Worker Not Found')),
            body: Center(child: Text('Error loading worker details', style: AppTextStyles.bodySmall)),
          );
        }

        final workerList = snapshot.data!;
        // Simple fallback to the first worker if ID doesn't exactly match (since we seeded random uuids and passing arbitrary IDs locally)
        final worker = workerList.firstWhere(
          (w) => w.id == workerId,
          orElse: () => workerList.first,
        );

        return Scaffold(
          backgroundColor: AppColors.midnightNavy,
          body: CustomScrollView(
            slivers: [
              // SliverAppBar with hero header
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.midnightNavy,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.elevatedGraphite.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/workers'),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.elevatedGraphite.withAlpha(200),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share_rounded, size: 20),
                    ),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.warmCharcoal,
                          AppColors.midnightNavy,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: AppColors.elevatedGraphite,
                              child: Text(
                                worker.avatarInitials,
                                style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.saffronAmber),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.liveTeal,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.warmCharcoal, width: 2),
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(worker.name, style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: AppColors.mutedFog, size: 12),
                            const SizedBox(width: 4),
                            Text(worker.location,
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (worker.isOnline)
                              const StatusChip(
                                  label: '● Online', type: StatusChipType.online)
                            else
                              const StatusChip(
                                  label: 'Offline', type: StatusChipType.muted),
                            const SizedBox(width: 8),
                            StatusChip(
                                label: worker.category,
                                type: StatusChipType.accent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats row
                      Row(
                        children: [
                          _StatCard(
                              label: 'Rating',
                              value: worker.rating.toStringAsFixed(1),
                              icon: Icons.star_rounded,
                              iconColor: AppColors.saffronAmber),
                          const SizedBox(width: 12),
                          _StatCard(
                              label: 'Jobs Done',
                              value: '${worker.jobsCompleted}',
                              icon: Icons.check_circle_rounded,
                              iconColor: AppColors.safeGreen),
                          const SizedBox(width: 12),
                          _StatCard(
                              label: 'Distance',
                              value: '${worker.distanceKm} km',
                              icon: Icons.directions_walk_rounded,
                              iconColor: AppColors.liveTeal),
                        ],
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 24),
                      Text('About', style: AppTextStyles.titleSmall),
                      const SizedBox(height: 8),
                      Text(worker.about, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 24),
                      Text('Services Offered', style: AppTextStyles.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: worker.services.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.elevatedGraphite,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.mutedSteel),
                            ),
                            child: Text(s, style: AppTextStyles.label),
                          );
                        }).toList(),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),
                      // Reviews section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reviews', style: AppTextStyles.titleSmall),
                          Text('${worker.reviewCount} reviews',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        3,
                        (i) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warmCharcoal,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.mutedSteel),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.elevatedGraphite,
                                    child: Text(
                                      ['A', 'P', 'S'][i],
                                      style: AppTextStyles.bodySmall
                                          .copyWith(color: AppColors.saffronAmber),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ['Ayush Gupta', 'Priya S.', 'Sneha T.'][i],
                                          style: AppTextStyles.label.copyWith(
                                              color: AppColors.brightIvory),
                                        ),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (s) => Icon(
                                              Icons.star_rounded,
                                              size: 12,
                                              color: s < [5, 4, 5][i]
                                                  ? AppColors.saffronAmber
                                                  : AppColors.mutedSteel,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(['3 days ago', '1 week ago', '2 weeks ago'][i],
                                      style: AppTextStyles.micro),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                [
                                  'Really fast and professional! Fixed the leak in 30 mins.',
                                  'Good work overall. Arrived a bit late.',
                                  'Excellent service, very transparent about pricing.',
                                ][i],
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (300 + i * 80).ms),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/request', extra: worker),
                        child: const Text('Send Service Request'),
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.elevatedGraphite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mutedSteel),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.monoSmall.copyWith(color: AppColors.brightIvory)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.micro),
          ],
        ),
      ),
    );
  }
}
