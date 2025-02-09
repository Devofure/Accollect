import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? description;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            Text(
              description!,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}
