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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _sortOptions = ['Best Match', 'Nearest', 'Top Rated', 'Most Jobs'];
  late Future<List<Worker>> _workersFuture;

  @override
  void initState() {
    super.initState();
    _workersFuture = locator<SupabaseService>().getNearbyWorkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Worker> _sortedAndFiltered(List<Worker> workers) {
    List<Worker> list = workers;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((w) =>
          w.name.toLowerCase().contains(q) ||
          w.category.toLowerCase().contains(q)).toList();
    }

    final sorted = List.of(list);
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
        backgroundColor: AppColors.midnightNavy,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.brightIvory),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Workers near you'),
        actions: const [],
      ),
      body: FutureBuilder<List<Worker>>(
        future: _workersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.saffronAmber),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, color: AppColors.mutedFog, size: 48),
                  const SizedBox(height: 12),
                  Text('Failed to load workers', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _workersFuture = locator<SupabaseService>().getNearbyWorkers();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final allWorkers = snapshot.data ?? [];
          final workers = _sortedAndFiltered(allWorkers);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search Bar ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.elevatedGraphite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.mutedSteel),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.search_rounded,
                          color: AppColors.mutedFog, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.brightIvory),
                          decoration: InputDecoration(
                            hintText: 'Search by name or service...',
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mutedFog),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.close_rounded,
                                color: AppColors.mutedFog, size: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 50.ms),

              const SizedBox(height: 12),

              // ── Stats row ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.liveTeal.withAlpha(18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.liveTeal.withAlpha(60)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_rounded,
                              color: AppColors.liveTeal, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${workers.length} workers found',
                            style: AppTextStyles.micro.copyWith(
                                color: AppColors.liveTeal,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Sort chips ──────────────────────────────
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _sortOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final isActive = _sortIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _sortIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.saffronAmber
                              : AppColors.elevatedGraphite,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isActive
                                ? AppColors.saffronAmber
                                : AppColors.mutedSteel,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _sortOptions[index],
                            style: AppTextStyles.micro.copyWith(
                              color: isActive
                                  ? AppColors.midnightNavy
                                  : AppColors.softMoonlight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 14),

              // ── Worker list ─────────────────────────────
              if (workers.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            color: AppColors.mutedFog, size: 48),
                        const SizedBox(height: 12),
                        Text('No workers found', style: AppTextStyles.bodyMedium),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Try a different search term',
                              style: AppTextStyles.bodySmall),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: workers.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == workers.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Center(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.softMoonlight,
                                side: const BorderSide(
                                    color: AppColors.mutedSteel),
                                textStyle: AppTextStyles.bodySmall,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              onPressed: () {},
                              child: const Text('Show More'),
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
                      ).animate().fadeIn(delay: (index * 50).ms).slideY(
                          begin: 0.15,
                          curve: Curves.easeOutCubic);
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
