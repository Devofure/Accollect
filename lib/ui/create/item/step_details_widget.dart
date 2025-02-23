import 'package:accollect/core/app_router.dart';
import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:accollect/ui/widgets/loading_border_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StepDetailsWidget extends StatelessWidget {
  StepDetailsWidget({super.key});

  final ValueNotifier<bool> _isInputNotEmpty = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBarcodeScannerButton(context, viewModel, theme),
        const SizedBox(height: 8),
        _buildBarcodeInput(context, viewModel, theme),
        const SizedBox(height: 16),
        _buildCustomTextInput(
            'Item Name', 'Enter item name', viewModel.setTitle),
        const SizedBox(height: 16),
        _buildCustomTextInput(
            'Description', 'Enter item description', viewModel.setDescription),
        const SizedBox(height: 16),
        _buildCustomTextInput('Original Price', 'Enter original price',
            viewModel.setOriginalPrice),
        const SizedBox(height: 16),
        _buildCustomTextInput(
            'Notes', 'Enter additional notes', viewModel.setNotes),
      ],
    );
  }

  Widget _buildBarcodeScannerButton(BuildContext context,
      MultiStepCreateItemViewModel viewModel,
      ThemeData theme,) =>
      Center(
        child: ElevatedButton.icon(
          onPressed: () {
            context.push(AppRouter.addItemBarcodeScannerRoute);
          },
          icon: Icon(Icons.qr_code_scanner, color: theme.colorScheme.onPrimary),
          label: const Text('Scan Barcode'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      );

  Widget _buildBarcodeInput(BuildContext context,
      MultiStepCreateItemViewModel viewModel, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Barcode',
              hintText: 'Enter barcode digits',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              viewModel.barcode = value;
              _isInputNotEmpty.value = value.isNotEmpty;
            },
          ),
        ),
        const SizedBox(width: 8),
        _buildSearchButton(context, viewModel, theme),
      ],
    );
  }

  Widget _buildSearchButton(BuildContext context,
      MultiStepCreateItemViewModel viewModel, ThemeData theme) {
    return SizedBox(
      height: 48,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isInputNotEmpty,
        builder: (context, isNotEmpty, child) {
          return ValueListenableBuilder<bool>(
            valueListenable: viewModel.fetchItemByBarcodeCommand.isExecuting,
            builder: (context, isExecuting, child) {
              final isDisabled = !isNotEmpty || isExecuting;
              return LoadingBorderButton(
                title: 'Search',
                color: isDisabled
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primary,
                isExecuting: viewModel.fetchItemByBarcodeCommand.isExecuting,
                onPressed:
                    isDisabled ? null : () => _handleSearch(context, viewModel),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleSearch(
      BuildContext context, MultiStepCreateItemViewModel viewModel) async {
    if (viewModel.barcode != null && viewModel.barcode!.isNotEmpty) {
      var products =
          await viewModel.fetchItemByBarcodeCommand.executeWithFuture();
      if (products.isNotEmpty) {
        if (products.length == 1) {
          _showConfirmationDialog(context, viewModel, products.first);
        } else {
          // Handle multiple suggestions (dropdown)
        }
      }
    }
  }

  Widget _buildCustomTextInput(
      String label, String hint, Function(String?) onSaved) {
    return CustomTextInput(
      label: label,
      hint: hint,
      onSaved: onSaved,
    );
  }

  void _showConfirmationDialog(BuildContext context,
      MultiStepCreateItemViewModel viewModel, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Is this the correct item?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${product['title']}"),
            Text("Category: ${product['category']}"),
            Text("Price: \$${product['originalPrice']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              viewModel.fillItemDetails(product);
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
