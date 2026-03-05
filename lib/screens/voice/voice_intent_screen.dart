import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../core/ai/openrouter_service.dart';

class VoiceIntentScreen extends StatefulWidget {
  const VoiceIntentScreen({super.key});

  @override
  State<VoiceIntentScreen> createState() => _VoiceIntentScreenState();
}

class _VoiceIntentScreenState extends State<VoiceIntentScreen>
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _isDone = false;
  bool _isProcessing = false;
  late final TextEditingController _transcriptController;
  String _selectedLang = 'English';
  late AnimationController _pulseController;
  final FocusNode _focusNode = FocusNode();
  late stt.SpeechToText _speech;
  bool _speechEnabled = false;
  final OpenRouterService _aiService = OpenRouterService();

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
    _speech = stt.SpeechToText();
    _initSpeech();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transcriptController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startListening() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isDenied) return;
    }

    if (!_speechEnabled) {
      _initSpeech();
    }

    setState(() {
      _isListening = true;
      _isDone = false;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcriptController.text = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            _isDone = true;
          }
        });
      },
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _isDone = true;
    });
  }

  Future<void> _processTranscript() async {
    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final interpretation = await _aiService.interpretEmergency(
        transcript: transcript,
      );

      if (mounted) {
        context.go('/confirm-intent', extra: {
          'transcript': transcript,
          'category': interpretation.serviceCategory,
          'urgency': interpretation.urgency.name.toUpperCase(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Describe your problem'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Mic button with pulse
                  GestureDetector(
                    onTap: _isListening
                        ? _stopListening
                        : (_isProcessing ? null : _startListening),
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
                                  color: AppColors.saffronAmber.withAlpha(
                                      (30 * (1 - _pulseController.value))
                                          .round()),
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
                                        const BoxShadow(
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
                                _isListening
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded,
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
                      color: _isListening
                          ? AppColors.saffronAmber
                          : AppColors.brightIvory,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    constraints: const BoxConstraints(minHeight: 120),
                    decoration: BoxDecoration(
                      color: AppColors.elevatedGraphite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isListening
                            ? AppColors.saffronAmber.withAlpha(120)
                            : AppColors.mutedSteel,
                      ),
                    ),
                    child: TextField(
                      controller: _transcriptController,
                      focusNode: _focusNode,
                      maxLines: null,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.brightIvory,
                        fontStyle: FontStyle.italic,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Start typing or describe your problem...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.mutedFog,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && !_isDone) {
                          setState(() => _isDone = true);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tip
                  Text(
                    'Example: "My kitchen sink is leaking" or "माझ्या घरात पाणी गळत आहे"',
                    style:
                        AppTextStyles.micro.copyWith(color: AppColors.mutedFog),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_isDone ||
                                      _transcriptController.text.isNotEmpty) &&
                                  !_isProcessing
                              ? _processTranscript
                              : null,
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.midnightNavy,
                                  ),
                                )
                              : const Text('Done ✓'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (_isProcessing)
              Container(
                color: Colors.black.withAlpha(50),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.saffronAmber,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
