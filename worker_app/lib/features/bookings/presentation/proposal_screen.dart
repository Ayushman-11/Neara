import 'package:flutter/material.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';
import 'package:worker_app/features/bookings/presentation/negotiation_screen.dart';

class ProposalScreen extends ConsumerStatefulWidget {
  final ServiceRequest request;

  const ProposalScreen({super.key, required this.request});

  @override
  ConsumerState<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends ConsumerState<ProposalScreen> {
  late final TextEditingController _inspectionController;
  late final TextEditingController _laborController;
  final TextEditingController _notesController = TextEditingController();

  double _inspectionFee = 0;
  double _estimatedCost = 0;
  double _advancePercentage = 20;

  @override
  void initState() {
    super.initState();
    final baseFee = ref.read(workerProvider).baseInspectionFee;
    _inspectionFee = baseFee;
    _inspectionController = TextEditingController(
      text: baseFee.toInt().toString(),
    );
    _laborController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _inspectionController.dispose();
    _laborController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(title: const Text('Create Proposal')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRequestHeader(),
              const SizedBox(height: 32),
              _buildPriceSection(),
              const SizedBox(height: 32),
              _buildAdvanceSection(),
              const SizedBox(height: 32),
              _buildNotesSection(),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => _handleSendProposal(context),
                child: const Text('Send Proposal'),
              ),
              const SizedBox(height: 40), // Bottom breathing room
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('PROPOSAL FOR', style: AppTextStyles.chipLabel),
        const SizedBox(height: 8),
        Text(widget.request.title, style: AppTextStyles.titleLarge),
        Text(
          'Customer: Amit Kumar',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedFog),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('PRICING TERMS', style: AppTextStyles.chipLabel),
        const SizedBox(height: 16),
        _buildPriceField(
          'Inspection Fee',
          _inspectionController,
          (val) => setState(() => _inspectionFee = val),
          'Mandatory visit charge',
        ),
        const SizedBox(height: 20),
        _buildPriceField(
          'Estimated Labor',
          _laborController,
          (val) => setState(() => _estimatedCost = val),
          'Approx. based on description',
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.elevatedGraphite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mutedSteel, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Projected Total', style: AppTextStyles.titleSmall),
              Text(
                '₹${(_inspectionFee + _estimatedCost).toInt()}',
                style: AppTextStyles.monoLarge.copyWith(
                  color: AppColors.saffronAmber,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField(
    String label,
    TextEditingController controller,
    Function(double) onChanged,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTextStyles.monoMedium.copyWith(fontSize: 16),
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (val) {
            onChanged(double.tryParse(val) ?? 0);
          },
        ),
      ],
    );
  }

  Widget _buildAdvanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ADVANCE PAYMENT', style: AppTextStyles.chipLabel),
            Text(
              '${_advancePercentage.toInt()}%',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.saffronAmber,
              ),
            ),
          ],
        ),
        Slider(
          value: _advancePercentage,
          min: 0,
          max: 75,
          divisions: 15,
          activeColor: AppColors.saffronAmber,
          onChanged: (val) => setState(() => _advancePercentage = val),
        ),
        Text(
          'Advance of ₹${((_inspectionFee + _estimatedCost) * (_advancePercentage / 100)).toInt()} will be held in Escrow.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedFog),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('ADDITIONAL NOTES', style: AppTextStyles.chipLabel),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          style: AppTextStyles.bodyMedium,
          decoration: const InputDecoration(
            hintText: 'e.g. Parts cost extra...',
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  void _handleSendProposal(BuildContext context) {
    FocusScope.of(context).unfocus();

    // Update state first
    ref
        .read(workerProvider.notifier)
        .startNegotiation(widget.request, _inspectionFee + _estimatedCost);

    // Simple push to allow backtracking
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NegotiationScreen()),
    );
  }
}
