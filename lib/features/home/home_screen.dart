import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Collections')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/create-collection'), // Correct navigation using go_router
          child: Text('Create Collection'),
        ),
      ),
    );
  }
}
