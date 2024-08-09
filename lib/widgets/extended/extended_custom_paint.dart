// Flutter imports:
import 'package:flutter/widgets.dart';

/// [ExtendedCustomPaint] is a stateful widget that allows you to use
/// custom painting within a widget. It extends the functionality of
/// [CustomPaint] by providing methods to update the painting properties
/// without rebuilding the child widget.
///
/// This is useful for scenarios where you need to dynamically update
/// painting properties such as the [painter], [foregroundPainter],
/// [isComplex], and [willChange] flags without affecting the child widget.
///
/// The [initIsComplex] and [initWillChange] parameters set the initial values
/// for the respective properties.
/// The [initForegroundPainter] and [initPainter] parameters set the initial
/// custom painters.
/// The [child] parameter is the widget to be painted on.
class ExtendedCustomPaint extends StatefulWidget {
  /// A widget that extends [CustomPaint] with additional customization options.
  const ExtendedCustomPaint({
    super.key,
    this.initIsComplex = false,
    this.initWillChange = false,
    this.initForegroundPainter,
    this.initPainter,
    required this.child,
  });

  /// Initial value for whether the painting is complex.
  final bool initIsComplex;

  /// Initial value for whether the painting will change.
  final bool initWillChange;

  /// Initial custom painter for the foreground.
  final CustomPainter? initForegroundPainter;

  /// Initial custom painter.
  final CustomPainter? initPainter;

  /// The widget to be painted on.
  final Widget child;

  @override
  State<ExtendedCustomPaint> createState() => ExtendedCustomPaintState();
}

/// The state for [ExtendedCustomPaint], managing the painting logic and
/// properties.
class ExtendedCustomPaintState extends State<ExtendedCustomPaint> {
  /// Indicates whether the painting is complex.
  late bool isComplex;

  /// Determines if the painting will change.
  late bool willChange;

  /// The painter used for drawing on the foreground.
  late CustomPainter? foregroundPainter;

  /// The painter used for drawing on the background.
  late CustomPainter? painter;

  @override
  void initState() {
    isComplex = widget.initIsComplex;
    willChange = widget.initWillChange;
    foregroundPainter = widget.initForegroundPainter;
    painter = widget.initPainter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      isComplex: isComplex,
      willChange: willChange,
      foregroundPainter: foregroundPainter,
      painter: painter,
      child: widget.child,
    );
  }

  /// Updates the properties of the [CustomPaint] widget and triggers a
  /// rebuild of the painting without affecting the child widget.
  ///
  /// [isComplex] - Optional new value for whether the painting is complex.
  /// [willChange] - Optional new value for whether the painting will change.
  /// [foregroundPainter] - Optional new foreground painter.
  /// [painter] - Optional new painter.
  void update({
    bool? isComplex,
    bool? willChange,
    CustomPainter? foregroundPainter,
    CustomPainter? painter,
  }) {
    setState(() {
      if (isComplex != null) this.isComplex = isComplex;
      if (willChange != null) this.willChange = willChange;
      if (foregroundPainter != null) this.foregroundPainter = foregroundPainter;
      if (painter != null) this.painter = painter;
    });
  }

  /// Updates the [willChange] property and triggers a rebuild.
  /// This does not rebuild the child widget.
  ///
  /// [value] - The new value for [willChange].
  void setWillChange(bool value) {
    setState(() {
      willChange = value;
    });
  }

  /// Updates the [isComplex] property and triggers a rebuild.
  /// This does not rebuild the child widget.
  ///
  /// [value] - The new value for [isComplex].
  void setIsComplex(bool value) {
    setState(() {
      isComplex = value;
    });
  }

  /// Updates the [foregroundPainter] property and triggers a rebuild.
  /// This does not rebuild the child widget.
  ///
  /// [value] - The new [foregroundPainter].
  void setForegroundPainter(CustomPainter? value) {
    setState(() {
      foregroundPainter = value;
    });
  }

  /// Updates the [painter] property and triggers a rebuild.
  /// This does not rebuild the child widget.
  ///
  /// [value] - The new [painter].
  void setPainter(CustomPainter? value) {
    setState(() {
      painter = value;
    });
  }
}
