import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/service_request_service.dart';
import '../../core/di/locator.dart';
import '../../widgets/status_chip.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = locator<ServiceRequestService>().getMyRequests();
  }

  StatusChipType _statusType(String status) {
    switch (status.toUpperCase()) {
      case 'SERVICE_COMPLETED':
      case 'SERVICE_CLOSED':
        return StatusChipType.success;
      case 'REQUEST_ACCEPTED':
      case 'PROPOSAL_SENT':
      case 'NEGOTIATION':
      case 'ADVANCE_PAID':
      case 'WORKER_COMING':
      case 'WORKER_ARRIVED':
      case 'SERVICE_STARTED':
      case 'FINAL_PAYMENT_PENDING':
        return StatusChipType.warning;
      case 'REQUEST_SENT':
      case 'PENDING':
        return StatusChipType.muted;
      default:
        return StatusChipType.error;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((s) {
      if (s.isEmpty) return s;
      return s[0].toUpperCase() + s.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Booking History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.saffronAmber),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading requests\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.emergencyCrimson),
              ),
            );
          }
          
          final requests = snapshot.data ?? [];
          
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppColors.mutedFog),
                  const SizedBox(height: 16),
                  Text('No service requests yet.', style: AppTextStyles.label),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final req = requests[i];
              
              final workerName = req['profiles']?['full_name'] ?? 'Pending Assignment';
              final categoryName = req['service_categories']?['name'] ?? 'Service Request';
              final String rawStatus = req['status'] ?? 'UNKNOWN';
              final statusDisplay = _formatStatus(rawStatus);
              
              final createdAt = DateTime.tryParse(req['created_at'].toString())?.toLocal();
              final dateDisplay = createdAt != null 
                ? DateFormat('dd MMM, yyyy - hh:mm a').format(createdAt)
                : 'Unknown Date';
                
              final totalCost = req['total_cost'] ?? 0;

              return Container(
                padding: const EdgeInsets.all(16),
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.elevatedGraphite,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.handyman_rounded,
                              color: AppColors.saffronAmber, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(workerName,
                                  style: AppTextStyles.label
                                      .copyWith(color: AppColors.brightIvory)),
                              Text(categoryName, style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        StatusChip(
                            label: statusDisplay, type: _statusType(rawStatus)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateDisplay, style: AppTextStyles.bodySmall),
                        Text(
                          '₹$totalCost',
                          style: AppTextStyles.monoSmall
                              .copyWith(color: AppColors.brightIvory),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (i > 5 ? 5 : i * 60).ms).slideY(begin: 0.2);
            },
          );
        },
      ),
    );
  }
}

