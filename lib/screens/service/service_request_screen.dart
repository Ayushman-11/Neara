import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/worker.dart';
import '../../core/services/service_request_service.dart';
import '../../core/services/address_service.dart';
import '../../core/di/locator.dart';

class ServiceRequestScreen extends StatefulWidget {
  final dynamic worker;
  const ServiceRequestScreen({super.key, this.worker});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final TextEditingController _problemController = TextEditingController();
  String _urgency = 'normal';
  bool _isSending = false;

  // Addresses
  List<CustomerAddress> _addresses = [];
  CustomerAddress? _selectedAddress;
  bool _loadingAddresses = true;

  Worker? get _worker =>
      widget.worker is Worker ? widget.worker as Worker : null;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final list = await locator<AddressService>().getMyAddresses();
    if (mounted) {
      CustomerAddress? newSelected;
      if (list.isNotEmpty) {
        // If we have a newly added address not in our previous list, select it
        if (_addresses.isNotEmpty && list.length > _addresses.length) {
          try {
            newSelected = list.firstWhere((a) => !_addresses.any((old) => old.id == a.id));
          } catch (_) {}
        }
        
        // Otherwise, try to maintain current selection
        if (newSelected == null && _selectedAddress != null) {
          try {
            newSelected = list.firstWhere((a) => a.id == _selectedAddress!.id);
          } catch (_) {}
        }
        
        // Finally, fallback to default or first
        newSelected ??= list.firstWhere(
          (a) => a.isDefault,
          orElse: () => list.first,
        );
      }
      
      setState(() {
        _addresses = list;
        _selectedAddress = newSelected;
        _loadingAddresses = false;
      });
    }
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final problem = _problemController.text.trim();
    if (problem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your problem')),
      );
      return;
    }
    final worker = _worker;
    if (worker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No worker selected')),
      );
      return;
    }
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or add an address')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final requestId = await locator<ServiceRequestService>().createRequest(
        workerId: worker.id,
        categoryId: worker.categoryId, // now populated from DB
        problemDescription: problem,
        urgency: _urgency,
        addressId: _selectedAddress!.id,
        addressSnapshot: _selectedAddress!.displayText,
        locationLat: _selectedAddress!.locationLat,
        locationLng: _selectedAddress!.locationLng,
      );
      if (mounted) {
        context.go('/request-status', extra: {
          'requestId': requestId,
          'workerName': worker.name,
          'workerInitials': worker.avatarInitials,
          'category': worker.category,
          'problem': problem,
          'urgency': _urgency,
          'address': _selectedAddress?.displayText ?? '',
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _showAddressPicker() async {
    if (_addresses.isEmpty) {
      await context.push('/addresses');
      if (mounted) {
        _loadAddresses();
      }
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.warmCharcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mutedSteel,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select Address', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            ..._addresses.map((addr) => RadioListTile<CustomerAddress>(
                  value: addr,
                  groupValue: _selectedAddress,
                  activeColor: AppColors.saffronAmber,
                  contentPadding: EdgeInsets.zero,
                  title: Text(addr.label,
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.brightIvory)),
                  subtitle: Text(addr.displayText,
                      style: AppTextStyles.bodySmall),
                  onChanged: (v) {
                    setState(() => _selectedAddress = v);
                    Navigator.pop(ctx);
                  },
                )),
            const Divider(height: 20),
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await context.push('/addresses');
                if (mounted) {
                  _loadAddresses();
                }
              },
              icon: const Icon(Icons.add_location_alt_rounded,
                  color: AppColors.saffronAmber),
              label: Text('Add new address',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.saffronAmber)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final worker = _worker;
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Service Request'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worker card
              if (worker != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warmCharcoal,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mutedSteel),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.saffronAmber.withAlpha(30),
                        child: Text(worker.avatarInitials,
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.saffronAmber)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(worker.name,
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.brightIvory)),
                          Text(worker.category,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.liveTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                  color: AppColors.liveTeal,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text('Online',
                                style: AppTextStyles.micro
                                    .copyWith(color: AppColors.liveTeal)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 24),

              // ── Address picker ──────────────────────────────
              Text('Service Location', style: AppTextStyles.label)
                  .animate().fadeIn(delay: 120.ms),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _showAddressPicker,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.elevatedGraphite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedAddress != null
                          ? AppColors.saffronAmber
                          : AppColors.mutedSteel,
                    ),
                  ),
                  child: _loadingAddresses
                      ? const Center(
                          child: SizedBox(
                            height: 16, width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.saffronAmber),
                          ),
                        )
                      : Row(
                          children: [
                            Icon(
                              _selectedAddress != null
                                  ? Icons.location_on_rounded
                                  : Icons.add_location_alt_rounded,
                              color: _selectedAddress != null
                                  ? AppColors.saffronAmber
                                  : AppColors.mutedFog,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _selectedAddress != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(_selectedAddress!.label,
                                            style: AppTextStyles.label.copyWith(
                                                color: AppColors.brightIvory)),
                                        Text(_selectedAddress!.displayText,
                                            style: AppTextStyles.bodySmall,
                                            maxLines: 2),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('No saved address',
                                            style: AppTextStyles.label.copyWith(
                                                color: AppColors.mutedFog)),
                                        Text('Tap to add a new address',
                                            style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.saffronAmber)),
                                      ],
                                    ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.mutedFog, size: 18),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 24),

              // ── Problem description ────────────────────────
              Text('Describe your problem', style: AppTextStyles.label)
                  .animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 10),
              TextField(
                controller: _problemController,
                maxLines: 4,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.brightIvory),
                decoration: const InputDecoration(
                  hintText: 'e.g. Water leaking from kitchen sink for 2 days...',
                  alignLabelWithHint: true,
                ),
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 24),

              // ── Urgency selector ───────────────────────────
              Text('Urgency', style: AppTextStyles.label)
                  .animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 10),
              Row(
                children: [
                  _UrgencyChip(
                    label: 'Normal',
                    icon: Icons.schedule_rounded,
                    color: AppColors.liveTeal,
                    selected: _urgency == 'normal',
                    onTap: () => setState(() => _urgency = 'normal'),
                  ),
                  const SizedBox(width: 10),
                  _UrgencyChip(
                    label: 'Urgent',
                    icon: Icons.flash_on_rounded,
                    color: AppColors.saffronAmber,
                    selected: _urgency == 'urgent',
                    onTap: () => setState(() => _urgency = 'urgent'),
                  ),
                  const SizedBox(width: 10),
                  _UrgencyChip(
                    label: 'Emergency',
                    icon: Icons.sos_rounded,
                    color: AppColors.emergencyCrimson,
                    selected: _urgency == 'emergency',
                    onTap: () => setState(() => _urgency = 'emergency'),
                  ),
                ],
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 24),

              // Privacy notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.liveTeal.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.liveTeal.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_rounded,
                        color: AppColors.liveTeal, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your address and contact are shared with the worker only after payment.',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.liveTeal),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSending ? null : _submitRequest,
                child: _isSending
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.midnightNavy))
                    : Text(worker != null
                        ? 'Send Request to ${worker.name.split(' ').first}'
                        : 'Send Request'),
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _UrgencyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _UrgencyChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withAlpha(30) : AppColors.elevatedGraphite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : AppColors.mutedSteel,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? color : AppColors.mutedFog, size: 18),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTextStyles.micro.copyWith(
                    color: selected ? color : AppColors.mutedFog,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
