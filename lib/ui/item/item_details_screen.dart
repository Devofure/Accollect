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
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
            onPressed: () => _showMoreOptions(context, viewModel, theme),
          ),
        ],
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
            return _buildItemDetails(context, item, theme);
          },
        ),
      ),
    );
  }

  Widget _buildItemDetails(
      BuildContext context, ItemUIModel item, ThemeData theme) {
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
              _buildExpandableDetailRow(context, 'Notes', item.notes!, theme),
            if (item.collectionName?.isNotEmpty == true)
              _buildDetailRow('Collection', item.collectionName!, theme),
          ]),
          if (item.description?.isNotEmpty == true)
            _buildSectionCard(theme, '📝 Description', [
              _buildExpandableDetailRow(
                  context, 'Description', item.description!, theme),
            ]),
          _buildAdditionalAttributesSection(item, theme),
        ],
      ),
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

  Widget _buildImageCarousel(
      List<String> imageUrls, List<String> onlineImageUrls, ThemeData theme) {
    final allImages = [...imageUrls, ...onlineImageUrls];
    if (allImages.isEmpty) return _buildPlaceholder(theme);

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            enableInfiniteScroll: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4), // ⏳ Slower auto-play
          ),
          items: allImages
              .map((imageUrl) => _buildItemImage(imageUrl, theme))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: allImages.asMap().entries.map((entry) {
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
      height: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(Icons.image,
            color: theme.colorScheme.onSurfaceVariant, size: 40),
      ),
    );
  }

  Widget _buildExpandableDetailRow(
      BuildContext context, String label, String value, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showFullTextDialog(context, label, value),
      child: _buildDetailRow(label, value, theme),
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

  void _showFullTextDialog(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(text),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
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

  void _showMoreOptions(
      BuildContext context, ItemDetailViewModel viewModel, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // 🔥 Enables swipe-to-dismiss
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: theme.colorScheme.primary),
                title: const Text('Edit Item'),
                onTap: () {
                  Navigator.pop(context);
                  _editItem(context, viewModel);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: theme.colorScheme.error),
                title: const Text('Delete Item'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, viewModel, theme);
                },
              ),
            ],
          ),
        );
      },
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
