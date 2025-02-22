import 'package:accollect/domain/models/category_attributes_model.dart';
import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepDetailsWidget extends StatelessWidget {
  const StepDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextInput(
              label: 'Item Name',
              hint: 'Enter item name',
              onSaved: viewModel.setTitle,
              validator: viewModel.validateTitle,
            ),
            const SizedBox(height: 16),
            CustomTextInput(
              label: 'Description',
              hint: 'Enter item description',
              onSaved: viewModel.setDescription,
            ),
            const SizedBox(height: 16),
            CustomTextInput(
              label: 'Original Price',
              hint: 'Enter original price',
              onSaved: viewModel.setOriginalPrice,
            ),
            const SizedBox(height: 16),
            CustomTextInput(
              label: 'Notes',
              hint: 'Enter additional notes',
              onSaved: viewModel.setNotes,
            ),
            const SizedBox(height: 24),
            FutureBuilder<CategoryAttributesModel?>(
              future: viewModel.getCategoryAttributes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState(theme);
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final catAttributes = snapshot.data!;
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
                    const SizedBox(height: 8),
                    ...catAttributes.attributes.map((attr) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CustomTextInput(
                          label: attr.label,
                          hint: attr.placeholder ?? '',
                          onSaved: (value) {
                            viewModel.setAdditionalAttribute(attr.field, value);
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading attributes...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
