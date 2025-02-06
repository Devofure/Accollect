import 'package:accollect/features/item/item_library_view_model.dart';
import 'package:flutter/material.dart';

Widget buildCategorySelector({
  required BuildContext context,
  required ItemLibraryViewModel viewModel,
  required Function(String) onCategorySelected,
}) {
  final categories = ['+ New Category', ...viewModel.categories];

  return Container(
    height: 50,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = viewModel.selectedCategory == category;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ChoiceChip(
            label: Text(category),
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
            selected: isSelected,
            onSelected: (isSelected) {
              if (category == '+ New Category') {
                _showAddCategoryDialog(context, viewModel);
              } else {
                viewModel.selectCategory(category);
                onCategorySelected(category);
              }
            },
            selectedColor:
                category == '+ New Category' ? Colors.grey[800] : Colors.white,
            backgroundColor: Colors.grey[800],
          ),
        );
      },
    ),
  );
}

void _showAddCategoryDialog(
    BuildContext context, ItemLibraryViewModel viewModel) {
  final TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        'Add New Category',
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Enter category name',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              viewModel.addCategory(controller.text.trim());
            }
            Navigator.pop(context);
          },
          child: const Text('Add', style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}
