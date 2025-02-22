import 'package:flutter/material.dart';

Widget imagePlaceholder(BuildContext context) {
  final theme = Theme.of(context);
  return Container(
    width: double.infinity,
    height: 300,
    color: theme.colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.image,
      color: theme.colorScheme.onSurfaceVariant,
      size: 50,
    ),
  );
}

Widget buildErrorState(String errorMessage) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

Widget buildEmptyState({
  required String title,
  String? description,
  IconData icon = Icons.sentiment_dissatisfied,
  VoidCallback? onActionPressed,
  String? actionLabel,
  required BuildContext context,
}) {
  final theme = Theme.of(context);

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child:
              Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 48),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        if (onActionPressed != null && actionLabel != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onActionPressed,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget circularImageWidget(String? imageUrl, {double size = 90}) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      // If the imageUrl is null or empty, just show placeholder
      if (imageUrl == null || imageUrl.trim().isEmpty) {
        return _buildPlaceholder(size, theme);
      }

      // Otherwise, show the network image with a loading builder + error builder
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,

          // Show a subtle placeholder or progress indicator while loading
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child; // Image is fully loaded
            }
            return _buildPlaceholder(size, theme);
          },

          // If an error occurs, show the placeholder
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(size, theme);
          },
        ),
      );
    },
  );
}

Widget _buildPlaceholder(double size, ThemeData theme) {
  return SizedBox(
    width: size,
    height: size,
    child: ClipOval(
      child: Container(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        child: Icon(
          Icons.image,
          color: theme.colorScheme.onSurfaceVariant,
          size: size * 0.4, // For example, 40 if size=100
        ),
      ),
    ),
  );
}

Widget buildCategoryChip(ThemeData theme, String text) {
  final isDarkMode = theme.brightness == Brightness.dark;

  return Chip(
    label: Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
      ),
    ),
    backgroundColor: isDarkMode
        ? theme.colorScheme.surfaceContainer
        : theme.colorScheme.secondaryContainer,
    visualDensity: VisualDensity.compact,
  );
}
