import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/di/locator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (mounted) setState(() => _profile = data);
    } catch (e) {
      debugPrint('[ProfileScreen] Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await locator<AuthService>().signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final phone = user?.phone ?? '';
    final name = (_profile?['full_name'] as String?) ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.saffronAmber))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar + info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.warmCharcoal,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.mutedSteel),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.saffronAmber.withAlpha(30),
                                child: Text(initial,
                                    style: AppTextStyles.titleLarge
                                        .copyWith(color: AppColors.saffronAmber)),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.saffronAmber,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.warmCharcoal, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      size: 12, color: AppColors.midnightNavy),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(name, style: AppTextStyles.titleSmall),
                          if (phone.isNotEmpty)
                            Text(phone, style: AppTextStyles.bodySmall),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.safeGreen.withAlpha(20),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: AppColors.safeGreen.withAlpha(80)),
                            ),
                            child: Text('✓ Verified',
                                style: AppTextStyles.chipLabel
                                    .copyWith(color: AppColors.safeGreen)),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 20),
                    // Menu items
                    ...[
                      {
                        'icon': Icons.person_rounded,
                        'label': 'Edit Profile',
                        'onTap': () {}
                      },
                      {
                        'icon': Icons.location_on_rounded,
                        'label': 'My Addresses',
                        'onTap': () => context.push('/addresses')
                      },
                      {
                        'icon': Icons.contacts_rounded,
                        'label': 'Emergency Contacts',
                        'onTap': () => context.push('/emergency-contacts')
                      },
                      {
                        'icon': Icons.account_balance_wallet_rounded,
                        'label': 'Wallet',
                        'onTap': () => context.go('/wallet')
                      },
                      {
                        'icon': Icons.notifications_rounded,
                        'label': 'Notifications',
                        'onTap': () {}
                      },
                      {
                        'icon': Icons.lock_rounded,
                        'label': 'Privacy',
                        'onTap': () {}
                      },
                      {
                        'icon': Icons.help_rounded,
                        'label': 'Help & Support',
                        'onTap': () {}
                      },
                      {
                        'icon': Icons.logout_rounded,
                        'label': 'Logout',
                        'onTap': _logout,
                      },
                    ].asMap().entries.map((e) {
                      final item = e.value;
                      final isLast = e.key == 7;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warmCharcoal,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.mutedSteel),
                        ),
                        child: ListTile(
                          leading: Icon(
                            item['icon'] as IconData,
                            color: isLast
                                ? AppColors.emergencyCrimson
                                : AppColors.saffronAmber,
                            size: 20,
                          ),
                          title: Text(
                            item['label'] as String,
                            style: AppTextStyles.label.copyWith(
                              color: isLast
                                  ? AppColors.emergencyCrimson
                                  : AppColors.brightIvory,
                            ),
                          ),
                          trailing: isLast
                              ? null
                              : const Icon(Icons.arrow_forward_ios_rounded,
                                  color: AppColors.mutedFog, size: 14),
                          onTap: item['onTap'] as void Function(),
                        ),
                      ).animate().fadeIn(delay: (300 + e.key * 40).ms);
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
