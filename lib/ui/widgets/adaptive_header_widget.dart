import 'dart:ui' show lerpDouble;

import 'package:accollect/ui/widgets/common.dart';
import 'package:flutter/material.dart';

class AdaptiveHeader extends StatelessWidget {
  final double expandedPercentage;
  final ThemeData theme;
  final String title;
  final String? subTitle;
  final String? imageUrl;

  const AdaptiveHeader({
    super.key,
    required this.expandedPercentage,
    required this.theme,
    required this.title,
    this.subTitle,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final double imageSize = lerpDouble(20, 40, expandedPercentage)!;
    final TextStyle titleStyle = TextStyle.lerp(
      theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      expandedPercentage,
    )!;

    final TextStyle subTitleStyle = TextStyle.lerp(
      theme.textTheme.titleSmall,
      theme.textTheme.bodySmall,
      expandedPercentage,
    )!;

    return buildAdaptiveHeader(
      imageSize: imageSize,
      nameStyle: titleStyle,
      categoryStyle: subTitleStyle,
      theme: theme,
    );
  }

  Widget buildAdaptiveHeader({
    required double imageSize,
    required TextStyle nameStyle,
    required TextStyle categoryStyle,
    required ThemeData theme,
    VoidCallback? onMorePressed,
  }) {
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
                style: nameStyle,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subTitle ?? '',
                style: categoryStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
