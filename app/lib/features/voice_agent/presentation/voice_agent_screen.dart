import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/ai/ai_providers.dart';
import '../../../core/ai/gemini_service.dart';
import '../../discovery/presentation/worker_discovery_screen.dart';

class VoiceAgentScreen extends ConsumerStatefulWidget {
  const VoiceAgentScreen({super.key});

  @override
  ConsumerState<VoiceAgentScreen> createState() => _VoiceAgentScreenState();
}

class _VoiceAgentScreenState extends ConsumerState<VoiceAgentScreen> {
  final TextEditingController _textController = TextEditingController();

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
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const _FloatingAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15,
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFFEC4899)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bolt,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Describe your emergency',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Use voice or text below to find help',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _QuickActionsGrid(
                          onBrowseServices: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const WorkerDiscoveryScreen(),
                              ),
                            );
                          },
                        ),
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

class _FloatingAppBar extends StatelessWidget {
  const _FloatingAppBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937).withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFFEC4899)],
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Hi, Bayzid',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Control tasks effortlessly',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFFE5E7EB),
                size: 22,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onBrowseServices;

  const _QuickActionsGrid({required this.onBrowseServices});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _QuickActionTile(
              width: itemWidth,
              icon: Icons.flash_on,
              title: 'Emergency help',
              subtitle: 'Fast, voice-first help near you',
              onTap: () {
                // Primary action is already the hero mic; keep this as hint.
              },
            ),
            _QuickActionTile(
              width: itemWidth,
              icon: Icons.list_alt,
              title: 'Browse services',
              subtitle: 'Plumbers, electricians, maids & more',
              onTap: onBrowseServices,
            ),
            _QuickActionTile(
              width: itemWidth,
              icon: Icons.assignment,
              title: 'My\nrequests',
              subtitle: 'Track past and active jobs',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Requests tracking will come later.'),
                  ),
                );
              },
            ),
            _QuickActionTile(
              width: itemWidth,
              icon: Icons.shield,
              title: 'Safety & \nSOS',
              subtitle: 'Share live tracking, SOS options',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Safety & SOS screen is not wired yet.'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 95,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            border: Border.all(
              color: const Color(0xFF334155).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFFEC4899)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF9CA3AF),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onMicTap;
  final VoidCallback onSubmit;

  const _BottomInputBar({
    required this.controller,
    required this.onMicTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Describe what you need...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: onMicTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFFEC4899)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                onSubmitted: (_) => onSubmit(),
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
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF4F46E5)),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Confirm Details',
                style: TextStyle(color: Colors.white, fontSize: 18),
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
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"$_currentTranscript"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
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
              style: TextStyle(color: Color(0xFF9CA3AF)),
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
              backgroundColor: const Color(0xFF4F46E5),
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
        Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
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
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F2937), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
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
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF4F46E5),
                                Color(0xFFEC4899),
                                Color(0xFFFBBF24),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withOpacity(0.6),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: const Color(0xFFEC4899).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mic,
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
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        if (_geminiResult.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F2937).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF4F46E5).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                      color: Color(0xFF4F46E5),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'AI Analysis',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4F46E5),
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
                                    color: Color(0xFF9CA3AF),
                                    height: 1.4,
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
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF4F46E5),
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
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
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
                backgroundColor: const Color(0xFF1F2937),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
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
