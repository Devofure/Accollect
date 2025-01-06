import 'package:flutter/material.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String id;

  const ItemDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    // Use the `id` to fetch or display the item details
    return Scaffold(
      appBar: AppBar(title: Text('Item Details: $id')),
      body: Center(
        child: Text('Display details for item with ID: $id'),
      ),
    );
  }
}
