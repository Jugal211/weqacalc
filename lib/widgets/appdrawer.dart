import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.history,
                    title: 'Calculation History',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage(context, 'Opening History');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.bookmark,
                    title: 'Saved Calculations',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage(context, 'Opening Saved');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.trending_up,
                    title: 'Financial Reports',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage(context, 'Opening Reports');
                    },
                  ),
                  const Divider(height: 32),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage(context, 'Opening Settings');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage(context, 'Opening Help');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage(context, 'Opening About');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.star_outline,
                    title: 'Rate Us',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage(context, 'Thank you for rating!');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.share,
                    title: 'Share App',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage(context, 'Opening Share');
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              iconColor: Colors.red.shade400,
              onTap: () {
                Navigator.pop(context);
                _showMessage(context, 'Logged out');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_circle,
              size: 50,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'John Doe',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'john.doe@email.com',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Premium Member',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade700, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: iconColor ?? Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.blue.shade50,
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
