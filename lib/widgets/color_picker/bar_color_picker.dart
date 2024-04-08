import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import 'color_picker_configs.dart';

/// A padding used to calculate bar height(thumbRadius * 2 - kBarPadding).
const _kBarPadding = 4;

/// A widget that allows users to pick colors from a gradient bar.
///
/// The `BarColorPicker` widget provides a horizontal or vertical bar with a thumb that users can drag to select a color from a gradient.
///
/// Example Usage:
/// ```dart
/// BarColorPicker(
///   pickMode: PickMode.color,
///   length: 200,
///   initialColor: Color(0xffff0000),
///   thumbColor: Colors.black,
///   colorListener: (colorValue) {
///     // Handle the selected color change here
///   },
/// )
/// ```
class BarColorPicker extends StatefulWidget {
  /// The pick mode, which determines the available color options.
  final PickMode pickMode;

  /// The width of the bar if it is horizontal, or the height if it is vertical.
  final double length;

  /// A listener that receives color pick events.
  final Function(int value) colorListener;

  /// The corner radius of the picker bar for each corner.
  final double cornerRadius;

  /// Specifies whether the bar is horizontal (`true`) or vertical (`false`).
  final bool horizontal;

  /// The fill color of the thumb.
  final Color thumbColor;

  /// The radius of the thumb.
  final double thumbRadius;

  /// The initial color to be displayed.
  final Color initialColor;

  /// Callback function that is called when the thumb position changes.
  final ValueChanged? onPositionChange;

  /// The initial position of the thumb in the bar. If not provided, it will be estimated based on the gradient and an initial color.
  final double? initPosition;

  /// Image editor configurations.
  final ProImageEditorConfigs configs;

  const BarColorPicker({
    super.key,
    this.pickMode = PickMode.color,
    this.horizontal = true,
    this.length = 200,
    this.cornerRadius = 0.0,
    this.thumbRadius = 6,
    this.initialColor = const Color(0xffff0000),
    this.thumbColor = Colors.black,
    this.onPositionChange,
    this.initPosition,
    required this.colorListener,
    required this.configs,
  });

  @override
  createState() => _BarColorPickerState();
}

class _BarColorPickerState extends State<BarColorPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  /// The current percentage position in the gradient.
  double percent = 0.0;

  /// List of colors used in the gradient.
  late List<Color> colors;

  /// Width of the color bar.
  late double barWidth;

  /// Height of the color bar.
  late double barHeight;

  @override
  void initState() {
    super.initState();
    // Initialize the 'colors' list and 'percent' based on 'pickMode'.
    switch (widget.pickMode) {
      case PickMode.color:
        colors = const [
          Color(0xff000000),
          Color(0xffffffff),
          Color(0xffff0000),
          Color(0xffffff00),
          Color(0xff00ff00),
          Color(0xff00ffff),
          Color(0xff0000ff),
          Color(0xffff00ff),
          Color(0xffff0000),
        ];
        break;
      case PickMode.grey:
        colors = const [Color(0xff000000), Color(0xffffffff)];
        break;
    }

    // Initialize 'percent' based on 'initPosition' or target 'initialColor'.
    percent = widget.initPosition ??
        _estimateColorPositionInGradient(colors, widget.initialColor);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Estimates the position of a color within the gradient.
  double _estimateColorPositionInGradient(
      List<Color> gradientColors, Color targetColor) {
    double minDistance = double.infinity;
    double estimatedPosition = 0.0;

    for (int i = 0; i < gradientColors.length - 1; i++) {
      Color color1 = gradientColors[i];
      Color color2 = gradientColors[i + 1];

      // Linear interpolation factor (t) that brings color1 towards color2
      double t = _findBestInterpolation(color1, color2, targetColor);

      // Interpolated color at position t
      Color interpolatedColor = Color.lerp(color1, color2, t)!;

      // Calculate distance from interpolated color to target color
      double distance = _calculateColorDistance(interpolatedColor, targetColor);

      if (distance < minDistance) {
        minDistance = distance;
        estimatedPosition = (i + t) / (gradientColors.length - 1);
      }
    }

    return estimatedPosition;
  }

  /// Finds the best interpolation factor to approximate a target color.
  double _findBestInterpolation(Color a, Color b, Color target) {
    // This function should return a value between 0 and 1, which is the best
    // interpolation factor (t) that brings color 'a' towards color 'b' to
    // approximate the target color. This can be a complex task depending on
    // how accurate you want it to be. A simple approach would be to try several
    // values of t and choose the one that results in a color closest to the target.
    // For more accuracy, more sophisticated methods may be used.

    double bestT = 0;
    double minDistance = double.infinity;

    for (double t = 0; t <= 1; t += 0.01) {
      Color interpolated = Color.lerp(a, b, t)!;
      double distance = _calculateColorDistance(interpolated, target);
      if (distance < minDistance) {
        minDistance = distance;
        bestT = t;
      }
    }

    return bestT;
  }

  /// Calculates the Euclidean distance between two colors.
  double _calculateColorDistance(Color color1, Color color2) {
    num r = color1.red - color2.red;
    num g = color1.green - color2.green;
    num b = color1.blue - color2.blue;

    return sqrt(r * r + g * g + b * b);
  }

  /// Gets the color at a specific position within the gradient.
  Color _getColorAtPosition(Gradient gradient, double position) {
    // Ensure the position is within the valid range
    widget.onPositionChange?.call(position);
    position = position.clamp(0.0, 1.0);

    if (position < 0) {
      return colors.first;
    } else if (position >= 1) {
      return colors.last;
    }

    if (colors.isEmpty) {
      throw ArgumentError("The colors list must not be empty.");
    } else if (colors.length == 1) {
      return colors.first;
    }

    final int segmentCount = colors.length - 1;
    final double segmentWidth = 1.0 / segmentCount;

    final int startIndex = (position / segmentWidth).floor();
    final int endIndex = startIndex + 1;

    final double t = (position - startIndex * segmentWidth) / segmentWidth;

    return Color.lerp(colors[startIndex], colors[endIndex], t)!;
  }

  @override
  Widget build(BuildContext context) {
    final thumbRadius = widget.thumbRadius;
    final horizontal = widget.horizontal;

    Gradient gradient;

    bool isSimpleEditor =
        widget.configs.imageEditorTheme.editorMode == ThemeEditorMode.simple;

    double borderWidth =
        widget.configs.designMode == ImageEditorDesignModeE.cupertino &&
                !isSimpleEditor
            ? 2
            : 0;
    double left, top;
    double? thumbLeft, thumbTop;

    if (horizontal) {
      barWidth = widget.length;
      barHeight = widget.thumbRadius * 2 - _kBarPadding;

      thumbLeft = barWidth * percent;
      gradient = LinearGradient(colors: colors);

      left = thumbRadius;
      top = (thumbRadius * 2 - barHeight) / 2;
    } else {
      barWidth = widget.thumbRadius * 2 - _kBarPadding;
      barHeight = widget.length;

      thumbTop = barHeight * percent;
      gradient = LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter);

      left = (thumbRadius * 2 - barWidth) / 2;
      top = thumbRadius;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanDown: (details) =>
            handleTouch(details.globalPosition, context, gradient),
        onPanStart: (details) =>
            handleTouch(details.globalPosition, context, gradient),
        onPanUpdate: (details) =>
            handleTouch(details.globalPosition, context, gradient),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 5),
          child: Stack(
            children: [
              _buildFrame(
                horizontal: horizontal,
                thumbRadius: thumbRadius,
                borderWidth: borderWidth,
              ),
              _buildContent(
                top: top,
                left: left,
                borderWidth: borderWidth,
                gradient: gradient,
              ),
              if (isSimpleEditor)
                _buildThumb(
                  borderWidth: borderWidth,
                  thumbRadius: thumbRadius,
                  thumbLeft: thumbLeft,
                  thumbTop: thumbTop,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumb({
    double? thumbLeft,
    double? thumbTop,
    required double thumbRadius,
    required double borderWidth,
  }) {
    return Positioned(
      left: borderWidth / 2 + (thumbLeft ?? 0),
      top: thumbTop,
      child: Container(
        padding: EdgeInsets.zero,
        width: thumbRadius * 2,
        height: thumbRadius * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(thumbRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x45000000),
              spreadRadius: 2,
              blurRadius: 3,
            )
          ],
          color: widget.thumbColor,
        ),
      ),
    );
  }

  Widget _buildContent({
    required double top,
    required double left,
    required double borderWidth,
    Gradient? gradient,
  }) {
    return Positioned(
      left: left - borderWidth / 2,
      top: top,
      child: Container(
        padding: EdgeInsets.zero,
        width: barWidth + borderWidth * 2,
        height: barHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          border: borderWidth != 0
              ? Border.all(
                  color: Colors.white,
                  width: borderWidth,
                )
              : null,
          gradient: gradient,
        ),
      ),
    );
  }

  Widget _buildFrame({
    required bool horizontal,
    required double thumbRadius,
    required double borderWidth,
  }) {
    double frameWidth, frameHeight;
    if (horizontal) {
      frameWidth = barWidth + thumbRadius * 2 + borderWidth;
      frameHeight = thumbRadius * 2;
    } else {
      frameWidth = thumbRadius * 2 + borderWidth;
      frameHeight = barHeight + thumbRadius * 2;
    }
    return SizedBox(width: frameWidth, height: frameHeight);
  }

  /// calculate colors picked from palette and update our states.
  void handleTouch(
      Offset globalPosition, BuildContext context, Gradient gradient) {
    var box = context.findRenderObject() as RenderBox;
    var localPosition = box.globalToLocal(globalPosition);
    double percent;
    if (widget.horizontal) {
      percent = (localPosition.dx - widget.thumbRadius) / barWidth;
    } else {
      percent = (localPosition.dy - widget.thumbRadius) / barHeight;
    }
    percent = min(max(0.0, percent), 1.0);
    setState(() {
      this.percent = percent;
    });
    switch (widget.pickMode) {
      case PickMode.color:
        final Color colorAtPosition = _getColorAtPosition(gradient, percent);
        widget.colorListener(colorAtPosition.value);
        break;
      case PickMode.grey:
        final channel = (0xff * percent).toInt();
        widget.colorListener(
            Color.fromARGB(0xff, channel, channel, channel).value);
        break;
    }
  }
}
