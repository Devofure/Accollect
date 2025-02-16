import 'package:accollect/core/app_router.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/item/item_details_view_model.dart';
import 'package:accollect/ui/widgets/empty_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ItemDetailViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text('Item Details', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: StreamBuilder<ItemUIModel?>(
          stream: viewModel.itemStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildErrorState(context, "Failed to load item.");
            }
            final item = snapshot.data;
            if (item == null) {
              return const EmptyStateWidget(
                title: 'Item Not Found',
                description: 'This item might have been deleted or moved.',
              );
            }
            return _buildItemDetails(item);
          },
        ),
      ),
      floatingActionButton: StreamBuilder<ItemUIModel?>(
        stream: viewModel.itemStream,
        builder: (context, snapshot) {
          final item = snapshot.data;
          if (item == null) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            onPressed: () => _confirmDelete(context, viewModel),
            icon: const Icon(Icons.delete),
            label: const Text('Delete Item'),
          );
        },
      ),
    );
  }

  Widget _buildItemDetails(ItemUIModel item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'item-${item.key}',
            child: _buildItemImage(item.imageUrl),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Name', item.title),
          _buildDetailRow('Category', item.category ?? 'No category'),
          _buildDetailRow('Added On', _formatDate(item.addedOn)),
          if (item.description?.isNotEmpty == true)
            _buildDetailRow('Description', item.description!),
        ],
      ),
    );
  }

  Widget _buildItemImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl ?? '',
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        placeholder: (context, url) => _imagePlaceholder(),
        errorWidget: (context, url, error) => _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.grey[800],
      child: const Icon(Icons.image, color: Colors.white, size: 50),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  void _deleteItem(BuildContext context, ItemDetailViewModel viewModel) async {
    await viewModel.deleteItem();
    if (!context.mounted) return;
    context.go(AppRouter.homeRoute);
  }

  void _confirmDelete(BuildContext context, ItemDetailViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Confirm Delete',
              style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this item?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _deleteItem(context, viewModel);
              },
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(errorMessage,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
