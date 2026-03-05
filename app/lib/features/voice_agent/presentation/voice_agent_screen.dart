import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/ai/ai_providers.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../discovery/presentation/worker_discovery_screen.dart';

class VoiceAgentScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOpenDrawer;

  const VoiceAgentScreen({super.key, this.onOpenDrawer});

  @override
  ConsumerState<VoiceAgentScreen> createState() => _VoiceAgentScreenState();
}

class _VoiceAgentScreenState extends ConsumerState<VoiceAgentScreen> {
  final TextEditingController _textController = TextEditingController();
  static const List<String> _exampleQueries = [
    'There is a power outage at my home',
    'Water is leaking in my kitchen',
    'My car broke down near me',
    'Need urgent house cleaning help',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _openVoiceListeningPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VoiceListeningPanel(
        onTranscriptComplete: (transcript) {
          Navigator.of(context).pop();
          _processVoiceInput(transcript);
        },
      ),
    );
  }

  Future<void> _processVoiceInput(String input) async {
    if (input.isEmpty) return;

    // Check if we already have an interpretation (from voice input)
    var interpretation = ref.read(emergencyInterpretationProvider).value;

    if (interpretation == null) {
      // Show loading only if we need to interpret
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Interpret the voice input with Gemini
        await ref
            .read(emergencyInterpretationProvider.notifier)
            .interpret(input);

        // Get the interpretation result
        interpretation = ref.read(emergencyInterpretationProvider).value;

        if (mounted) {
          // Close loading dialog
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
        return;
      }
    }

    // Navigate with the interpretation
    if (mounted && interpretation != null) {
      // Update search filters based on interpretation
      final currentFilters = ref.read(searchFiltersProvider);
      ref
          .read(searchFiltersProvider.notifier)
          .update(
            currentFilters.copyWith(
              serviceCategory: interpretation.serviceCategory,
            ),
          );

      // Navigate to worker discovery screen
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const WorkerDiscoveryScreen()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to process request. Please try again.'),
        ),
      );
    }
  }

  void _submitTextInput() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _textController.clear();
      _processVoiceInput(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _HomeAppBar(onMenuTap: widget.onOpenDrawer),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFF0D9488).withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.bolt_rounded,
                              size: 14,
                              color: Color(0xFF0D9488),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'AI-powered  •  Emergency Ready',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Headline
                      const Text(
                        'What do you\nneed help with?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Describe your situation in words or use your voice.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Example queries label
                      const Text(
                        'Try asking',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final query in _exampleQueries)
                            _ExampleQuestionChip(
                              label: query,
                              onTap: () {
                                _textController.text = query;
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            _BottomInputBar(
              controller: _textController,
              onMicTap: _openVoiceListeningPanel,
              onSubmit: _submitTextInput,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleQuestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ExampleQuestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const _HomeAppBar({this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          // Menu button
          GestureDetector(
            onTap: () {
              if (onMenuTap != null) {
                onMenuTap!();
              } else {
                Scaffold.maybeOf(context)?.openDrawer();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(
                Icons.menu_rounded,
                size: 20,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const Spacer(),
          // Logo + name
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Neara',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Profile button
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile - Coming soon!')),
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Remove old _FloatingAppBar and _QuickActionsGrid as they're no longer needed

class _BottomInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onMicTap;
  final VoidCallback onSubmit;

  const _BottomInputBar({
    required this.controller,
    required this.onMicTap,
    required this.onSubmit,
  });

  @override
  State<_BottomInputBar> createState() => _BottomInputBarState();
}

class _BottomInputBarState extends State<_BottomInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant _BottomInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      _hasText = widget.controller.text.trim().isNotEmpty;
      widget.controller.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    final hasTextNow = widget.controller.text.trim().isNotEmpty;
    if (hasTextNow != _hasText) {
      setState(() {
        _hasText = hasTextNow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: widget.controller,
                style: const TextStyle(color: Color(0xFF111827), fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Describe what you need...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => widget.onSubmit(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (_hasText) {
                widget.onSubmit();
              } else {
                widget.onMicTap();
              }
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _hasText ? Icons.send_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceListeningPanel extends ConsumerStatefulWidget {
  final void Function(String transcript) onTranscriptComplete;

  const _VoiceListeningPanel({required this.onTranscriptComplete});

  @override
  ConsumerState<_VoiceListeningPanel> createState() =>
      _VoiceListeningPanelState();
}

class _VoiceListeningPanelState extends ConsumerState<_VoiceListeningPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final stt.SpeechToText _speech;
  bool _isListening = false;
  String _currentTranscript = '';
  String _geminiResult = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _startListening();
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
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
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() {
      _isListening = true;
    });

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _currentTranscript = result.recognizedWords;
          });

          // Process with Gemini if we have enough text
          if (result.recognizedWords.length > 10 && !_isProcessing) {
            _processWithGemini(result.recognizedWords);
          }

          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            _processWithGemini(result.recognizedWords);
          }
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      onDevice: false,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> _processWithGemini(String transcript) async {
    if (_isProcessing || transcript.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await ref
          .read(emergencyInterpretationProvider.notifier)
          .interpret(transcript);

      final asyncValue = ref.read(emergencyInterpretationProvider);

      asyncValue.when(
        data: (interpretation) {
          if (mounted && interpretation != null) {
            setState(() {
              _geminiResult =
                  'Service: ${interpretation.serviceCategory.name.toUpperCase()}\n'
                  'Location: ${interpretation.locationHint.isNotEmpty ? interpretation.locationHint : "Current location"}\n'
                  'Urgency: ${interpretation.urgency.name.toUpperCase()}\n'
                  'Issue: ${interpretation.issueSummary}';
              _isProcessing = false;
            });
          }
        },
        loading: () {
          // Still processing
        },
        error: (error, stack) {
          if (mounted) {
            setState(() {
              _geminiResult =
                  'Error: ${error.toString()}\nPlease check your internet connection and API key.';
              _isProcessing = false;
            });
            print('Gemini Error: $error');
            print('Stack: $stack');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _geminiResult = 'Error processing: ${e.toString()}';
          _isProcessing = false;
        });
        print('Process error: $e');
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    // For emergency workflow, skip confirmation and proceed immediately
    if (_currentTranscript.isNotEmpty) {
      Navigator.of(context).pop(); // Close the voice panel
      widget.onTranscriptComplete(_currentTranscript);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showConfirmationDialog() {
    final interpretation = ref.read(emergencyInterpretationProvider).value;

    if (interpretation == null) {
      widget.onTranscriptComplete(_currentTranscript);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF0D9488)),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Confirm Details',
                style: TextStyle(color: Color(0xFF111827), fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your request:',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"$_currentTranscript"',
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0D9488).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConfirmationRow(
                      'Service',
                      interpretation.serviceCategory.name.toUpperCase(),
                      Icons.build,
                    ),
                    const SizedBox(height: 8),
                    _buildConfirmationRow(
                      'Location',
                      interpretation.locationHint.isNotEmpty
                          ? interpretation.locationHint
                          : 'Current location',
                      Icons.location_on,
                    ),
                    const SizedBox(height: 8),
                    _buildConfirmationRow(
                      'Urgency',
                      interpretation.urgency.name.toUpperCase(),
                      Icons.priority_high,
                    ),
                    const SizedBox(height: 8),
                    _buildConfirmationRow(
                      'Issue',
                      interpretation.issueSummary,
                      Icons.info_outline,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close bottom sheet
              // Small delay to ensure navigation completes
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) {
                widget.onTranscriptComplete(_currentTranscript);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Find Workers',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0D9488)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF111827), fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final scale = 1 + (_controller.value * 0.1);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0D9488),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0D9488,
                                ).withOpacity(0.25),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          _currentTranscript.isEmpty
                              ? 'Listening...'
                              : _currentTranscript,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                            height: 1.5,
                          ),
                        ),
                        if (_geminiResult.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.accentGradient,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'AI Analysis',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0D9488),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _geminiResult,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (_isProcessing) ...[
                          const SizedBox(height: 16),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0D9488),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Speak now to describe your emergency',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _stopListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                minimumSize: const Size(double.infinity, 52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
