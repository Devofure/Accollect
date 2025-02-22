import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'common.dart';

/// A header that grows/shrinks between two sizes (min -> max) as [expandedPercentage]
/// goes from 0.0 (fully collapsed) to 1.0 (fully expanded).
class AdaptiveHeader extends StatelessWidget {
  /// How “expanded” the header is, from 0 (collapsed) to 1 (expanded).
  final double expandedPercentage;

  final String title;
  final String? subTitle;
  final String? imageUrl;

  /// Optional min/max sizes you can easily tweak.
  final double minImageSize;
  final double maxImageSize;
  final double minTitleFontSize;
  final double maxTitleFontSize;
  final double minSubTitleFontSize;
  final double maxSubTitleFontSize;

  /// Theme is passed in to get colors, etc.
  final ThemeData theme;

  const AdaptiveHeader({
    super.key,
    required this.expandedPercentage,
    required this.title,
    this.subTitle,
    this.imageUrl,
    this.minImageSize = 24,
    this.maxImageSize = 56,
    this.minTitleFontSize = 16,
    this.maxTitleFontSize = 16,
    this.minSubTitleFontSize = 16,
    this.maxSubTitleFontSize = 12,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final double imageSize = lerpDouble(
      minImageSize,
      maxImageSize,
      expandedPercentage,
    )!;

    final double titleFontSize = lerpDouble(
      minTitleFontSize,
      maxTitleFontSize,
      expandedPercentage,
    )!;

    final double subTitleFontSize = lerpDouble(
      minSubTitleFontSize,
      maxSubTitleFontSize,
      expandedPercentage,
    )!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        circularImageWidget(
          imageUrl,
          size: imageSize,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subTitle != null && subTitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subTitle!,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: subTitleFontSize,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
