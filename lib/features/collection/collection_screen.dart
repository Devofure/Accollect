import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For demonstration, show a mock list of items
    return Scaffold(
      appBar: AppBar(title: const Text('Collection Details')),
      body: ListView.builder(
        itemCount: 5, // mock item count
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item ${index + 1}'),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.itemDetailsRoute);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addNewItemRoute);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
