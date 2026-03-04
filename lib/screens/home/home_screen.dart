import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/mock/mock_data.dart';
import '../../widgets/section_header.dart';
import '../../widgets/worker_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.plumbing_rounded, 'label': 'Plumber'},
    {'icon': Icons.electrical_services_rounded, 'label': 'Electrician'},
    {'icon': Icons.build_rounded, 'label': 'Mechanic'},
    {'icon': Icons.local_fire_department_rounded, 'label': 'Gas Tech'},
    {'icon': Icons.handyman_rounded, 'label': 'Handyman'},
    {'icon': Icons.ac_unit_rounded, 'label': 'AC Repair'},
    {'icon': Icons.chair_alt_rounded, 'label': 'Carpenter'},
    {'icon': Icons.format_paint_rounded, 'label': 'Painter'},
  ];

  @override
  Widget build(BuildContext context) {
    final nearbyWorkers = MockData.workers.where((w) => w.isOnline).take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning, Ayush 👋',
                            style: AppTextStyles.titleSmall),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: AppColors.saffronAmber, size: 14),
                            const SizedBox(width: 4),
                            Text('Koregaon Park, Pune',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.saffronAmber)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Notification + Avatar
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.brightIvory),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.saffronAmber,
                    child: Text('A',
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.midnightNavy,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SOS Strip
                    _SosStrip().animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                    const SizedBox(height: 20),
                    // Voice CTA
                    _VoiceCTA(
                      onTap: () => context.go('/voice'),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 24),
                    // Service categories
                    SectionHeader(
                      title: 'What do you need?',
                      actionLabel: 'See all',
                      onAction: () => context.go('/workers'),
                    ).animate().fadeIn(delay: 250.ms),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: _categories.map((cat) {
                        final idx = _categories.indexOf(cat);
                        return _CategoryChip(
                          icon: cat['icon'] as IconData,
                          label: cat['label'] as String,
                          onTap: () => context.go('/workers'),
                        ).animate().fadeIn(delay: (300 + idx * 40).ms).scale(
                            begin: const Offset(0.8, 0.8));
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Nearby Workers
                    SectionHeader(
                      title: 'Workers near you',
                      actionLabel: 'See all',
                      onAction: () => context.go('/workers'),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: nearbyWorkers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final w = nearbyWorkers[index];
                          return SizedBox(
                            width: 280,
                            child: WorkerCard(
                              worker: w,
                              isTopRated: index == 0,
                              isClosest: index == 1,
                              onTap: () => context.go('/worker/${w.id}'),
                            ),
                          ).animate().fadeIn(delay: (430 + index * 60).ms).slideX(begin: 0.2);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);
          switch (index) {
            case 1:
              context.go('/workers');
              break;
            case 2:
              context.go('/history');
              break;
            case 3:
              context.go('/wallet');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}

class _SosStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/sos'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.emergencyCrimson.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.emergencyCrimson.withAlpha(80)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.emergencyCrimson,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergencyCrimson.withAlpha(80),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.sos_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency?',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.emergencyCrimson,
                          fontWeight: FontWeight.w700)),
                  Text('Tap to activate SOS',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.emergencyCrimson,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'SOS',
                style: AppTextStyles.chipLabel.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceCTA extends StatelessWidget {
  final VoidCallback onTap;
  const _VoiceCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.saffronAmber.withAlpha(25),
            AppColors.warmCharcoal,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.saffronAmber.withAlpha(60)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.saffronAmber,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.saffronGlow,
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic_rounded,
                    color: AppColors.midnightNavy, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Describe your problem',
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                        '"My kitchen sink is leaking…"',
                        style: AppTextStyles.bodySmall
                            .copyWith(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.mic_rounded, size: 18),
            label: const Text('Speak Now'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.warmCharcoal,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mutedSteel),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.saffronAmber, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.micro.copyWith(color: AppColors.softMoonlight),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.warmCharcoal,
        border: Border(top: BorderSide(color: AppColors.mutedSteel)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
