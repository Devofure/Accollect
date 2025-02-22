import 'package:accollect/core/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go(AppRouter.onboardingRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildRippleEffect(
      context: context,
      onTap: () => _handleSignOut(context),
      child: _buildSignOutContent(context),
    );
  }

  /// 🔹 Extracted Ripple Effect Wrapper
  Widget _buildRippleEffect({
    required BuildContext context,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.2),
        // 🔹 Proper Ripple Effect
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: child,
      ),
    );
  }

  /// 🔹 Sign-Out Button Content (Reused Inside Ripple)
  Widget _buildSignOutContent(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.redAccent[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.logout, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sign Out',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
