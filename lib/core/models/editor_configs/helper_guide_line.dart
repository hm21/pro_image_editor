// Flutter imports:
import 'package:flutter/widgets.dart';

/// Defines how the [HelperGuideLine.position] value is interpreted.
enum HelperGuidePositionMode {
  /// The position is an absolute coordinate in editor-body pixels, measured
  /// from the top-left corner of the editor body.
  absolute,

  /// The position is a normalized fraction (`0.0` – `1.0`) of the editor-body
  /// extent along the guide's axis (width for vertical guides, height for
  /// horizontal guides).
  normalized,
}

/// A single app-defined snapping/helper guide line for the main editor.
///
/// Custom guides participate in layer snapping just like the built-in center
/// and layer-alignment lines and are drawn while a layer snaps to them. Add
/// them through [HelperLineConfigs.customGuides].
///
/// Example:
/// ```dart
/// HelperLineConfigs(
///   customGuides: [
///     // A vertical guide at 25% of the editor width.
///     HelperGuideLine(
///       axis: Axis.vertical,
///       position: 0.25,
///       positionMode: HelperGuidePositionMode.normalized,
///     ),
///     // A horizontal guide 120px from the top.
///     HelperGuideLine(axis: Axis.horizontal, position: 120),
///   ],
/// )
/// ```
@immutable
class HelperGuideLine {
  /// Creates a custom guide line.
  const HelperGuideLine({
    required this.axis,
    required this.position,
    this.positionMode = HelperGuidePositionMode.absolute,
  });

  /// The orientation of the guide line.
  ///
  /// - [Axis.vertical] snaps layers horizontally (along the x-axis).
  /// - [Axis.horizontal] snaps layers vertically (along the y-axis).
  final Axis axis;

  /// The position of the guide along its axis.
  ///
  /// Interpreted according to [positionMode] - either absolute editor-body
  /// pixels or a normalized `0.0`-`1.0` fraction.
  final double position;

  /// How [position] is interpreted.
  final HelperGuidePositionMode positionMode;

  /// Resolves the guide to an absolute editor-body-space coordinate, given the
  /// current [editorSize].
  double resolvePosition(Size editorSize) {
    if (positionMode == HelperGuidePositionMode.absolute) return position;

    final extent = axis == Axis.vertical ? editorSize.width : editorSize.height;
    return position * extent;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HelperGuideLine &&
        other.axis == axis &&
        other.position == position &&
        other.positionMode == positionMode;
  }

  @override
  int get hashCode => Object.hash(axis, position, positionMode);
}
