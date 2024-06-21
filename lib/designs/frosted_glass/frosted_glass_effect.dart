// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

class FrostedGlassEffect extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? radius;
  final Color color;

  const FrostedGlassEffect({
    super.key,
    required this.child,
    this.color = Colors.black26,
    this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(100),
      clipBehavior: Clip.hardEdge,
      child: Container(
        color: color,
        padding: padding,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: child,
        ),
      ),
    );
  }
}
