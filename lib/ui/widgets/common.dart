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