// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

/// A stateless widget that applies a frosted glass effect to its child widget.
///
/// The frosted glass effect adds a semi-transparent overlay with optional
/// padding and border radius, enhancing the visual appearance of the child
/// widget in a subtle, stylish way.

class FrostedGlassEffect extends StatelessWidget {
  /// Creates a [FrostedGlassEffect].
  ///
  /// This widget wraps a [child] widget with a frosted glass effect, using a
  /// semi-transparent color overlay and optional padding and border radius.
  ///
  /// Example:
  /// ```
  /// FrostedGlassEffect(
  ///   child: Text('Hello, World!'),
  ///   color: Colors.black26,
  ///   radius: BorderRadius.circular(10),
  ///   padding: EdgeInsets.all(8),
  /// )
  /// ```
  const FrostedGlassEffect({
    super.key,
    required this.child,
    this.color = Colors.black26,
    this.radius,
    this.padding,
  });

  /// The child widget to which the frosted glass effect is applied.
  ///
  /// This widget is wrapped by the frosted glass effect, providing a stylish
  /// overlay that enhances the child's visual presentation.
  final Widget child;

  /// The optional padding inside the frosted glass effect.
  ///
  /// This padding adds space between the child widget and the borders of the
  /// frosted glass overlay, providing additional layout control.
  final EdgeInsets? padding;

  /// The optional border radius of the frosted glass effect.
  ///
  /// This radius defines the curvature of the frosted glass overlay's corners,
  /// allowing for a more rounded or angular appearance as desired.
  final BorderRadius? radius;

  /// The color used for the frosted glass overlay.
  ///
  /// This color provides the semi-transparent overlay effect, with a default
  /// value of `Colors.black26`, creating a subtle frosted look.
  final Color color;

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
