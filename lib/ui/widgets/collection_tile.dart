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
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(45),
                right: Radius.circular(14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: isSquareTile
                ? _buildSquareTile(context)
                : _buildListTile(context),
          ),
          if (collection.category != null && collection.category!.isNotEmpty)
            Positioned(
              top: 4,
              right: 4,
              child: Chip(
                label: Text(
                  collection.category!,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context) {
    return Row(
      children: [
        circularImageWidget(collection.imageUrl, size: 90),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (collection.isFavorite == true) _buildFavoriteIcon(),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                collection.description?.isNotEmpty == true
                    ? collection.description!
                    : 'No description',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Updated: ${_formatDate(collection.lastUpdated)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  _buildItemCountBadge(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSquareTile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            circularImageWidget(collection.imageUrl, size: 80),
            // ✅ Reused widget
            if (collection.isFavorite == true)
              Positioned(
                top: 6,
                right: 6,
                child: _buildFavoriteIcon(),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          collection.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        _buildItemCountBadge(),
      ],
    );
  }

  Widget _buildItemCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${collection.itemsCount}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFavoriteIcon() {
    return const Icon(Icons.star, color: Colors.yellow, size: 20);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
