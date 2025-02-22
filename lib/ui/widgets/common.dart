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
      return ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _circularImagePlaceholder(size, context),
              )
            : _circularImagePlaceholder(size, context),
      );
    },
  );
}

Widget _circularImagePlaceholder(double size, BuildContext context) {
  final theme = Theme.of(context);
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.image,
      color: theme.colorScheme.onSurfaceVariant,
      size: 40,
    ),
  );
}
