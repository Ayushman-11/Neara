import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final void Function(int index)? onSelectScreen;

  const AppDrawer({super.key, this.onSelectScreen});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xE6121826),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DrawerHeader(),
            const SizedBox(height: 16),
            _DrawerItem(
              icon: Icons.mic,
              label: 'Home (Voice Agent)',
              onTap: () {
                Navigator.of(context).maybePop();
                onSelectScreen?.call(0);
              },
            ),
            _DrawerItem(
              icon: Icons.map,
              label: 'Browse Services',
              onTap: () {
                Navigator.of(context).maybePop();
                onSelectScreen?.call(1);
              },
            ),
            _DrawerItem(icon: Icons.bookmark, label: 'Saved Workers'),
            _DrawerItem(icon: Icons.assignment, label: 'My Requests'),
            _DrawerItem(icon: Icons.shield, label: 'Safety & SOS'),
            const _DrawerItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
            ),
            const _DrawerItem(icon: Icons.settings, label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
              ),
            ),
            child: const Icon(Icons.bolt, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Neara',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                'Emergency-ready discovery',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DrawerItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE5E7EB)),
      title: Text(label, style: const TextStyle(color: Color(0xFFE5E7EB))),
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
    );
  }
}
