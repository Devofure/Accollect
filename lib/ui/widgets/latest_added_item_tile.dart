import 'package:accollect/data/models/item_ui_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LatestAddedItemTile extends StatelessWidget {
  final ItemUIModel item;
  final VoidCallback? onTap;
  final bool isSelected;
  final List<PopupMenuEntry>? menuOptions;

  const LatestAddedItemTile({
    super.key,
    required this.item,
    this.onTap,
    this.isSelected = false,
    this.menuOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected ? Colors.blue : Colors.transparent;
    double screenWidth = MediaQuery.of(context).size.width;
    double imageSize = screenWidth * 0.18;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueGrey[800] : Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: item.key,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildItemImage(imageSize),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildItemDetails(theme)),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
            if (menuOptions != null) _buildPopupMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(double size) {
    return item.imageUrl != null && item.imageUrl!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: item.imageUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(size),
            errorWidget: (context, url, error) => _buildErrorImage(size),
          )
        : _buildPlaceholder(size);
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.photo, color: Colors.white, size: 30),
    );
  }

  Widget _buildErrorImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.broken_image, color: Colors.white, size: 30),
    );
  }

  Widget _buildItemDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.collectionName ?? 'No Collection',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.blueGrey[300],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Added on: ${_formatDate(item.addedOn)}',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      itemBuilder: (context) => menuOptions!,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Unknown date";
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
