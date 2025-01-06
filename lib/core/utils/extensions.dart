import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension GoRouterOrderedParamsExtension on BuildContext {
  /// Replaces all segments that start with a colon ":" in [routePath]
  /// with consecutive values from [paramValues].
  ///
  /// Example:
  ///   routePath = "/collection/:colId/data/:someId"
  ///   paramValues = ["abc123", "def456"]
  ///
  ///   => final path = "/collection/abc123/data/def456"
  void goWithParams(String routePath, List<String> paramValues) {
    final segments = routePath.split('/');
    final placeholders = segments.where((s) => s.startsWith(':')).length;

    // If you want to enforce exact matching:
    if (paramValues.length != placeholders) {
      throw ArgumentError(
        'Expected $placeholders parameters, but got ${paramValues.length}.',
      );
    }

    int paramIndex = 0;
    for (int i = 0; i < segments.length; i++) {
      if (segments[i].startsWith(':')) {
        segments[i] = paramValues[paramIndex];
        paramIndex++;
      }
    }

    final finalPath = segments.join('/');
    go(finalPath);
  }
}
