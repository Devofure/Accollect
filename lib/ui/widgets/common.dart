import 'package:flutter/material.dart';

Widget imagePlaceholder() {
  return Container(
    width: double.infinity,
    height: 300,
    color: Colors.grey[800],
    child: const Icon(Icons.image, color: Colors.white, size: 50),
  );
}

Widget circularImagePlaceholder(double size) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.grey,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.image, color: Colors.white, size: 32),
  );
}

Widget buildErrorState(String errorMessage) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(errorMessage, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

Widget buildEmptyState({
  required String title,
  String? description,
  IconData icon = Icons.sentiment_dissatisfied,
  VoidCallback? onActionPressed,
  String? actionLabel,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey, size: 64),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
        if (onActionPressed != null && actionLabel != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onActionPressed,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget circularImageWidget(String? imageUrl, {double size = 90}) {
  return ClipOval(
    child: imageUrl != null
        ? Image.network(
            imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _circularImagePlaceholder(size),
          )
        : _circularImagePlaceholder(size),
  );
}

Widget _circularImagePlaceholder(double size) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.grey,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.image, color: Colors.white, size: 40),
  );
}
