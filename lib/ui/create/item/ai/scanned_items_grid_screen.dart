import 'package:flutter/material.dart';

class ScannedItemsGridScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const ScannedItemsGridScreen({super.key, required this.items});

  @override
  State<ScannedItemsGridScreen> createState() => _ScannedItemsGridScreenState();
}

class _ScannedItemsGridScreenState extends State<ScannedItemsGridScreen>
    with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> scannedItems;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    scannedItems = List.from(widget.items);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _removeItem(int index) {
    setState(() {
      scannedItems.removeAt(index);
      _animationController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanned Items")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: scannedItems.length,
        itemBuilder: (context, index) {
          final item = scannedItems[index];
          return ScaleTransition(
            scale:
                _animationController.drive(CurveTween(curve: Curves.bounceOut)),
            child: GridTile(
              child: Column(
                children: [
                  Image.network(item['image'], height: 100),
                  Text(item['title']),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeItem(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
