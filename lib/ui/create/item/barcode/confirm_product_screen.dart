import 'package:flutter/material.dart';

class ConfirmProductScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function() onAddToCollection;

  const ConfirmProductScreen({
    super.key,
    required this.product,
    required this.onAddToCollection,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(product['images']?.first ?? '',
                height: 100, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(product['title'] ?? 'Unknown Product',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(product['brand'] ?? 'No Brand',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAddToCollection,
              child: const Text('Add to Collection'),
            ),
          ],
        ),
      ),
    );
  }
}
