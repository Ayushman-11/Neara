import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final Set<String> _selectedTags = {};
  final List<String> _tags = [
    '⚡ Fast',
    '🛠 Expert Skill',
    '✅ Clean Work',
    '💬 Communicative',
    '📋 Transparent Pricing',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Rate the Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Success header
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.safeGreen.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.safeGreen, size: 40),
              ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 500.ms,
                  curve: Curves.elasticOut),
              const SizedBox(height: 12),
              Text('Payment Successful! 🎉',
                  style: AppTextStyles.titleMedium).animate().fadeIn(delay: 300.ms),
              Text('₹400 paid to Ramesh Sharma',
                  style: AppTextStyles.bodyMedium).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warmCharcoal,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mutedSteel),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.elevatedGraphite,
                      child: Text('RS',
                          style: TextStyle(
                              color: AppColors.saffronAmber,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 8),
                    Text('How was Ramesh\'s service?',
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 20),
                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () => setState(() => _rating = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              i < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: i < _rating
                                  ? AppColors.saffronAmber
                                  : AppColors.mutedSteel,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                    if (_rating > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent!'][_rating],
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.saffronAmber),
                        ),
                      ).animate().fadeIn(),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              // Tag chips
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) _selectedTags.remove(tag);
                      else _selectedTags.add(tag);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.saffronAmber
                            : AppColors.elevatedGraphite,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? AppColors.saffronAmber
                              : AppColors.mutedSteel,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: AppTextStyles.label.copyWith(
                          color: selected
                              ? AppColors.midnightNavy
                              : AppColors.softMoonlight,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brightIvory),
                decoration: const InputDecoration(
                  hintText: 'Add a comment (optional)…',
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/booking-summary'),
                child: const Text('Submit Review'),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text('Skip for now',
                    style: AppTextStyles.label.copyWith(color: AppColors.mutedFog)),
              ).animate().fadeIn(delay: 550.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
