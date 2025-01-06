import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';

class CollectionScreen extends StatelessWidget {
  final String collectionKey;
  const CollectionScreen({super.key, required this.collectionKey});

  @override
  Widget build(BuildContext context) {
    // Use `id` to fetch the collection from a backend, for example
    return Scaffold(
      appBar: AppBar(title: Text('Collection: $collectionKey')),
      body: Center(
        child: Text('Details for collection with ID: $collectionKey'),
      ),
    );
  }
}
