import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';
import 'package:worker_app/core/theme/app_theme.dart';
import 'package:worker_app/features/onboarding/presentation/category_selection_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_app/features/dashboard/presentation/worker_state.dart';
import 'package:worker_app/features/support/presentation/safety_screen.dart';
import 'package:worker_app/features/support/presentation/dispute_screen.dart';
import 'package:worker_app/features/auth/presentation/auth_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerState = ref.watch(workerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context, ref, workerState),
          const SizedBox(height: 32),
          _buildSectionHeader('SERVICE SETTINGS'),
          const SizedBox(height: 16),
          _buildMenuTile(
            LucideIcons.mapPin,
            'Service Radius',
            'Currently ${workerState.serviceRadius.toInt()} km',
            onTap: () =>
                _showRadiusDialog(context, ref, workerState.serviceRadius),
            trailing: _buildEditLabel(),
          ),
          _buildMenuTile(
            LucideIcons.wrench,
            'Categories',
            workerState.selectedCategories.join(', '),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CategorySelectionScreen(isEditing: true),
                ),
              );
            },
            trailing: const Icon(
              LucideIcons.chevronRight,
              color: AppColors.mutedFog,
              size: 20,
            ),
          ),
          _buildMenuTile(
            LucideIcons.indianRupee,
            'Inspection Fee',
            '₹${workerState.baseInspectionFee.toInt()} Base Fee',
            onTap: () =>
                _showFeeDialog(context, ref, workerState.baseInspectionFee),
            trailing: _buildEditLabel(),
          ),
          _buildMenuTile(
            LucideIcons.clock,
            'Working Hours',
            workerState.workingHours,
            onTap: () =>
                _showHoursDialog(context, ref, workerState.workingHours),
            trailing: _buildEditLabel(),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('ACCOUNT & SECURITY'),
          const SizedBox(height: 16),
          _buildMenuTile(
            LucideIcons.landmark,
            'Bank Details',
            '${workerState.bankName} • ${workerState.accountNumber}',
            onTap: () => _showBankDialog(context, ref, workerState),
            trailing: const Icon(
              LucideIcons.checkCircle2,
              color: AppColors.safeGreen,
              size: 18,
            ),
          ),
          _buildMenuTile(
            LucideIcons.shieldCheck,
            'KYC Status',
            'Verified Provider',
            onTap: () => _showKYCDialog(context, workerState),
            trailing: const Icon(
              LucideIcons.checkCircle2,
              color: AppColors.safeGreen,
              size: 18,
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('PREFERENCES'),
          const SizedBox(height: 16),
          _buildMenuTile(
            LucideIcons.bell,
            'Push Notifications',
            workerState.notificationsEnabled ? 'Enabled' : 'Disabled',
            trailing: Switch(
              value: workerState.notificationsEnabled,
              onChanged: (val) =>
                  ref.read(workerProvider.notifier).toggleNotifications(val),
              activeColor: AppColors.liveTeal,
            ),
          ),
          _buildMenuTile(
            LucideIcons.languages,
            'Language',
            workerState.language,
            onTap: () =>
                _showLanguageDialog(context, ref, workerState.language),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('SUPPORT & LEGAL'),
          const SizedBox(height: 16),
          _buildMenuTile(
            LucideIcons.helpCircle,
            'Help Center',
            'FAQs & Live Chat',
            onTap: () => _showComingSoon(context, 'Help Center'),
          ),
          _buildMenuTile(
            LucideIcons.fileText,
            'Terms of Service',
            null,
            onTap: () => _showComingSoon(context, 'Terms of Service'),
          ),
          _buildMenuTile(
            LucideIcons.shieldAlert,
            'Privacy Policy',
            null,
            onTap: () => _showComingSoon(context, 'Privacy Policy'),
          ),
          _buildMenuTile(
            LucideIcons.shieldAlert,
            'Safety & Risks',
            'Protocols & Guidelines',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SafetyScreen()),
              );
            },
          ),
          _buildMenuTile(
            LucideIcons.messageSquare,
            'Resolve Disputes',
            'Pending cases',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DisputeResponseScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          Center(
            child: TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              child: Text(
                'LOGOUT',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.emergencyCrimson,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'v1.0.0-PRO • Neara Worker App',
              style: AppTextStyles.chipLabel.copyWith(
                color: AppColors.mutedFog,
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildEditLabel() {
    return Text(
      'EDIT',
      style: AppTextStyles.chipLabel.copyWith(
        color: AppColors.saffronAmber,
        fontSize: 10,
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    WorkerState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.warmCharcoal,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mutedSteel),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.elevatedGraphite,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.user,
                  size: 32,
                  color: AppColors.mutedFog,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.liveTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.check,
                    size: 12,
                    color: AppColors.midnightNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(state.name, style: AppTextStyles.titleLarge),
                    ),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.edit2,
                        size: 16,
                        color: AppColors.mutedFog,
                      ),
                      onPressed: () =>
                          _showNameDialog(context, ref, state.name),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.star,
                      color: AppColors.saffronAmber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${state.rating}',
                      style: AppTextStyles.monoSmall.copyWith(
                        color: AppColors.brightIvory,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${state.completedJobs} Jobs',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.chipLabel.copyWith(
        color: AppColors.mutedFog,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    String? subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.elevatedGraphite.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.midnightNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.saffronAmber, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.brightIvory,
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // --- Dialogs ---

  void _showNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmCharcoal,
        title: Text('Edit Name', style: AppTextStyles.titleMedium),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Full Name'),
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(workerProvider.notifier).updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showRadiusDialog(
    BuildContext context,
    WidgetRef ref,
    double currentRadius,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        double radius = currentRadius;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.warmCharcoal,
              title: Text(
                'Adjust Service Radius',
                style: AppTextStyles.titleMedium,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${radius.toInt()} km', style: AppTextStyles.heroAmount),
                  Slider(
                    value: radius,
                    min: 1,
                    max: 50,
                    activeColor: AppColors.saffronAmber,
                    onChanged: (value) => setDialogState(() => radius = value),
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
                    ref.read(workerProvider.notifier).updateRadius(radius);
                    Navigator.pop(context);
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFeeDialog(BuildContext context, WidgetRef ref, double currentFee) {
    final controller = TextEditingController(
      text: currentFee.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmCharcoal,
        title: Text('Default Inspection Fee', style: AppTextStyles.titleMedium),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '₹ ', hintText: '250'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final fee = double.tryParse(controller.text) ?? currentFee;
              ref.read(workerProvider.notifier).updateFees(fee);
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showHoursDialog(
    BuildContext context,
    WidgetRef ref,
    String currentHours,
  ) {
    final controller = TextEditingController(text: currentHours);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmCharcoal,
        title: Text('Service Hours', style: AppTextStyles.titleMedium),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. 9 AM - 6 PM'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(workerProvider.notifier)
                  .updateWorkingHours(controller.text);
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showBankDialog(BuildContext context, WidgetRef ref, WorkerState state) {
    final bankController = TextEditingController(text: state.bankName);
    final accController = TextEditingController(text: state.accountNumber);
    final ifscController = TextEditingController(text: state.ifscCode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmCharcoal,
        title: Text('Payout Details', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bankController,
              decoration: const InputDecoration(hintText: 'Bank Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: accController,
              decoration: const InputDecoration(hintText: 'Account Number'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ifscController,
              decoration: const InputDecoration(hintText: 'IFSC Code'),
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
              ref
                  .read(workerProvider.notifier)
                  .updateBankDetails(
                    bankController.text,
                    accController.text,
                    ifscController.text,
                  );
              Navigator.pop(context);
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  void _showKYCDialog(BuildContext context, WorkerState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmCharcoal,
        title: Row(
          children: [
            const Icon(LucideIcons.shieldCheck, color: AppColors.safeGreen),
            const SizedBox(width: 12),
            Text('Verification Status', style: AppTextStyles.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKYCRow('Identity', 'Government ID Verified'),
            _buildKYCRow('Skill Test', 'Certified Provider'),
            _buildKYCRow('Background', 'Clear Checklist'),
            const Divider(color: AppColors.mutedSteel, height: 24),
            Text(
              'Verified on ${state.verifiedDate}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildKYCRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: AppTextStyles.label.copyWith(color: AppColors.safeGreen),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLang,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmCharcoal,
        title: Text('App Language', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Hindi', 'Marathi', 'Kannada'].map((lang) {
            return ListTile(
              title: Text(lang, style: AppTextStyles.bodyLarge),
              trailing: currentLang == lang
                  ? const Icon(LucideIcons.check, color: AppColors.liveTeal)
                  : null,
              onTap: () {
                ref.read(workerProvider.notifier).updateLanguage(lang);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!', style: AppTextStyles.bodySmall),
        backgroundColor: AppColors.midnightNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
