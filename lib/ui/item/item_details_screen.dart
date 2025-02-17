import 'package:accollect/core/app_router.dart';
import 'package:accollect/domain/models/category_attributes_model.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/item/item_details_view_model.dart';
import 'package:accollect/ui/widgets/common.dart';
import 'package:accollect/ui/widgets/empty_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          const SizedBox(height: 16),
          _buildAdditionalAttributesSection(item),
        ],
      ),
    );
  }

  Widget _buildAdditionalAttributesSection(ItemUIModel item) {
    return FutureBuilder<CategoryAttributesModel?>(
      future: _fetchCategoryAttributes(item.category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          // If static attributes are not available, we show nothing.
          return const SizedBox.shrink();
        }
        final catAttributes = snapshot.data!;
        // For each defined attribute, display the stored value (or "N/A" if missing)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...catAttributes.attributes.map((attrDef) {
              final value = item.additionalAttributes != null
                  ? item.additionalAttributes![attrDef.field]
                  : null;
              return _buildDetailRow(attrDef.label, value?.toString() ?? 'N/A');
            }),
          ],
        );
      },
    );
  }

  Future<CategoryAttributesModel?> _fetchCategoryAttributes(
      String? category) async {
    if (category == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('categoryAttributes')
        .doc(category)
        .get();
    if (!doc.exists) return null;
    return CategoryAttributesModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Widget _buildItemImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl ?? '',
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        placeholder: (context, url) => imagePlaceholder(),
        errorWidget: (context, url, error) => imagePlaceholder(),
      ),
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
