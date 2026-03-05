import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';
import 'package:timeago/timeago.dart' as timeago;

// Imports for navigation
import 'package:worker_app/features/bookings/presentation/negotiation_screen.dart';
import 'package:worker_app/features/bookings/presentation/escrow_waiting_screen.dart';
import 'package:worker_app/features/bookings/presentation/escrow_signing_screen.dart';
import 'package:worker_app/features/bookings/presentation/navigation_screen.dart';
import 'package:worker_app/features/bookings/presentation/service_progress_screen.dart';
import 'package:worker_app/features/bookings/presentation/job_summary_screen.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workerState = ref.watch(workerProvider);
    final history = workerState.jobHistory;
    final activeJob = workerState.activeJob;

    final List<ActiveJob> ongoingJobs = activeJob != null ? [activeJob] : [];
    final completedJobs = history
        .where((j) => j.status == 'COMPLETED')
        .toList();
    final cancelledJobs = history
        .where((j) => j.status == 'CANCELLED')
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Jobs', style: AppTextStyles.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Manage your active and past services',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.saffronAmber,
          unselectedLabelColor: AppColors.mutedFog,
          indicatorColor: AppColors.saffronAmber,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: AppTextStyles.chipLabel,
          tabs: const [
            Tab(text: 'ONGOING'),
            Tab(text: 'COMPLETED'),
            Tab(text: 'CANCELLED'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOngoingList(ongoingJobs, workerState.jobStatus),
              _buildPastJobsList(completedJobs, AppColors.safeGreen),
              _buildPastJobsList(cancelledJobs, AppColors.emergencyCrimson),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOngoingList(List<ActiveJob> jobs, JobStatus status) {
    if (jobs.isEmpty) {
      return _buildEmptyState(LucideIcons.clock, 'No active jobs');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _buildActiveJobCard(job, status);
      },
    );
  }

  Widget _buildPastJobsList(List<PastJob> jobs, Color statusColor) {
    if (jobs.isEmpty) {
      return _buildEmptyState(LucideIcons.history, 'No history found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _buildHistoryCard(job, statusColor);
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.mutedFog, size: 48),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard(ActiveJob job, JobStatus status) {
    return InkWell(
      onTap: () => _navigateToLifecycle(context, status),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.liveTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.activity,
                  color: AppColors.liveTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.name.toUpperCase().replaceAll('_', ' '),
                      style: AppTextStyles.chipLabel.copyWith(
                        color: AppColors.liveTeal,
                        fontSize: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(job.serviceType, style: AppTextStyles.titleSmall),
                    Text(job.customerName, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                color: AppColors.mutedFog,
                size: 20,
              ),
            ],
          ),
        ),
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

  Widget _buildHistoryCard(PastJob job, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.midnightNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                job.status == 'COMPLETED'
                    ? LucideIcons.checkCircle2
                    : LucideIcons.xCircle,
                color: statusColor,
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
                      Text(
                        job.status,
                        style: AppTextStyles.chipLabel.copyWith(
                          color: statusColor,
                          fontSize: 8,
                        ),
                      ),
                      Text(
                        '₹${job.amount.toInt()}',
                        style: AppTextStyles.monoSmall.copyWith(
                          color: AppColors.saffronAmber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(job.serviceType, style: AppTextStyles.titleSmall),
                  Text(
                    '${job.customerName} • ${timeago.format(job.date)}',
                    style: AppTextStyles.bodySmall,
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
