import 'package:flutter/material.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailsScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    // Use the `id` to fetch or display the item details
    return Scaffold(
      appBar: AppBar(title: Text('Item Details: $itemId')),
      body: Center(
        child: Text('Display details for item with ID: $itemId'),
      ),
    );
  }
}
