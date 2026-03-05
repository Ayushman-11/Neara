import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class VoiceIntentScreen extends StatefulWidget {
  const VoiceIntentScreen({super.key});

  @override
  State<VoiceIntentScreen> createState() => _VoiceIntentScreenState();
}

class _VoiceIntentScreenState extends State<VoiceIntentScreen>
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _isDone = false;
  String _transcript = '';
  String _selectedLang = 'English';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _isDone = false;
      _transcript = '';
    });
    // Simulate transcript appearing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _transcript = 'My kitchen sink is');
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _transcript = 'My kitchen sink is leaking badly.');
    });
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _isListening = false;
          _isDone = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Describe your problem'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Mic button with pulse
              GestureDetector(
                onTap: _isListening ? null : _startListening,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isListening) ...[
                          Container(
                            width: 120 + _pulseController.value * 30,
                            height: 120 + _pulseController.value * 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.saffronAmber
                                  .withAlpha((30 * (1 - _pulseController.value)).round()),
                            ),
                          ),
                          Container(
                            width: 110 + _pulseController.value * 15,
                            height: 110 + _pulseController.value * 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.saffronAmber.withAlpha(50),
                            ),
                          ),
                        ],
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening
                                ? AppColors.saffronAmber
                                : AppColors.elevatedGraphite,
                            boxShadow: _isListening
                                ? [
                                    BoxShadow(
                                      color: AppColors.saffronGlow,
                                      blurRadius: 24,
                                      spreadRadius: 8,
                                    )
                                  ]
                                : null,
                            border: Border.all(
                              color: _isListening
                                  ? AppColors.saffronAmber
                                  : AppColors.mutedSteel,
                            ),
                          ),
                          child: Icon(
                            _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                            color: _isListening
                                ? AppColors.midnightNavy
                                : AppColors.saffronAmber,
                            size: 44,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isListening
                    ? 'Listening…'
                    : _isDone
                        ? 'Got it!'
                        : 'Tap to speak',
                style: AppTextStyles.titleSmall.copyWith(
                  color: _isListening ? AppColors.saffronAmber : AppColors.brightIvory,
                ),
              ).animate(key: ValueKey(_isListening)).fadeIn(),
              const SizedBox(height: 32),
              // Language chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['English', 'हिंदी', 'मराठी'].map((lang) {
                  final isSelected = _selectedLang == lang;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLang = lang),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.saffronAmber
                            : AppColors.elevatedGraphite,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.saffronAmber
                              : AppColors.mutedSteel,
                        ),
                      ),
                      child: Text(
                        lang,
                        style: AppTextStyles.label.copyWith(
                          color: isSelected
                              ? AppColors.midnightNavy
                              : AppColors.softMoonlight,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Transcript box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(minHeight: 100),
                decoration: BoxDecoration(
                  color: AppColors.elevatedGraphite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isListening
                        ? AppColors.saffronAmber.withAlpha(120)
                        : AppColors.mutedSteel,
                  ),
                ),
                child: Text(
                  _transcript.isEmpty
                      ? 'Start speaking — we\'ll transcribe what you say'
                      : '"$_transcript"',
                  style: _transcript.isEmpty
                      ? AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.mutedFog,
                          fontStyle: FontStyle.italic)
                      : AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.brightIvory,
                          fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 16),
              // Tip
              Text(
                'Example: "My kitchen sink is leaking" or "माझ्या घरात पाणी गळत आहे"',
                style: AppTextStyles.micro.copyWith(color: AppColors.mutedFog),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDone || _transcript.isNotEmpty
                          ? () => context.push('/confirm-intent')
                          : null,
                      child: const Text('Done ✓'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
