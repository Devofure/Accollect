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
            return _buildItemDetails(context, item, theme, viewModel);
          },
        ),
      ),
      floatingActionButton: _buildFloatingButtons(context, viewModel, theme),
    );
  }

  Widget _buildItemDetails(BuildContext context, ItemUIModel item,
      ThemeData theme, ItemDetailViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(
              item.imageUrls ?? [], item.onlineImageUrls ?? [], theme),
          const SizedBox(height: 24),
          _buildSectionCard(theme, '📌 General Info', [
            _buildDetailRow('Name', item.name, theme),
            _buildDetailRow('Category', item.category ?? 'No category', theme),
            _buildDetailRow('Added On', _formatDate(item.addedOn), theme),
            if (item.originalPrice?.isNotEmpty == true)
              _buildDetailRow('Original Price', item.originalPrice!, theme),
            if (item.notes?.isNotEmpty == true)
              _buildDetailRow('Notes', item.notes!, theme),
            if (item.collectionName?.isNotEmpty == true)
              _buildDetailRow('Collection', item.collectionName!, theme),
          ]),
          if (item.description?.isNotEmpty == true)
            _buildSectionCard(theme, '📝 Description', [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child:
                    Text(item.description!, style: theme.textTheme.bodyMedium),
              ),
            ]),
          _buildAdditionalAttributesSection(item, theme),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(
      List<String> imageUrls, List<String> onlineImageUrls, ThemeData theme) {
    final allImages = [...imageUrls, ...onlineImageUrls];
    if (allImages.isEmpty) return _buildPlaceholder(theme);

    return CarouselSlider(
      options: CarouselOptions(
        height: 300,
        enableInfiniteScroll: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        autoPlay: true,
      ),
      items: allImages
          .map((imageUrl) => _buildItemImage(imageUrl, theme))
          .toList(),
    );
  }

  Widget _buildItemImage(String imageUrl, ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
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
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Icon(Icons.image,
          color: theme.colorScheme.onSurfaceVariant, size: 30),
    );
  }

  Widget _buildSectionCard(
      ThemeData theme, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(value,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalAttributesSection(ItemUIModel item, ThemeData theme) {
    if (item.additionalAttributes == null ||
        item.additionalAttributes!.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildSectionCard(
      theme,
      '🔎 Extra Information',
      item.additionalAttributes!.entries
          .map((entry) =>
              _buildDetailRow(entry.key, entry.value.toString(), theme))
          .toList(),
    );
  }

  Widget _buildFloatingButtons(
      BuildContext context, ItemDetailViewModel viewModel, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          heroTag: 'edit_item',
          onPressed: () => _editItem(context, viewModel),
          child: const Icon(Icons.edit),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          heroTag: 'delete_item',
          onPressed: () => _confirmDelete(context, viewModel, theme),
          child: const Icon(Icons.delete),
        ),
      ],
    );
  }

  void _editItem(BuildContext context, ItemDetailViewModel viewModel) {
    debugPrint("Edit feature not implemented yet.");
  }

  void _confirmDelete(
      BuildContext context, ItemDetailViewModel viewModel, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text(
            "Are you sure you want to delete this item? This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await viewModel.deleteItem();
              },
              child: const Text("Delete")),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);
}
