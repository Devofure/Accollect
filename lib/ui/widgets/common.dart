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
