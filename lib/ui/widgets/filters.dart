import 'package:flutter/material.dart';

class FiltersWidget extends StatelessWidget {
  final VoidCallback? onFilterPressed;
  final VoidCallback? onSortPressed;

  const FiltersWidget({
    super.key,
    this.onFilterPressed,
    this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onFilterPressed,
          icon: const Icon(Icons.filter_list, color: Colors.white),
          label: const Text(
            'Filter',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onSortPressed,
          icon: const Icon(Icons.sort, color: Colors.white),
          label: const Text(
            'Sort',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
