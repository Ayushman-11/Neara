import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/mock/mock_data.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with TickerProviderStateMixin {
  bool _activated = false;
  int _countdown = 5;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _activate() {
    setState(() => _activated = true);
    _tick();
  }

  void _tick() {
    if (_countdown <= 0) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _activated) {
        setState(() => _countdown--);
        _tick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _activated
          ? AppColors.emergencyCrimson.withAlpha(30)
          : AppColors.midnightNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                  ),
                ],
              ),
              const Spacer(),
              // Central SOS button
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: _activated ? null : _activate,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_activated) ...[
                          Container(
                            width: 220 + _pulseCtrl.value * 40,
                            height: 220 + _pulseCtrl.value * 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.emergencyCrimson
                                  .withAlpha((20 * (1 - _pulseCtrl.value)).round()),
                            ),
                          ),
                          Container(
                            width: 190 + _pulseCtrl.value * 20,
                            height: 190 + _pulseCtrl.value * 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.emergencyCrimson.withAlpha(30),
                            ),
                          ),
                        ],
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.emergencyCrimson,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.emergencyCrimson.withAlpha(120),
                                blurRadius: 32,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: _activated
                                ? Text(
                                    '$_countdown',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 64,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.sos_rounded,
                                          color: Colors.white, size: 44),
                                      const SizedBox(height: 4),
                                      const Text('SOS',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                _activated
                    ? _countdown > 0
                        ? 'Sending SOS in $_countdown seconds…'
                        : '🚨 SOS Activated!'
                    : 'Tap and hold to activate SOS',
                style: AppTextStyles.titleSmall.copyWith(
                    color: _activated
                        ? AppColors.emergencyCrimson
                        : AppColors.brightIvory),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey(_activated)).fadeIn(),
              if (_activated) ...[
                const SizedBox(height: 8),
                Text(
                  'Your live location is being shared with emergency contacts.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
              ],
              const Spacer(),
              // Emergency contacts
              Text('Emergency Contacts',
                  style: AppTextStyles.titleSmall).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 12),
              ...MockData.emergencyContacts.map((contact) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warmCharcoal,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mutedSteel),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded,
                          color: AppColors.saffronAmber, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contact['name'] as String,
                                style: AppTextStyles.label
                                    .copyWith(color: AppColors.brightIvory)),
                            Text(contact['relation'] as String,
                                style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_rounded,
                            color: AppColors.safeGreen, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms);
              }),
              const SizedBox(height: 16),
              if (_activated)
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel_rounded),
                  label: const Text('Cancel SOS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mutedSteel,
                    foregroundColor: AppColors.brightIvory,
                  ),
                  onPressed: () {
                    setState(() {
                      _activated = false;
                      _countdown = 5;
                    });
                  },
                ).animate().fadeIn(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
