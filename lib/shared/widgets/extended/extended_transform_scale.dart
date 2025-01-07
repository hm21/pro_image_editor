// Flutter imports:
import 'package:flutter/widgets.dart';

/// [ExtendedTransformScale] is a stateful widget that allows
/// you to apply a scaling transform to a child widget.
/// This widget provides a method to update the scale factor,
/// allowing you to only rebuild the transform without affecting
/// the child widget.
///
/// This is useful for scenarios where you need to animate or
/// dynamically change the scale of a widget without triggering
/// a rebuild of the widget's children.
///
/// The [initScale] parameter sets the initial scale factor,
/// the [alignment] parameter defines the alignment of the scaled
/// child, and the [child] parameter is the widget to be scaled.
class ExtendedTransformScale extends StatefulWidget {
  /// Creates an instance of [ExtendedTransformScale].
  const ExtendedTransformScale({
    super.key,
    required this.initScale,
    required this.alignment,
    required this.child,
  });

  /// The widget to be scaled.
  final Widget child;

  /// The initial scale factor.
  final double initScale;

  /// The alignment of the scaled child widget.
  final Alignment alignment;

  @override
  State<ExtendedTransformScale> createState() => ExtendedTransformScaleState();
}

/// The state class for [ExtendedTransformScale], which manages the scale
/// transformation.
class ExtendedTransformScaleState extends State<ExtendedTransformScale> {
  /// The current scale factor applied to the child widget.
  late double scale;

  @override
  void initState() {
    super.initState();
    scale = widget.initScale;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      alignment: widget.alignment,
      child: widget.child,
    );
  }

  /// Updates the scale factor and triggers a rebuild of the transform.
  /// This does not rebuild the child widget, making it efficient for
  /// animations and dynamic scaling.
  ///
  /// [value] - The new scale factor.
  void setScale(double value) {
    setState(() {
      scale = value;
    });
  }
}
