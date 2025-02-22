import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'common.dart';

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
    final isDarkMode = theme.brightness == Brightness.dark;
    final borderColor =
        isSelected ? theme.colorScheme.primary : Colors.transparent;
    final tileColor = isDarkMode
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerHighest;

    double screenWidth = MediaQuery.of(context).size.width;
    double imageSize = screenWidth * 0.18;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'item-${item.key}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildItemImage(imageSize, theme),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildItemDetails(theme)),
                if (isSelected)
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
                if (menuOptions != null) _buildPopupMenu(theme),
              ],
            ),
          ),
          if (item.category?.isNotEmpty == true)
            Positioned(
              top: 6,
              right: 6,
              child: buildCategoryChip(theme, item.category!),
            ),
        ],
      ),
    );
  }

  Widget _buildItemImage(double size, ThemeData theme) {
    final imageUrl = item.firstImageUrl;
    return imageUrl != null
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(size, theme),
            errorWidget: (context, url, error) => _buildErrorImage(size, theme),
          )
        : _buildPlaceholder(size, theme);
  }

  Widget _buildPlaceholder(double size, ThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      ),
      child: Icon(Icons.image,
          color: theme.colorScheme.onSurfaceVariant, size: 26),
    );
  }

  Widget _buildErrorImage(double size, ThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
      ),
      child:
          Icon(Icons.broken_image, color: theme.colorScheme.onError, size: 26),
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
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          item.collectionName ?? 'Unknown Collection',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          item.description ?? 'No description available',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenu(ThemeData theme) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
      itemBuilder: (context) => menuOptions!,
    );
  }
}
