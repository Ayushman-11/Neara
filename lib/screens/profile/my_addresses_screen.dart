import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/address_service.dart';
import '../../core/di/locator.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  List<CustomerAddress> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _loading = true);
    final list = await locator<AddressService>().getMyAddresses();
    if (mounted) setState(() { _addresses = list; _loading = false; });
  }

  Future<void> _delete(String id) async {
    await locator<AddressService>().deleteAddress(id);
    await _loadAddresses();
  }

  Future<void> _setDefault(String id) async {
    await locator<AddressService>().setDefault(id);
    await _loadAddresses();
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.warmCharcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddAddressSheet(onSaved: _loadAddresses),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('My Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add address',
            onPressed: _showAddSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.saffronAmber))
            : _addresses.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _addresses.length,
                    itemBuilder: (_, i) =>
                        _AddressTile(
                          address: _addresses[i],
                          onDelete: () => _delete(_addresses[i].id),
                          onSetDefault: () => _setDefault(_addresses[i].id),
                        ).animate().fadeIn(delay: (i * 60).ms),
                  ),
      ),
      floatingActionButton: _addresses.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showAddSheet,
              backgroundColor: AppColors.saffronAmber,
              icon: const Icon(Icons.add_location_alt_rounded,
                  color: AppColors.midnightNavy),
              label: Text('Add Address',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.midnightNavy)),
            )
          : null,
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.elevatedGraphite,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home_work_rounded,
                size: 48, color: AppColors.saffronAmber),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 20),
          Text('No saved addresses', style: AppTextStyles.titleSmall)
              .animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 8),
          Text('Add your home, work or any frequent address.',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center)
              .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _showAddSheet,
            icon: const Icon(Icons.add_location_alt_rounded),
            label: const Text('Add Address'),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final CustomerAddress address;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressTile(
      {required this.address,
      required this.onDelete,
      required this.onSetDefault});

  IconData get _icon {
    switch (address.label.toLowerCase()) {
      case 'work':
        return Icons.work_rounded;
      case 'other':
        return Icons.location_on_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.warmCharcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: address.isDefault
              ? AppColors.saffronAmber
              : AppColors.mutedSteel,
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: address.isDefault
                ? AppColors.saffronAmber.withAlpha(25)
                : AppColors.elevatedGraphite,
            shape: BoxShape.circle,
          ),
          child: Icon(_icon,
              color: address.isDefault
                  ? AppColors.saffronAmber
                  : AppColors.mutedFog,
              size: 20),
        ),
        title: Row(
          children: [
            Text(address.label,
                style: AppTextStyles.label
                    .copyWith(color: AppColors.brightIvory)),
            if (address.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.saffronAmber.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Default',
                    style: AppTextStyles.micro
                        .copyWith(color: AppColors.saffronAmber)),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(address.displayText,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.softMoonlight)),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColors.mutedFog, size: 20),
          color: AppColors.elevatedGraphite,
          onSelected: (v) {
            if (v == 'default') onSetDefault();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            if (!address.isDefault)
              const PopupMenuItem(
                value: 'default',
                child: Text('Set as default'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete',
                  style: TextStyle(color: AppColors.emergencyCrimson)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAddressSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddAddressSheet({required this.onSaved});

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  String _label = 'Home';
  bool _isDefault = false;
  bool _saving = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter address')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await locator<AddressService>().addAddress(
        label: _label,
        addressLine: _addressController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        isDefault: _isDefault,
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedSteel,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Add New Address', style: AppTextStyles.titleSmall),
          const SizedBox(height: 20),

          // Label chips
          Text('Label', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            children: ['Home', 'Work', 'Other'].map((l) {
              final sel = _label == l;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(l),
                  selected: sel,
                  onSelected: (_) => setState(() => _label = l),
                  selectedColor: AppColors.saffronAmber,
                  backgroundColor: AppColors.elevatedGraphite,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: sel ? AppColors.midnightNavy : AppColors.mutedFog,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color:
                        sel ? AppColors.saffronAmber : AppColors.mutedSteel,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          Text('Street / Flat / Building', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.brightIvory),
            maxLines: 2,
            decoration: const InputDecoration(
                hintText: 'e.g. Flat 4B, Silver Oaks, Koregaon Park'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('City', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cityController,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.brightIvory),
                      decoration:
                          const InputDecoration(hintText: 'Pune'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pincode', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.brightIvory),
                      decoration: const InputDecoration(
                          hintText: '411001', counterText: ''),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Switch(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                activeColor: AppColors.saffronAmber,
              ),
              const SizedBox(width: 8),
              Text('Set as default address', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.midnightNavy))
                : const Text('Save Address'),
          ),
        ],
      ),
    );
  }
}
