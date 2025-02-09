import 'package:accollect/data/models/collection_ui_model.dart';
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        padding: const EdgeInsets.all(10),
        // Reduced padding
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(14), // Softer corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child:
            isSquareTile ? _buildSquareTile(context) : _buildListTile(context),
      ),
    );
  }

  Widget _buildListTile(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        _buildImage(width: screenWidth * 0.24, height: screenWidth * 0.24),
        // Bigger image
        const SizedBox(width: 10),
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
                  if (collection.isFavorite) _buildFavoriteIcon(),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                collection.description.isNotEmpty
                    ? collection.description
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            _buildImage(width: screenWidth * 0.32, height: screenWidth * 0.32),
            // Bigger image
            if (collection.isFavorite)
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

  Widget _buildImage({double width = 70, double height = 70}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          collection.imageUrl != null
              ? Image.network(
                  collection.imageUrl!,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _imagePlaceholder(width, height),
                )
              : _imagePlaceholder(width, height),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image, color: Colors.white, size: 32),
    );
  }

  Widget _buildItemCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        '${collection.itemCount}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
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