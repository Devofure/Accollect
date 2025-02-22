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
    final theme = Theme.of(context);
    final viewModel = context.watch<ItemDetailViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Item Details',
            style: TextStyle(color: theme.colorScheme.onSurface)),
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
            return _buildItemDetails(item, theme);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        heroTag: 'delete_item',
        onPressed: () => _confirmDelete(context, viewModel, theme),
        icon: const Icon(Icons.delete),
        label: const Text('Delete Item'),
      ),
    );
  }

  Widget _buildItemDetails(ItemUIModel item, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(item.imageUrls ?? [], theme),
          const SizedBox(height: 20),
          _buildDetailRow('Name', item.name, theme),
          _buildDetailRow('Category', item.category ?? 'No category', theme),
          _buildDetailRow('Added On', _formatDate(item.addedOn), theme),
          if (item.description?.isNotEmpty == true)
            _buildDetailRow('Description', item.description!, theme),
          if (item.originalPrice?.isNotEmpty == true)
            _buildDetailRow('Original Price', item.originalPrice!, theme),
          if (item.notes?.isNotEmpty == true)
            _buildDetailRow('Notes', item.notes!, theme),
          if (item.collectionName?.isNotEmpty == true)
            _buildDetailRow('Collection', item.collectionName!, theme),
          const SizedBox(height: 20),
          _buildAdditionalAttributesSection(item, theme),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls, ThemeData theme) {
    if (imageUrls.isEmpty) {
      return _buildItemImage(null, theme);
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
          items: imageUrls
              .map((imageUrl) => _buildItemImage(imageUrl, theme))
              .toList(),
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildItemImage(String? imageUrl, ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl ?? '',
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(theme),
        errorWidget: (context, url, error) => _buildPlaceholder(theme),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Icon(Icons.image,
          color: theme.colorScheme.onSurfaceVariant, size: 40),
    );
  }

  Widget _buildAdditionalAttributesSection(ItemUIModel item, ThemeData theme) {
    if (item.additionalAttributes == null ||
        item.additionalAttributes!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...item.additionalAttributes!.entries.map((entry) {
          return _buildDetailRow(entry.key, entry.value.toString(), theme);
        }),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ItemDetailViewModel viewModel, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text('Confirm Delete',
              style: TextStyle(color: theme.colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this item?',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Text(
                'This action cannot be undone.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: theme.colorScheme.primary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await viewModel.deleteItem();
              },
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text('Delete',
                  style: TextStyle(color: theme.colorScheme.onError)),
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
