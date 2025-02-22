import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadingBorderButton extends StatefulWidget {
  final String title;
  final Color color;
  final ValueListenable<bool> isExecuting;
  final VoidCallback? onPressed;

  const LoadingBorderButton({
    super.key,
    required this.title,
    required this.color,
    required this.isExecuting,
    required this.onPressed,
  });

  @override
  LoadingBorderButtonState createState() => LoadingBorderButtonState();
}

class LoadingBorderButtonState extends State<LoadingBorderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.5);
    final shadowColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.3);

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isExecuting,
      builder: (context, executing, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: executing
                ? Border.all(
                    width: _glowAnimation.value,
                    color: borderColor,
                  )
                : null,
            boxShadow: executing
                ? [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: _glowAnimation.value,
                      spreadRadius: 1.5,
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            onPressed: executing ? null : widget.onPressed,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: executing ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                if (executing)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
