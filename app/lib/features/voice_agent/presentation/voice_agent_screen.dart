import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/ai/ai_providers.dart';
import '../../../core/ai/gemini_service.dart';
import '../../discovery/presentation/worker_discovery_screen.dart';

class VoiceAgentScreen extends ConsumerWidget {
  const VoiceAgentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _VoiceTopBar(colorScheme: colorScheme),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MicButton(
                  onTranscript: (text) {
                    ref
                        .read(emergencyInterpretationProvider.notifier)
                        .interpret(text);
                  },
                ),
                const SizedBox(height: 24),
                const _LiveTranscription(),
                const SizedBox(height: 32),
                const _AiFeedbackCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceTopBar extends StatelessWidget {
  final ColorScheme colorScheme;

  const _VoiceTopBar({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                  ),
                ),
                child: const Icon(Icons.bolt, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Neara',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Using GPS · Kolhapur area',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.sos, color: Color(0xFFEF4444)),
            onPressed: () {
              // TODO: Navigate to Safety & SOS screen.
            },
          ),
        ],
      ),
    );
  }
}

class _MicButton extends StatefulWidget {
  final void Function(String transcript) onTranscript;

  const _MicButton({required this.onTranscript});

  @override
  State<_MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<_MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!_isListening) {
      final available = await _speech.initialize();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone not available. Please check permissions.',
              ),
            ),
          );
        }
        return;
      }

      setState(() {
        _isListening = true;
      });

      await _speech.listen(
        onResult: (result) {
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            widget.onTranscript(result.recognizedWords);
          }
        },
      );
    } else {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
    );

    return GestureDetector(
      onTap: _toggleRecording,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 + (_controller.value * 0.05);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LiveTranscription extends StatelessWidget {
  const _LiveTranscription();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: const [
          Text(
            'Tap and describe what\'s wrong',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),
          ),
          SizedBox(height: 12),
          Text(
            '"My car broke down near Kolhapur NH4, engine isn\'t starting"',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _AiFeedbackCard extends ConsumerWidget {
  const _AiFeedbackCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interpretationAsync = ref.watch(emergencyInterpretationProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121826),
              borderRadius: BorderRadius.circular(20),
            ),
            child: interpretationAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Couldn't understand that",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please try speaking again or edit details manually.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
              data: (data) {
                if (data == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Here\'s what I understood",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      _FeedbackRow(
                        label: 'Issue',
                        value: 'Describe what went wrong in your words',
                      ),
                    ],
                  );
                }
                final urgencyLabel = switch (data.urgency) {
                  EmergencyUrgency.high => 'High · Stranded / urgent',
                  EmergencyUrgency.medium => 'Medium',
                  EmergencyUrgency.low => 'Low',
                };
                final serviceLabel = data.serviceCategory.name;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Here\'s what I understood",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FeedbackRow(label: 'Issue', value: data.issueSummary),
                    const SizedBox(height: 8),
                    _FeedbackRow(label: 'Urgency', value: urgencyLabel),
                    const SizedBox(height: 8),
                    _FeedbackRow(label: 'Location', value: data.locationHint),
                    const SizedBox(height: 8),
                    _FeedbackRow(
                      label: 'Suggested service',
                      value: serviceLabel,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final interpretation = ref
                  .read(emergencyInterpretationProvider)
                  .value;
              if (interpretation == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Describe the issue first to find help nearby.',
                    ),
                  ),
                );
                return;
              }

              final currentFilters = ref.read(searchFiltersProvider);
              ref
                  .read(searchFiltersProvider.notifier)
                  .update(
                    currentFilters.copyWith(
                      serviceCategory: interpretation.serviceCategory,
                    ),
                  );

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WorkerDiscoveryScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('Find Nearby Help'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // TODO: Allow editing of interpreted details.
            },
            child: const Text('Edit Details'),
          ),
        ],
      ),
    );
  }
}

class _FeedbackRow extends StatelessWidget {
  final String label;
  final String value;

  const _FeedbackRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}
