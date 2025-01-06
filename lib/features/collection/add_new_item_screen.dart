import 'package:flutter/material.dart';

class AddNewItemScreen extends StatelessWidget {
  const AddNewItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen could have a form to add a new item
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mock UI: Form to add a new item'),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Save Item'),
              onPressed: () {
                // After saving, go back to Collection screen
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
