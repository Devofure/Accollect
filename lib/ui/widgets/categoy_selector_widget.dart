import 'package:accollect/ui/item/item_library_view_model.dart';
import 'package:flutter/material.dart';

Widget buildCategorySelector({
  required BuildContext context,
  required ItemLibraryViewModel viewModel,
  required Function(String?) onCategorySelected,
}) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => onCategorySelected(null),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: viewModel.selectedCategory == null
                  ? Colors.blue
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "All",
              style: TextStyle(
                color: viewModel.selectedCategory == null
                    ? Colors.white
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ...viewModel.categories.map((category) {
          final isSelected = viewModel.selectedCategory == category;
          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ],
    ),
  );
}
