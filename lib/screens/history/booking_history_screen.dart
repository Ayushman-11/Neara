import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/mock/mock_data.dart';
import '../../widgets/status_chip.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bookings = MockData.bookings;

    StatusChipType statusType(String status) {
      switch (status.toLowerCase()) {
        case 'completed':
          return StatusChipType.success;
        case 'in progress':
          return StatusChipType.warning;
        case 'cancelled':
          return StatusChipType.error;
        default:
          return StatusChipType.muted;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Booking History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final b = bookings[i];
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
                          Text(b.workerName,
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.brightIvory)),
                          Text(b.category, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    StatusChip(
                        label: b.status, type: statusType(b.status)),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(b.date, style: AppTextStyles.bodySmall),
                    Text(
                      '₹${b.totalAmount.toInt()}',
                      style: AppTextStyles.monoSmall
                          .copyWith(color: AppColors.brightIvory),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.2);
        },
      ),
    );
  }
}
