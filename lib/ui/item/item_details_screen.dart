import 'package:accollect/core/app_router.dart';
import 'package:accollect/ui/item/item_details_view_model.dart';
import 'package:accollect/ui/widgets/empty_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemKey;

  const ItemDetailScreen({super.key, required this.itemKey});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemDetailViewModel(itemKey: itemKey),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title:
              const Text('Item Details', style: TextStyle(color: Colors.white)),
        ),
        body: SafeArea(
          child: Consumer<ItemDetailViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.errorMessage != null) {
                return _buildErrorState(context, viewModel.errorMessage!);
              }

              if (viewModel.item == null) {
                return const EmptyStateWidget(
                  title: 'Item Not Found',
                  description: 'This item might have been deleted or moved.',
                );
              }

              return _buildItemDetails(viewModel);
            },
          ),
        ),
        floatingActionButton: Consumer<ItemDetailViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.item == null) return const SizedBox.shrink();
            return FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              onPressed: () => _deleteItem(context, viewModel),
              icon: const Icon(Icons.delete),
              label: const Text('Delete Item'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemDetails(ItemDetailViewModel viewModel) {
    final item = viewModel.item!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemImage(item.imageUrl),
          const SizedBox(height: 16),
          _buildDetailRow('Name', item.title),
          _buildDetailRow('Category', item.category),
          _buildDetailRow('Added On', _formatDate(item.addedOn)),
          if (item.description.isNotEmpty)
            _buildDetailRow('Description', item.description),
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
    context.go(AppRouter.homeRoute);
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
          ElevatedButton(
            onPressed: () =>
                Provider.of<ItemDetailViewModel>(context, listen: false)
                    .fetchItem(),
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
