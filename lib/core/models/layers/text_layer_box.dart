import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

/// Where the text of a [TextLayerBox] sits when it is shorter than the box.
enum TextLayerBoxVerticalAlign {
  /// The first line starts at the top of the box.
  top,

  /// The text is centered in the box.
  center,

  /// The last line ends at the bottom of the box.
  bottom;

  /// The share of the free height above the text: `0` at the top, `1` at
  /// the bottom.
  double get factor => switch (this) {
    TextLayerBoxVerticalAlign.top => 0,
    TextLayerBoxVerticalAlign.center => 0.5,
    TextLayerBoxVerticalAlign.bottom => 1,
  };
}

/// What a [TextLayerBox] does with text taller than the box.
enum TextLayerBoxOverflow {
  /// Lines below the box are cut off.
  clip,

  /// The text gets smaller until it fits, down to
  /// [TextLayerBox.minShrinkFactor] of its size; what still does not fit is
  /// cut off.
  shrink,
}

/// An edge or corner of a [TextLayerBox] that resizes it when dragged.
enum TextLayerBoxHandle {
  /// The left edge.
  left(-1, 0),

  /// The top edge.
  top(0, -1),

  /// The right edge.
  right(1, 0),

  /// The bottom edge.
  bottom(0, 1),

  /// The top left corner.
  topLeft(-1, -1),

  /// The top right corner.
  topRight(1, -1),

  /// The bottom left corner.
  bottomLeft(-1, 1),

  /// The bottom right corner.
  bottomRight(1, 1);

  const TextLayerBoxHandle(this.x, this.y);

  /// The side of the box the handle moves horizontally: `-1` left, `1`
  /// right, `0` neither.
  final int x;

  /// The side of the box the handle moves vertically: `-1` top, `1` bottom,
  /// `0` neither.
  final int y;

  /// The four edges, without the corners.
  static const List<TextLayerBoxHandle> edges = [left, top, right, bottom];

  /// Where the handle sits on a box, as an [Alignment].
  Alignment get alignment => Alignment(x.toDouble(), y.toDouble());
}

/// A fixed box a `TextLayer` lays its text out in, like a text field on a
/// form, instead of growing with its text.
///
/// The text wraps at the box width and never makes the layer taller. The
/// layer's background fills the whole box as one rectangle rather than
/// following the lines.
///
/// [size] is measured like `TextLayer.maxTextWidth`: in the layer's own
/// units, before its `Layer.scale`, so the box grows and shrinks with the
/// layer and its text.
@immutable
class TextLayerBox {
  /// Creates a [TextLayerBox].
  const TextLayerBox({
    required this.size,
    this.verticalAlign = TextLayerBoxVerticalAlign.top,
    this.overflow = TextLayerBoxOverflow.clip,
  });

  /// Creates a [TextLayerBox] from a map written by [toMap].
  ///
  /// Values this version does not know fall back to the defaults, so a layer
  /// saved by a newer version still loads.
  factory TextLayerBox.fromMap(Map<String, dynamic> map) {
    return TextLayerBox(
      size: Size(
        math.max(0, (map['width'] as num?)?.toDouble() ?? 0),
        math.max(0, (map['height'] as num?)?.toDouble() ?? 0),
      ),
      verticalAlign: TextLayerBoxVerticalAlign.values.firstWhere(
        (align) => align.name == map['verticalAlign'],
        orElse: () => TextLayerBoxVerticalAlign.top,
      ),
      overflow: TextLayerBoxOverflow.values.firstWhere(
        (overflow) => overflow.name == map['overflow'],
        orElse: () => TextLayerBoxOverflow.clip,
      ),
    );
  }

  /// The smallest share of its size [TextLayerBoxOverflow.shrink] makes the
  /// text.
  static const double minShrinkFactor = 0.25;

  /// The width and height of the box, before the layer's scale.
  final Size size;

  /// Where text shorter than the box sits.
  final TextLayerBoxVerticalAlign verticalAlign;

  /// What happens to text taller than the box.
  final TextLayerBoxOverflow overflow;

  /// A box that holds [text] the way a layer without a box shows it: laid
  /// out in [style], wrapped at [maxTextWidth], padded as the layer pads its
  /// text, and with room for an outline of [outlineWidth] and the shadows of
  /// [style].
  ///
  /// Measured in the layer's units, so [style] carries the font size before
  /// the layer's scale (`TextEditorConfigs.initFontSize` times
  /// `TextLayer.fontScale`). [slack] is added to the width and height, to
  /// absorb rounding at other scales, which could otherwise wrap the last
  /// word onto a new line.
  static TextLayerBox fit({
    required String text,
    required TextStyle style,
    double? maxTextWidth,
    TextAlign align = TextAlign.left,
    double outlineWidth = 0,
    double slack = 1,
    TextLayerBoxVerticalAlign verticalAlign = TextLayerBoxVerticalAlign.top,
    TextLayerBoxOverflow overflow = TextLayerBoxOverflow.shrink,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxTextWidth ?? double.infinity);
    final lineHeight = painter.preferredLineHeight;
    final textSize = painter.size;
    painter.dispose();

    // As `RoundedBackgroundText` pads a layer's text and makes room for its
    // effects.
    var effectX = outlineWidth;
    var effectY = outlineWidth;
    for (final shadow in style.shadows ?? const <Shadow>[]) {
      final blur = shadow.blurRadius > 0
          ? Shadow.convertRadiusToSigma(shadow.blurRadius) * 3
          : 0.0;
      effectX = math.max(effectX, outlineWidth + shadow.offset.dx.abs() + blur);
      effectY = math.max(effectY, outlineWidth + shadow.offset.dy.abs() + blur);
    }

    return TextLayerBox(
      size: Size(
        textSize.width + (lineHeight * 0.3 + effectX) * 2 + slack,
        textSize.height + (lineHeight * 0.1 + effectY) * 2 + slack,
      ),
      verticalAlign: verticalAlign,
      overflow: overflow,
    );
  }

  /// The smallest width and height [resize] leaves a box, before the
  /// layer's scale.
  static const Size minSize = Size(8, 8);

  /// The size and layer offset of a box of [size] whose [handle] was dragged
  /// by [delta], with the opposite edges staying where they are.
  ///
  /// [delta] is measured on the canvas, the way the layer [offset] is, and
  /// only its part along the dragged edges counts. The layer is drawn at
  /// [scale], turned by [rotation] and mirrored by [flipX] and [flipY], with
  /// [fractionalOffset] being the share of its size its offset is shifted by
  /// (`Offset(-0.5, -0.5)` for a layer placed by its center).
  static ({Size size, Offset offset}) resize({
    required Size size,
    required Offset offset,
    required TextLayerBoxHandle handle,
    required Offset delta,
    required double scale,
    double rotation = 0,
    bool flipX = false,
    bool flipY = false,
    Offset fractionalOffset = const Offset(-0.5, -0.5),
  }) {
    // The layer turns its content and then mirrors it.
    Offset mirror(Offset v) =>
        Offset(flipX ? -v.dx : v.dx, flipY ? -v.dy : v.dy);
    Offset turn(Offset v, double angle) {
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      return Offset(v.dx * cos - v.dy * sin, v.dx * sin + v.dy * cos);
    }

    final local = turn(mirror(delta), -rotation);
    final start = size * scale;
    final minimum = minSize * scale;
    final end = Size(
      handle.x == 0
          ? start.width
          : math.max(minimum.width, start.width + handle.x * local.dx),
      handle.y == 0
          ? start.height
          : math.max(minimum.height, start.height + handle.y * local.dy),
    );

    // The center follows half of the growth, towards the dragged edges.
    final grown = end - start as Offset;
    final centerShift = mirror(
      turn(Offset(handle.x * grown.dx / 2, handle.y * grown.dy / 2), rotation),
    );
    final anchor = fractionalOffset + const Offset(0.5, 0.5);
    Offset anchorShift(Size s) =>
        Offset(anchor.dx * s.width, anchor.dy * s.height);

    return (
      size: end / scale,
      offset: offset + anchorShift(start) + centerShift - anchorShift(end),
    );
  }

  /// Converts the box to a map, readable by [TextLayerBox.fromMap].
  Map<String, dynamic> toMap() => <String, dynamic>{
    'width': size.width,
    'height': size.height,
    'verticalAlign': verticalAlign.name,
    'overflow': overflow.name,
  };

  /// Creates a copy with the given fields replaced.
  TextLayerBox copyWith({
    Size? size,
    TextLayerBoxVerticalAlign? verticalAlign,
    TextLayerBoxOverflow? overflow,
  }) {
    return TextLayerBox(
      size: size ?? this.size,
      verticalAlign: verticalAlign ?? this.verticalAlign,
      overflow: overflow ?? this.overflow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextLayerBox &&
        other.size == size &&
        other.verticalAlign == verticalAlign &&
        other.overflow == overflow;
  }

  @override
  int get hashCode => Object.hash(size, verticalAlign, overflow);

  @override
  String toString() =>
      'TextLayerBox(size: $size, verticalAlign: ${verticalAlign.name}, '
      'overflow: ${overflow.name})';
}
