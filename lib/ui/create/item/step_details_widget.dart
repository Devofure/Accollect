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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBarcodeScannerButton(viewModel, theme),
        const SizedBox(height: 8),
        _buildBarcodeInput(context, viewModel, theme),
        const SizedBox(height: 16),
        _buildItemNameInput(viewModel),
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

  Widget _buildBarcodeScannerButton(
      MultiStepCreateItemViewModel viewModel, ThemeData theme) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: viewModel.scanBarcode,
        icon: Icon(Icons.qr_code_scanner, color: theme.colorScheme.onPrimary),
        label: const Text('Scan Barcode'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildBarcodeInput(BuildContext context,
      MultiStepCreateItemViewModel viewModel, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Barcode',
              hintText: 'Enter barcode digits',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => viewModel.barcode = value,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              if (viewModel.barcode != null && viewModel.barcode!.isNotEmpty) {
                var products = await viewModel.fetchItemByBarcodeCommand
                    .executeWithFuture();
                if (products.isNotEmpty) {
                  if (products.length == 1) {
                    _showConfirmationDialog(context, viewModel, products.first);
                  } else {
                    // Handle multiple suggestions (dropdown)
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Search'),
          ),
        ),
      ],
    );
  }

  Widget _buildItemNameInput(MultiStepCreateItemViewModel viewModel) {
    return CustomTextInput(
      label: 'Item Name',
      hint: 'Enter item name',
      onSaved: viewModel.setTitle,
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
