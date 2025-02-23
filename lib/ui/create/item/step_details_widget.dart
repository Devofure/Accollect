import 'dart:async';

import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepDetailsWidget extends StatefulWidget {
  const StepDetailsWidget({super.key});

  @override
  State<StepDetailsWidget> createState() => _StepDetailsWidgetState();
}

class _StepDetailsWidgetState extends State<StepDetailsWidget> {
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItemNameInput(context, viewModel, theme),
        const SizedBox(height: 8),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: viewModel.fetchSuggestionsCommand,
          builder: (context, suggestions, _) {
            if (suggestions.isEmpty) return const SizedBox.shrink();
            return _buildSuggestionsList(context, viewModel, suggestions);
          },
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
      ],
    );
  }

  /// 🏗 **Item Name Input with Debounced Search**
  Widget _buildItemNameInput(BuildContext context,
      MultiStepCreateItemViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Name',
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter item name',
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
          validator: viewModel.validateTitle,
          onSaved: viewModel.setTitle,
          onChanged: (value) {
            _debounceSearch(viewModel, value);
          },
        ),
      ],
    );
  }

  void _debounceSearch(MultiStepCreateItemViewModel viewModel, String query) {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        viewModel.fetchSuggestionsCommand.execute(query);
      }
    });
  }

  /// 📋 **Suggestions List UI**
  Widget _buildSuggestionsList(
      BuildContext context,
      MultiStepCreateItemViewModel viewModel,
      List<Map<String, dynamic>> suggestions) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: suggestions.take(5).map((item) {
          return ListTile(
            leading: item['images'] != null && item['images'].isNotEmpty
                ? Image.network(item['images'][0],
                    width: 40, height: 40, fit: BoxFit.cover)
                : Icon(Icons.image_not_supported,
                    color: theme.colorScheme.onSurfaceVariant),
            title: Text(item['title'] ?? "Unknown Item",
                style: theme.textTheme.bodyLarge),
            subtitle: Text(item['brand'] ?? "No brand",
                style: theme.textTheme.bodySmall),
            onTap: () {
              viewModel.selectSuggestion(item);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
