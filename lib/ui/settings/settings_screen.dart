import 'package:accollect/core/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/sign_out_tile.dart';

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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileSection(context),
          const SizedBox(height: 16),
          _buildSettingsGroup(
            title: 'Account',
            items: [
              _buildSettingsTile(
                title: 'Account Details',
                icon: Icons.person,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsGroup(
            title: 'Preferences',
            items: [
              _buildSettingsTile(
                title: 'Collection Management',
                icon: Icons.settings,
                onTap: () => context.push(AppRouter.settingsCollectionsRoute),
              ),
              _buildSettingsTile(
                title: 'Notifications',
                icon: Icons.notifications,
                onTap: () {},
              ),
              _buildSettingsTile(
                title: 'Appearance',
                icon: Icons.nights_stay,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SignOutTile(),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRouter.profileRoute);
      },
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final displayName = user?.displayName ?? 'User';
          final photoUrl = user?.photoURL;
          final email = user?.email ?? 'No email linked';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[700],
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 30)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 18),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsGroup(
      {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: item,
            )),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        highlightColor: Colors.transparent,
        splashColor: Colors.white.withValues(alpha: 0.1),
        splashFactory: InkRipple.splashFactory,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
