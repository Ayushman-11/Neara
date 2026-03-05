import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/address_service.dart';
import '../../core/di/locator.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _nameFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _pincodeFocus = FocusNode();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _nameFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _pincodeFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await locator<AuthService>().saveProfile(
        _nameController.text.trim(),
        city: _cityController.text.trim(),
      );

      if (_addressController.text.trim().isNotEmpty) {
        await locator<AddressService>().addAddress(
          label: 'Home',
          addressLine: _addressController.text.trim(),
          city: _cityController.text.trim(),
          pincode: _pincodeController.text.trim(),
          isDefault: true,
        );
      }

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: AppColors.emergencyCrimson,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = _nameController.text.isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Complete Profile', style: AppTextStyles.label
            .copyWith(color: AppColors.brightIvory)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar preview
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.saffronAmber.withAlpha(25),
                        child: Text(
                          initial,
                          style: AppTextStyles.titleLarge
                              .copyWith(color: AppColors.saffronAmber),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.saffronAmber,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.midnightNavy, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: AppColors.midnightNavy, size: 14),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).scale(
                    begin: const Offset(0.85, 0.85)),
                const SizedBox(height: 8),
                Center(
                  child: Text('This is how workers see you',
                      style: AppTextStyles.micro),
                ),
                const SizedBox(height: 32),

                // Name field
                Text('Full Name *', style: AppTextStyles.label)
                    .animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.brightIvory),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Priya Sharma',
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        color: AppColors.mutedFog, size: 20),
                  ),
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _addressFocus.requestFocus(),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Please enter your full name (min 2 characters)';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 20),

                // Address fields
                Text('Street / Flat / Building *', style: AppTextStyles.label)
                    .animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  focusNode: _addressFocus,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.brightIvory),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Flat 4B, Silver Oaks',
                    prefixIcon: Icon(Icons.location_on_rounded,
                        color: AppColors.mutedFog, size: 20),
                  ),
                  onFieldSubmitted: (_) => _cityFocus.requestFocus(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('City *', style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cityController,
                            focusNode: _cityFocus,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.brightIvory),
                            decoration: const InputDecoration(
                              hintText: 'e.g. Pune',
                            ),
                            onFieldSubmitted: (_) => _pincodeFocus.requestFocus(),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pincode *', style: AppTextStyles.label),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _pincodeController,
                            focusNode: _pincodeFocus,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textInputAction: TextInputAction.done,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.brightIvory),
                            decoration: const InputDecoration(
                              hintText: 'e.g. 411001',
                              counterText: '',
                            ),
                            onFieldSubmitted: (_) => _save(),
                            validator: (v) {
                              if (v == null || v.trim().length != 6) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 350.ms),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.midnightNavy),
                        )
                      : const Text('Save & Continue →'),
                ).animate().fadeIn(delay: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
