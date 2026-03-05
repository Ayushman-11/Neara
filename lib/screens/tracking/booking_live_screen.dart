import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/status_chip.dart';

class BookingLiveScreen extends StatefulWidget {
  const BookingLiveScreen({super.key});

  @override
  State<BookingLiveScreen> createState() => _BookingLiveScreenState();
}

class _BookingLiveScreenState extends State<BookingLiveScreen> {
  int _currentStep = 1; // 0=Sent, 1=Accepted, 2=Arrived, 3=InProgress, 4=Done

  final List<Map<String, dynamic>> _steps = [
    {'icon': Icons.send_rounded, 'label': 'Requested'},
    {'icon': Icons.check_circle_rounded, 'label': 'Accepted'},
    {'icon': Icons.directions_walk_rounded, 'label': 'Coming'},
    {'icon': Icons.handyman_rounded, 'label': 'In Progress'},
    {'icon': Icons.done_all_rounded, 'label': 'Done'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Column(
        children: [
          // Mock map
          Container(
            height: MediaQuery.of(context).size.height * 0.38,
            color: AppColors.warmCharcoal,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_rounded,
                          color: AppColors.mutedSteel, size: 60),
                      const SizedBox(height: 8),
                      Text('Live map • Worker en route',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                // Worker pin (mock)
                Positioned(
                  left: 120,
                  top: 100,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.saffronAmber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.saffronGlow, blurRadius: 16),
                      ],
                    ),
                    child: const Icon(Icons.person_pin_circle_rounded,
                        color: AppColors.midnightNavy, size: 20),
                  ),
                ),
                // User pin
                Positioned(
                  right: 80,
                  bottom: 80,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.liveTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.home_rounded,
                        color: AppColors.midnightNavy, size: 20),
                  ),
                ),
                // Back button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.warmCharcoal.withAlpha(200),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 18),
                      ),
                      onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Status sheet
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusChip(label: 'Worker Coming', type: StatusChipType.warning),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: AppColors.liveTeal, size: 14),
                          const SizedBox(width: 4),
                          Text('~12 mins away',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.liveTeal)),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),
                  // Worker card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warmCharcoal,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.mutedSteel),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.elevatedGraphite,
                          child: Text('RS', style: TextStyle(
                              color: AppColors.saffronAmber, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ramesh Sharma',
                                style: TextStyle(
                                    color: AppColors.brightIvory,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            Text('4.7 ⭐  ·  1.3 km',
                                style: TextStyle(
                                    color: AppColors.mutedFog, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.elevatedGraphite,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.call_rounded,
                                color: AppColors.saffronAmber, size: 18),
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.elevatedGraphite,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_rounded,
                                color: AppColors.softMoonlight, size: 18),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 20),
                  // Timeline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _steps.asMap().entries.map((e) {
                      final isDone = e.key <= _currentStep;
                      return Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                if (e.key > 0)
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: e.key <= _currentStep
                                          ? AppColors.saffronAmber
                                          : AppColors.mutedSteel,
                                    ),
                                  ),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? AppColors.saffronAmber
                                        : AppColors.elevatedGraphite,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDone
                                          ? AppColors.saffronAmber
                                          : AppColors.mutedSteel,
                                    ),
                                  ),
                                  child: Icon(
                                    e.value['icon'] as IconData,
                                    size: 14,
                                    color: isDone
                                        ? AppColors.midnightNavy
                                        : AppColors.mutedFog,
                                  ),
                                ),
                                if (e.key < _steps.length - 1)
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: e.key < _currentStep
                                          ? AppColors.saffronAmber
                                          : AppColors.mutedSteel,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e.value['label'] as String,
                              style: TextStyle(
                                fontSize: 9,
                                color: isDone
                                    ? AppColors.saffronAmber
                                    : AppColors.mutedFog,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/in-progress'),
                    child: const Text('Mark as Arrived (Mock)'),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppColors.emergencyCrimson,
        onPressed: () => context.push('/sos'),
        child: const Icon(Icons.sos_rounded, color: Colors.white),
      ),
    );
  }
}
