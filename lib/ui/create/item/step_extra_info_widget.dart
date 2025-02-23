import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepExtraInfoWidget extends StatelessWidget {
  const StepExtraInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MultiStepCreateItemViewModel>();
    final attributes = viewModel.additionalAttributes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extra Information',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // ✅ If there are no attributes, show message.
        if (attributes.isEmpty)
          Text(
            'No extra attributes available. You can add custom fields below.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

        ...attributes.entries.map((entry) {
          final currentValue = entry.value?.toString() ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextInput(
                    key: ValueKey(entry.key),
                    label: entry.key,
                    hint: 'Enter ${entry.key}',
                    controller: TextEditingController(text: currentValue),
                    onChanged: (value) {
                      viewModel.setAdditionalAttribute(entry.key, value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                  onPressed: () =>
                      viewModel.removeAdditionalAttribute(entry.key),
                ),
              ],
            ),
          );
        }),

        // ✅ Add new custom field button
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddAttributeDialog(context, viewModel),
            icon: const Icon(Icons.add),
            label: const Text("Add Custom Field"),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddAttributeDialog(
      BuildContext context, MultiStepCreateItemViewModel viewModel) {
    final fieldController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Custom Field"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextInput(
              label: "Field Name",
              hint: "Enter field name (e.g., 'Color')",
              controller: fieldController,
            ),
            const SizedBox(height: 8),
            CustomTextInput(
              label: "Value",
              hint: "Enter value",
              controller: valueController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (fieldController.text.isNotEmpty &&
                  valueController.text.isNotEmpty) {
                viewModel.setAdditionalAttribute(
                    fieldController.text, valueController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
