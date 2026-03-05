import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:worker_app/features/bookings/presentation/request_details_screen.dart';
import 'package:worker_app/features/dashboard/presentation/jobs_screen.dart';
import 'package:worker_app/features/dashboard/presentation/profile_screen.dart';
import 'package:worker_app/features/dashboard/presentation/earnings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:worker_app/features/dashboard/presentation/notifications_screen.dart';
import 'package:worker_app/features/bookings/presentation/negotiation_screen.dart';
import 'package:worker_app/features/bookings/presentation/escrow_waiting_screen.dart';
import 'package:worker_app/features/bookings/presentation/escrow_signing_screen.dart';
import 'package:worker_app/features/bookings/presentation/navigation_screen.dart';
import 'package:worker_app/features/bookings/presentation/service_progress_screen.dart';
import 'package:worker_app/features/bookings/presentation/job_summary_screen.dart';

class WorkerDashboardScreen extends ConsumerStatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  ConsumerState<WorkerDashboardScreen> createState() =>
      _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends ConsumerState<WorkerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final workerState = ref.watch(workerProvider);
    final isOnline = workerState.isOnline;

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: Text('Neara Worker', style: AppTextStyles.titleMedium),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.bell,
              size: 20,
              color: AppColors.mutedFog,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Text(
                isOnline ? 'ONLINE' : 'OFFLINE',
                style: AppTextStyles.chipLabel.copyWith(
                  color: isOnline ? AppColors.liveTeal : AppColors.mutedFog,
                ),
              ),
              Switch(
                value: isOnline,
                onChanged: (value) =>
                    ref.read(workerProvider.notifier).toggleOnline(value),
                activeColor: AppColors.liveTeal,
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: !isOnline,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              // No const here to ensure they build correctly with current context/state
              const HomeTab(),
              const JobsScreen(),
              const EarningsScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
      ),
      floatingActionButton: !isOnline && _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () =>
                  ref.read(workerProvider.notifier).toggleOnline(true),
              backgroundColor: AppColors.liveTeal,
              label: const Text('GO ONLINE'),
              icon: const Icon(LucideIcons.power),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.briefcase),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerState = ref.watch(workerProvider);
    final requests = workerState.nearbyRequests;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:
            MainAxisSize.min, // Ensure Column doesn't expand needlessly
        children: [
          if (workerState.jobStatus != JobStatus.idle &&
              workerState.activeJob != null)
            _ActiveJobCard(state: workerState),
          const _EarningsSummaryCard(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('New Requests', style: AppTextStyles.titleLarge),
              if (requests.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.saffronGlow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${requests.length} NEARBY',
                    style: AppTextStyles.chipLabel.copyWith(
                      color: AppColors.saffronAmber,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (requests.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Icon(
                      LucideIcons.search,
                      color: AppColors.mutedFog,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No new requests nearby',
                      style: AppTextStyles.bodyLarge,
                    ),
                    Text(
                      'We\'ll notify you when a job appears',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          else
            ...requests.map((request) => _RequestCard(request: request)),
        ],
      ),
    );
  }
}

class _EarningsSummaryCard extends StatelessWidget {
  const _EarningsSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.warmCharcoal,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mutedSteel),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmCharcoal,
            AppColors.elevatedGraphite.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TODAY\'S EARNINGS', style: AppTextStyles.chipLabel),
              const Icon(
                LucideIcons.trendingUp,
                color: AppColors.liveTeal,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('₹1,450.00', style: AppTextStyles.heroAmount),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Jobs', '4'),
              _buildStat('Rating', '4.8★'),
              _buildStat('Online', '6.5h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(value, style: AppTextStyles.titleMedium),
      ],
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final WorkerState state;
  const _ActiveJobCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final job = state.activeJob!;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            AppColors.elevatedGraphite, // Different color to ensure visibility
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.liveTeal.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.liveTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.playCircle,
                  color: AppColors.liveTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE JOB',
                      style: AppTextStyles.chipLabel.copyWith(
                        color: AppColors.liveTeal,
                      ),
                    ),
                    Text(job.serviceType, style: AppTextStyles.titleSmall),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _navigateToLifecycle(context, state.jobStatus),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.liveTeal,
                  foregroundColor: AppColors.midnightNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('RESUME'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToLifecycle(BuildContext context, JobStatus status) {
    Widget target;
    switch (status) {
      case JobStatus.negotiating:
        target = const NegotiationScreen();
        break;
      case JobStatus.waitingEscrow:
        target = const EscrowWaitingScreen();
        break;
      case JobStatus.escrowSigning:
        target = const EscrowSigningScreen();
        break;
      case JobStatus.coming:
      case JobStatus.arrived:
        target = const NavigationScreen();
        break;
      case JobStatus.started:
      case JobStatus.completing:
      case JobStatus.waitingFinalPayment:
        target = const ServiceProgressScreen();
        break;
      case JobStatus.closed:
        target = const JobSummaryScreen();
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => target));
  }
}

class _RequestCard extends ConsumerWidget {
  final ServiceRequest request;
  const _RequestCard({required this.request});

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'URGENT':
        return AppColors.emergencyCrimson;
      case 'FAST RESPONSE':
        return AppColors.warningAmber;
      default:
        return AppColors.liveTeal;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagColor = _getTagColor(request.tag);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.midnightNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.wrench,
                    color: AppColors.saffronAmber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: tagColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              request.tag,
                              style: AppTextStyles.chipLabel.copyWith(
                                color: tagColor,
                                fontSize: 8,
                              ),
                            ),
                          ),
                          Text(
                            timeago.format(request.createdAt),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(request.title, style: AppTextStyles.titleSmall),
                      Text(
                        '${request.category} • ${request.distance}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref
                        .read(workerProvider.notifier)
                        .ignoreRequest(request.id),
                    child: const Text('Ignore'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RequestDetailsScreen(request: request),
                        ),
                      );
                    },
                    child: const Text('View & Bid'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
