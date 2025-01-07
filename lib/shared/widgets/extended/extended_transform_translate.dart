// Flutter imports:
import 'package:flutter/widgets.dart';

/// [ExtendedTransformTranslate] is a stateful widget that allows
/// you to apply a translation transform to a child widget.
/// This widget provides a method to update the translation offset,
/// allowing you to only rebuild the transform without affecting
/// the child widget.
///
/// This is useful for scenarios where you need to animate or
/// dynamically change the position of a widget without triggering
/// a rebuild of the widget's children.
///
/// The [initOffset] parameter sets the initial translation offset,
/// and the [child] parameter is the widget to be translated.
class ExtendedTransformTranslate extends StatefulWidget {
  /// Creates an instance of [ExtendedTransformTranslate].
  ///
  /// [initOffset] is the initial translation offset.
  /// [child] is the widget to be translated.
  const ExtendedTransformTranslate({
    super.key,
    required this.initOffset,
    required this.child,
  });

  /// The widget to be translated.
  final Widget child;

  /// The initial translation offset.
  final Offset initOffset;

  @override
  State<ExtendedTransformTranslate> createState() =>
      ExtendedTransformTranslateState();
}

/// A [State] for managing the translation of a widget using
/// [Transform.translate].
class ExtendedTransformTranslateState
    extends State<ExtendedTransformTranslate> {
  /// The current translation offset.
  late Offset offset;

  @override
  void initState() {
    super.initState();
    offset = widget.initOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: widget.child,
    );
  }

  /// Updates the translation offset and triggers a rebuild of the transform.
  /// This does not rebuild the child widget, making it efficient for
  /// animations and dynamic position changes.
  ///
  /// [value] - The new translation offset.
  void setOffset(Offset value) {
    setState(() {
      offset = value;
    });
  }
}
