import 'package:accollect/core/navigation/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous screen
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Optional: Add functionality for the menu
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSettingsGroup(
            context,
            title: '',
            items: [
              _buildSettingsTile(
                context,
                title: 'Account',
                icon: Icons.person,
                onTap: () {
                  // TODO: Navigate to Account screen
                },
              ),
              _buildSettingsTile(
                context,
                title: 'My subscription',
                icon: Icons.card_membership,
                onTap: () {
                  // TODO: Navigate to Subscription screen
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // General Section
          _buildSettingsGroup(
            context,
            title: '',
            items: [
              _buildSettingsTile(
                context,
                title: 'General',
                icon: Icons.tune,
                onTap: () {
                  // TODO: Navigate to General settings screen
                },
              ),
              _buildSettingsTile(
                context,
                title: 'Privacy',
                icon: Icons.security,
                onTap: () {
                  // TODO: Navigate to Privacy screen
                },
              ),
              _buildSettingsTile(
                context,
                title: 'Notifications',
                icon: Icons.notifications,
                onTap: () {
                  // TODO: Navigate to Notifications screen
                },
              ),
              _buildSettingsTile(
                context,
                title: 'Appearance',
                icon: Icons.nights_stay,
                onTap: () {
                  // TODO: Navigate to Appearance settings screen
                },
              ),
              _buildSettingsTile(
                context,
                title: 'Collection Management',
                icon: Icons.settings,
                onTap: () {
                  // TODO: Navigate to Collection Management screen
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Assistance Section
          _buildSettingsGroup(
            context,
            title: '',
            items: [
              _buildSettingsTile(
                context,
                title: 'Collector Assistance',
                icon: Icons.help_outline,
                onTap: () {
                  // TODO: Navigate to Assistance screen
                },
              ),
              _buildSettingsTile(
                context,
                title: 'Sign out',
                icon: Icons.logout,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  context.go(AppRouter.onboardingRoute);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper: Build Settings Group
  Widget _buildSettingsGroup(BuildContext context,
      {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: item,
          ),
        ),
      ],
    );
  }

  // Helper: Build Settings Tile
  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: onTap,
      ),
    );
  }
}
