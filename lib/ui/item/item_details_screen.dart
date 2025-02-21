import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/item/item_details_view_model.dart';
import 'package:accollect/ui/widgets/common.dart';
import 'package:accollect/ui/widgets/empty_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
              return buildErrorState("Failed to load item.");
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        onPressed: () => _confirmDelete(context, viewModel),
        icon: const Icon(Icons.delete),
        label: const Text('Delete Item'),
      ),
    );
  }

  Widget _buildItemDetails(ItemUIModel item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(item.imageUrls ?? []),
          const SizedBox(height: 20),
          _buildDetailRow('Name', item.title),
          _buildDetailRow('Category', item.category ?? 'No category'),
          _buildDetailRow('Added On', _formatDate(item.addedOn)),
          if (item.description?.isNotEmpty == true)
            _buildDetailRow('Description', item.description!),
          if (item.originalPrice?.isNotEmpty == true)
            _buildDetailRow('Original Price', item.originalPrice!),
          if (item.notes?.isNotEmpty == true)
            _buildDetailRow('Notes', item.notes!),
          if (item.collectionName?.isNotEmpty == true)
            _buildDetailRow('Collection', item.collectionName!),
          const SizedBox(height: 20),
          _buildAdditionalAttributesSection(item),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return _buildItemImage(null);
    }
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            autoPlay: true,
          ),
          items:
              imageUrls.map((imageUrl) => _buildItemImage(imageUrl)).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imageUrls.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            );
          }).toList(),
        ),
      ],
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
        placeholder: (context, url) => imagePlaceholder(),
        errorWidget: (context, url, error) => imagePlaceholder(),
      ),
    );
  }

  Widget _buildAdditionalAttributesSection(ItemUIModel item) {
    if (item.additionalAttributes == null ||
        item.additionalAttributes!.isEmpty) {
      return const SizedBox.shrink();
    }
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
        ...item.additionalAttributes!.entries.map((entry) {
          return _buildDetailRow(entry.key, entry.value.toString());
        }).toList(),
      ],
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

  void _confirmDelete(BuildContext context, ItemDetailViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Confirm Delete',
              style: TextStyle(color: Colors.white)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this item?',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                'This action cannot be undone.',
                style: TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white))),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await viewModel.deleteItem();
              },
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
