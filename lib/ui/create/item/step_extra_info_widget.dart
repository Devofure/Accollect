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

    // If there are no additional attributes, show a message.
    if (viewModel.additionalAttributes.isEmpty) {
      return Text(
        'No additional attributes available.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

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
        ...viewModel.additionalAttributes.entries.map((entry) {
          final currentValue = entry.value?.toString() ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CustomTextInput(
              key: ValueKey(currentValue),
              label: entry.key,
              // Use the attribute key as label.
              hint: 'Enter ${entry.key}',
              controller: TextEditingController(text: currentValue),
              onChanged: (value) {
                viewModel.setAdditionalAttribute(entry.key, value);
              },
            ),
          );
        }),
      ],
    );
  }
}
