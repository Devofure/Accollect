import 'package:accollect/core/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sign Up Screen'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to home, for example
                context.go(AppRouter.homeRoute);
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
