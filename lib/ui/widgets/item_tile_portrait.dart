import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ItemPortraitTile extends StatelessWidget {
  final ItemUIModel item;
  final VoidCallback? onTap;
  final bool isSelected;
  final List<PopupMenuEntry>? menuOptions;

  const ItemPortraitTile({
    super.key,
    required this.item,
    this.onTap,
    this.isSelected = false,
    this.menuOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: item.firstImageUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildPlaceholder(theme),
                      errorWidget: (context, url, error) =>
                          _buildPlaceholder(theme),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.check,
                    color: theme.colorScheme.onPrimary, size: 18),
              ),
            ),
        ],
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
}
