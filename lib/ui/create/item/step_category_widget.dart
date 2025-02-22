import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepCategoryWidget extends StatelessWidget {
  const StepCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Category',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Category Picker Button
        GestureDetector(
          onTap: () {
            showCategoryPickerDialog(
              context: context,
              categories: viewModel.fetchCategoriesCommand.value,
              selectedCategory: viewModel.selectedCategory,
              onCategorySelected: viewModel.setCategory,
              getPlaceholderPath: (category) =>
                  viewModel.placeholderAsset(category),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Image.asset(
                  viewModel.placeholderAsset(viewModel.selectedCategory),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    viewModel.selectedCategory,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Tap to select a category.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
