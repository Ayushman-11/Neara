import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import '../../../core/ai/ai_providers.dart';
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
        // Interpret the voice input with OpenRouter
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
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.agentGradient),
        child: SafeArea(
          child: Column(
            children: [
              _HomeAppBar(onMenuTap: widget.onOpenDrawer),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.12,
                        ),
                        // App branding and tagline
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.accentGradient,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6366F1,
                                ).withValues(alpha: 0.3),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Neara',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your emergency-ready assistant',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Example questions
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Example questions you can ask:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 8),
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Menu button (opens drawer)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: IconButton(
                icon: const Icon(Icons.menu_rounded, size: 22),
                color: Colors.white,
                onPressed: () {
                  if (onMenuTap != null) {
                    onMenuTap!();
                  } else {
                    final scaffoldState = Scaffold.maybeOf(context);
                    scaffoldState?.openDrawer();
                  }
                },
              ),
            ),
            // App name in center
            const Text(
              'Neara',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            // Profile button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.accentGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                padding: EdgeInsets.zero,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile - Coming soon!')),
                  );
                },
              ),
            ),
          ],
        ),
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
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Describe what you need...',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => widget.onSubmit(),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_hasText) {
                  widget.onSubmit();
                } else {
                  widget.onMicTap();
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.accentGradient,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _hasText ? Icons.send_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
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
  String _currentTranscript = '';
  String _openrouterResult = '';
  bool _isProcessing = false;
  bool _speechEnabled = false;

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
    // Request microphone permission at runtime
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied.')),
          );
        }
        return;
      }
    }

    if (!_speechEnabled) {
      _speechEnabled = await _speech.initialize();
    }

    if (!_speechEnabled) {
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

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _currentTranscript = result.recognizedWords;
          });

          // Process with OpenRouter if we have enough text
          if (result.recognizedWords.length > 10 && !_isProcessing) {
            _processWithOpenRouter(result.recognizedWords);
          }

          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            _processWithOpenRouter(result.recognizedWords);
          }
        }
      },
      listenFor: const Duration(seconds: 60),
    );
  }

  Future<void> _processWithOpenRouter(String transcript) async {
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
              _openrouterResult =
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
              _openrouterResult =
                  'Error: ${error.toString()}\nPlease check your internet connection and API key.';
              _isProcessing = false;
            });
            debugPrint('OpenRouter Error: $error');
            debugPrint('Stack: $stack');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _openrouterResult = 'Error processing: ${e.toString()}';
          _isProcessing = false;
        });
        debugPrint('Process error: $e');
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 40,
            offset: Offset(0, -8),
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
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.accentGradient,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6366F1,
                                ).withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            size: 56,
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
                        if (_openrouterResult.isNotEmpty) ...[
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
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _openrouterResult,
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
                                Color(0xFF6366F1),
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
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.accentGradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _stopListening,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
