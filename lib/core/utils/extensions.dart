import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension GoRouterOrderedParamsExtension on BuildContext {
  String _buildPathWithParams(String routePath, List<String> paramValues) {
    final segments = routePath.split('/');
    final placeholders = segments.where((s) => s.startsWith(':')).length;

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

    return segments.join('/');
  }

  /// Navigates to a route by replacing placeholders in [routePath] with [paramValues].
  void goWithParams(String routePath, List<String> paramValues) {
    final finalPath = _buildPathWithParams(routePath, paramValues);
    return go(finalPath);
  }

  /// Pushes a new route onto the stack by replacing placeholders in [routePath] with [paramValues].
  Future<T?> pushWithParams<T extends Object?>(
      String routePath, List<String> paramValues) {
    final finalPath = _buildPathWithParams(routePath, paramValues);
    return push(finalPath);
  }
}
