import 'package:accollect/data/models/item_ui_model.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Use Expanded to let the image take the available height
            // but still leave room for the text below
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _imagePlaceholder(),
                    errorWidget: (context, url, error) => _imagePlaceholder(),
                  ),
                ),
              ),
            ),
            // Give the text a fixed (or minimum) height or just a padded area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      color: Colors.grey[700],
      child: const Icon(Icons.image, color: Colors.white, size: 40),
    );
  }
}
