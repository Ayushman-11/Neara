import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class NegotiationScreen extends StatefulWidget {
  const NegotiationScreen({super.key});

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  final TextEditingController _messageCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'worker',
      'text': 'Inspection fee: ₹150\nEstimated repair: ₹400\nAdvance: 50%',
      'time': '10:42 AM',
    },
  ];

  void _sendMessage() {
    if (_messageCtrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': _messageCtrl.text.trim(),
        'time': 'Now',
      });
      _messageCtrl.clear();
    });
    // Simulate worker reply
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'worker',
            'text': 'I can reduce the inspection fee to ₹100. The repair cost remains ₹400.',
            'time': 'Now',
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Negotiate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/proposal'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push('/payment'),
            child: Text('Accept',
                style: AppTextStyles.label
                    .copyWith(color: AppColors.saffronAmber)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final msg = _messages[i];
                  final isUser = msg['sender'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.saffronAmber.withAlpha(20)
                            : AppColors.warmCharcoal,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft:
                              Radius.circular(isUser ? 14 : 4),
                          bottomRight:
                              Radius.circular(isUser ? 4 : 14),
                        ),
                        border: Border.all(
                          color: isUser
                              ? AppColors.saffronAmber.withAlpha(60)
                              : AppColors.mutedSteel,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUser ? 'You' : 'Ramesh Sharma',
                            style: AppTextStyles.micro.copyWith(
                                color: isUser
                                    ? AppColors.saffronAmber
                                    : AppColors.liveTeal),
                          ),
                          const SizedBox(height: 4),
                          Text(msg['text'] as String,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.brightIvory)),
                          const SizedBox(height: 4),
                          Text(msg['time'] as String,
                              style: AppTextStyles.micro),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (i * 50).ms);
                },
              ),
            ),
            // Message input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.warmCharcoal,
                border: Border(top: BorderSide(color: AppColors.mutedSteel)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.brightIvory),
                      decoration: const InputDecoration(
                        hintText: 'Send a counter-offer or message…',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.saffronAmber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: AppColors.midnightNavy, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
