import 'package:accollect/domain/models/category_attributes_model.dart';
import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepAdditionalAttributesWidget extends StatelessWidget {
  const StepAdditionalAttributesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return FutureBuilder<CategoryAttributesModel?>(
      future: viewModel.getCategoryAttributes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Text(
            'No additional attributes for this category.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        final attributes = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Attributes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...attributes.attributes.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: entry.label,
                    labelStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    viewModel.setAdditionalAttribute(entry.field, value);
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
