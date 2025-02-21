import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/ui/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CollectionTile extends StatelessWidget {
  final CollectionUIModel collection;
  final VoidCallback onTap;
  final String? placeholderAsset;

  const CollectionTile({
    super.key,
    required this.collection,
    required this.onTap,
    this.placeholderAsset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? theme.colorScheme.surface
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(45),
                right: Radius.circular(14),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: _buildListTile(context, theme),
          ),
          if (collection.category?.isNotEmpty == true)
            Positioned(
              top: 8,
              right: 8,
              child: buildCategoryChip(theme, collection.category!),
            ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        circularImageWidget(
          collection.imageUrl,
          placeholderAsset: placeholderAsset,
          size: 80,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      collection.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (collection.isFavorite == true) _buildFavoriteIcon(theme),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                collection.description?.isNotEmpty == true
                    ? collection.description!
                    : 'No description',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        'Updated: ${_formatDate(collection.lastUpdated)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  _buildItemCountBadge(theme),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteIcon(ThemeData theme) {
    return Icon(Icons.star, color: theme.colorScheme.secondary, size: 20);
  }

  Widget _buildItemCountBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${collection.itemsCount}',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
