import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CollectionListScreen extends StatelessWidget {
  final String id;

  const CollectionListScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Collection: $id')),
      body: ElevatedButton(
        onPressed: () {
          String newId = '456'; // Example of a dynamic ID
          context.go('/collection/$newId');
        },
        child: Text('Go to Collection'),
      ),
    );
  }
}
