import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';
import 'package:worker_app/features/bookings/presentation/escrow_waiting_screen.dart';

class NegotiationScreen extends ConsumerStatefulWidget {
  const NegotiationScreen({super.key});

  @override
  ConsumerState<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends ConsumerState<NegotiationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text':
          'Hi, I need help with a leaking tap in my kitchen. Can you come today?',
      'time': '4:15 PM',
    },
    {
      'isMe': true,
      'text':
          'Yes, I can be there in 30 minutes. The base inspection fee is ₹250.',
      'time': '4:16 PM',
    },
    {
      'isMe': false,
      'text': 'That works. How much for the actual repair?',
      'time': '4:17 PM',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workerState = ref.watch(workerProvider);
    final activeJob = workerState.activeJob;

    if (activeJob == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activeJob.customerName, style: AppTextStyles.titleSmall),
            Text(activeJob.serviceType, style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.phone, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: Material(
        // Wrap in Material for robustness
        color: Colors.transparent,
        child: Column(
          children: [
            _buildNegotiationSummary(activeJob),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(
                    msg['text'],
                    msg['isMe'],
                    msg['time'] ?? 'Now',
                  );
                },
              ),
            ),
            _buildInputArea(context, ref, activeJob),
          ],
        ),
      ),
    );
  }

  Widget _buildNegotiationSummary(ActiveJob job) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.warmCharcoal,
        border: Border(
          bottom: BorderSide(color: AppColors.mutedSteel, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.midnightNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.users,
              color: AppColors.saffronAmber,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURRENT OFFER', style: AppTextStyles.chipLabel),
                Text(
                  '₹${job.agreedAmount.toInt()}',
                  style: AppTextStyles.monoMedium.copyWith(
                    color: AppColors.saffronAmber,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleAccept(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.liveTeal,
              foregroundColor: AppColors.midnightNavy,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(0, 40),
            ),
            child: const Text('ACCEPT'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.saffronAmber.withOpacity(0.12)
              : AppColors.elevatedGraphite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: isMe
              ? Border.all(color: AppColors.saffronAmber.withOpacity(0.3))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? AppColors.saffronAmber : AppColors.brightIvory,
              ),
            ),
            const SizedBox(height: 4),
            Text(time, style: AppTextStyles.micro.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, WidgetRef ref, ActiveJob job) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.warmCharcoal,
        border: Border(
          top: BorderSide(color: AppColors.mutedSteel, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, color: AppColors.mutedFog),
            onPressed: () =>
                _showCounterOfferDialog(context, ref, job.agreedAmount),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.midnightNavy,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.saffronAmber,
            radius: 20,
            child: IconButton(
              icon: const Icon(
                LucideIcons.send,
                color: AppColors.midnightNavy,
                size: 18,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'isMe': true,
          'text': _messageController.text.trim(),
          'time': 'Now',
        });
        _messageController.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showCounterOfferDialog(
    BuildContext context,
    WidgetRef ref,
    double currentAmount,
  ) {
    final controller = TextEditingController(
      text: currentAmount.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmCharcoal,
        title: Text('Counter Offer', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Suggest a new total amount for this service.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: 'Enter amount',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? currentAmount;
              ref.read(workerProvider.notifier).updateAgreedAmount(amount);
              setState(() {
                _messages.add({
                  'isMe': true,
                  'text':
                      'I am suggesting a revised quote of ₹${amount.toInt()}.',
                  'time': 'Now',
                });
              });
              Navigator.pop(context);
            },
            child: const Text('SEND OFFER'),
          ),
        ],
      ),
    );
  }

  void _handleAccept(BuildContext context, WidgetRef ref) {
    ref.read(workerProvider.notifier).updateJobStatus(JobStatus.waitingEscrow);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EscrowWaitingScreen()),
    );
  }
}
