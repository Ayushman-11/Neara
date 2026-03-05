import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/supabase_service.dart';
import '../../core/models/worker.dart';
import '../../core/di/locator.dart';
import '../../widgets/worker_card.dart';

class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  int _sortIndex = 0;
  final List<String> _sortOptions = ['Best Match', 'Nearest', 'Top Rated', 'Most Jobs'];
  
  late Future<List<Worker>> _workersFuture;

  @override
  void initState() {
    super.initState();
    _workersFuture = locator<SupabaseService>().getNearbyWorkers();
  }

  List<Worker> _sortedWorkers(List<Worker> workers) {
    final sorted = List.of(workers);
    switch (_sortIndex) {
      case 1:
        sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case 2:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 3:
        sorted.sort((a, b) => b.jobsCompleted.compareTo(a.jobsCompleted));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Workers near you'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.saffronAmber),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Worker>>(
        future: _workersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.saffronAmber));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading workers', style: AppTextStyles.bodyMedium));
          }

          final allWorkers = snapshot.data ?? [];
          final workers = _sortedWorkers(allWorkers);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    const Icon(Icons.people_rounded,
                        color: AppColors.liveTeal, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${workers.length} workers found · within 5 km',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.liveTeal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Sort chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _sortOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isActive = _sortIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _sortIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.saffronAmber : AppColors.elevatedGraphite,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isActive ? AppColors.saffronAmber : AppColors.mutedSteel,
                          ),
                        ),
                        child: Text(
                          _sortOptions[index],
                          style: AppTextStyles.label.copyWith(
                            color: isActive ? AppColors.midnightNavy : AppColors.softMoonlight,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Worker list
              if (workers.isEmpty)
                Expanded(
                  child: Center(
                    child: Text('No workers found', style: AppTextStyles.bodyMedium),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: workers.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == workers.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: TextButton.icon(
                              icon: const Icon(Icons.search_rounded),
                              label: const Text('Expand to 10 km'),
                              onPressed: () {},
                            ),
                          ),
                        );
                      }
                      final w = workers[index];
                      return WorkerCard(
                        worker: w,
                        isTopRated: w.rating >= 4.7,
                        isClosest: w.distanceKm <= 1.0,
                        onTap: () => context.push('/worker/${w.id}'),
                      ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.2);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
