import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/widgets/common.dart';
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
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.blueAccent, width: 3)
                  : null,
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
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => imagePlaceholder(),
                      errorWidget: (context, url, error) => imagePlaceholder(),
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
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}
