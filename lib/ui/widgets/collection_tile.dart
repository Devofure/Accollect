import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/ui/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CollectionTile extends StatelessWidget {
  final CollectionUIModel collection;
  final VoidCallback onTap;
  final bool isSquareTile;

  const CollectionTile({
    super.key,
    required this.collection,
    required this.onTap,
    this.isSquareTile = false,
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
            child: isSquareTile
                ? _buildSquareTile(context, theme)
                : _buildListTile(context, theme),
          ),
          if (collection.category?.isNotEmpty == true)
            Positioned(
              top: 8,
              right: 8,
              child: _buildCategoryChip(theme),
            ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        _buildCollectionImage(theme),
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

  Widget _buildSquareTile(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            _buildCollectionImage(theme, size: 80),
            if (collection.isFavorite == true)
              Positioned(
                top: 6,
                right: 6,
                child: _buildFavoriteIcon(theme),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          collection.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        _buildItemCountBadge(theme),
      ],
    );
  }

  Widget _buildCollectionImage(ThemeData theme, {double size = 90}) {
    return circularImageWidget(collection.imageUrl, size: size);
  }

  Widget _buildCategoryChip(ThemeData theme) {
    return Chip(
      label: Text(
        collection.category!,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      backgroundColor: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      visualDensity: VisualDensity.compact,
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