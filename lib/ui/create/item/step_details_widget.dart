import 'package:accollect/core/app_router.dart';
import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:accollect/ui/widgets/loading_border_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StepDetailsWidget extends StatefulWidget {
  const StepDetailsWidget({super.key});

  @override
  State<StepDetailsWidget> createState() => _StepDetailsWidgetState();
}

class _StepDetailsWidgetState extends State<StepDetailsWidget> {
  final ValueNotifier<bool> _isInputNotEmpty = ValueNotifier<bool>(false);
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    // ✅ Ensure text controllers reflect ViewModel data
    _barcodeController.text = viewModel.barcode ?? "";
    _nameController.text = viewModel.name ?? "";
    _descriptionController.text = viewModel.description ?? "";
    _priceController.text = viewModel.originalPrice ?? "";
    _notesController.text = viewModel.notes ?? "";
  }

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
        CustomTextInput(
            label: 'Item Name',
            hint: 'Enter item name',
            controller: _nameController,
            onSaved: viewModel.setTitle),
        const SizedBox(height: 16),
        CustomTextInput(
            label: 'Description',
            hint: 'Enter item description',
            controller: _descriptionController,
            onSaved: viewModel.setDescription),
        const SizedBox(height: 16),
        CustomTextInput(
            label: 'Original Price',
            hint: 'Enter original price',
            controller: _priceController,
            onSaved: viewModel.setOriginalPrice),
        const SizedBox(height: 16),
        CustomTextInput(
            label: 'Notes',
            hint: 'Enter additional notes',
            controller: _notesController,
            onSaved: viewModel.setNotes),
      ],
    );
  }

  Widget _buildBarcodeScannerButton(BuildContext context,
      MultiStepCreateItemViewModel viewModel, ThemeData theme) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final result =
              await context.push<Result>(AppRouter.addItemBarcodeScannerRoute);

          if (result != null &&
              result.status == Status.ok &&
              result.content != null &&
              result.content is String &&
              result.content!.trim().isNotEmpty) {
            viewModel.barcode = result.content;
            _barcodeController.text = result.content!;
            var products =
                await viewModel.fetchItemByBarcodeCommand.executeWithFuture();
            if (products.isNotEmpty) {
              if (products.length == 1) {
                _showConfirmationDialog(context, viewModel, products.first);
              } else {
                // Handle multiple products (dropdown selection)
              }
            }
          }
        },
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
          child: CustomTextInput(
            controller: _barcodeController,
            label: 'Barcode',
            hint: 'Enter barcode digits',
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
                onPressed: isDisabled
                    ? null
                    : () async {
                        var products = await viewModel.fetchItemByBarcodeCommand
                            .executeWithFuture();
                        if (products.isNotEmpty) {
                          if (products.length == 1) {
                            _showConfirmationDialog(
                                context, viewModel, products.first);
                          } else {
                            // Handle multiple products
                          }
                        }
                      },
              );
            },
          );
        },
      ),
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
            onPressed: () => context.pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              viewModel.fillItemDetails(product);
              _barcodeController.text = viewModel.barcode ?? "";
              _nameController.text = viewModel.name ?? "";
              _descriptionController.text = viewModel.description ?? "";
              _priceController.text = viewModel.originalPrice ?? "";
              _notesController.text = viewModel.notes ?? "";

              setState(() {}); // ✅ Force UI update
              context.pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
