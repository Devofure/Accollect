import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepCategoryWidget extends StatelessWidget {
  const StepCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MultiStepCreateItemViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a Category',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<String>>(
          valueListenable: viewModel.fetchCategoriesCommand,
          builder: (context, categories, _) {
            final uniqueCats = categories.toSet().toList();
            // Set a default if needed.
            if (uniqueCats.isNotEmpty &&
                (viewModel.selectedCategory == 'Other' ||
                    !uniqueCats.contains(viewModel.selectedCategory))) {
              viewModel.setCategory(uniqueCats.first);
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: uniqueCats.map((cat) {
                final isSelected = cat == viewModel.selectedCategory;
                return GestureDetector(
                  onTap: () => viewModel.setCategory(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected ? Colors.blueAccent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Tap a category to select it.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }
}
