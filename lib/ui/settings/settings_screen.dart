import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/sign_out_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileSection(context),
          const SizedBox(height: 16),
          _buildSettingsGroup(
            context,
            title: 'Preferences',
            items: [
              _buildSettingsTile(
                context,
                title: 'Collection Management',
                icon: Icons.settings,
                onTap: () => context.push(AppRouter.settingsCollectionsRoute),
              ),
              _buildSettingsTile(
                context,
                title: 'Notifications',
                icon: Icons.notifications,
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                title: 'Appearance',
                icon: Icons.brightness_6,
                onTap: () => _showThemeDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SignOutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final displayName = user?.displayName ?? 'User';
        final photoUrl = user?.photoURL;
        final email = user?.email ?? 'No email linked';

        return Material(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => context.push(AppRouter.profileRoute),
            borderRadius: BorderRadius.circular(12),
            splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? Icon(Icons.person, color: theme.iconTheme.color)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: theme.textTheme.titleMedium),
                        Text(email, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 18, color: theme.iconTheme.color),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsGroup(BuildContext context,
      {required String title, required List<Widget> items}) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            title,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Column(children: items),
      ],
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        highlightColor: Colors.transparent,
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: theme.iconTheme.color),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.iconTheme.color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Choose Theme',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(dialogContext, themeProvider, 'System Default',
                  ThemeMode.system),
              _buildThemeOption(
                  dialogContext, themeProvider, 'Light Theme', ThemeMode.light),
              _buildThemeOption(
                  dialogContext, themeProvider, 'Dark Theme', ThemeMode.dark),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    String title,
    ThemeMode mode,
  ) {
    final theme = Theme.of(context);
    final isSelected = themeProvider.themeMode == mode;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          mode == ThemeMode.light
              ? Icons.wb_sunny
              : mode == ThemeMode.dark
                  ? Icons.nightlight_round
                  : Icons.brightness_auto,
          color: theme.colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check, color: theme.colorScheme.primary)
            : null,
        onTap: () {
          themeProvider.setTheme(mode);
          Navigator.pop(context);
        },
      ),
    );
  }
}