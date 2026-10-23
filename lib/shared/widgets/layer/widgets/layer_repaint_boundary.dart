// Dart imports:
import 'dart:math' as math;
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '/features/text_editor/utils/rounded_background_painter.dart';

/// Renders a layer's untransformed content at [pixelRatio].
typedef LayerContentRenderer = Future<ui.Image> Function(double pixelRatio);

/// Renders a text layer's untransformed content at [pixelRatio] with the
/// entry of `TextLayer.highlights` at [highlightIndex] active.
typedef LayerHighlightRenderer =
    Future<ui.Image> Function(double pixelRatio, int highlightIndex);

/// Renders a text layer's untransformed content at [pixelRatio] with the
/// entry of `TextLayer.highlights` at [highlightIndex] active (none when it is
/// `null`) and only the first [revealedLength] UTF-16 code units of its text
/// drawn (all of it when it is `null`).
typedef LayerTextStateRenderer =
    Future<ui.Image> Function(
      double pixelRatio, {
      int? highlightIndex,
      int? revealedLength,
    });

/// The repaint boundary a layer's content paints into — what
/// `Layer.captureAsPng` reads through `Layer.repaintBoundaryKey`.
///
/// While a paint layer is drawn from the shared raster cache its painter
/// draws nothing here, so a capture of the boundary would be blank;
/// [renderContent] then supplies the pixels from the layer's model instead.
/// It is `null` whenever the boundary holds the real paint.
///
/// A text layer with `TextLayer.highlights`, or one that reveals its text,
/// paints whatever the playback position is on, so its capture comes from
/// [renderContent] too, with no highlight active and the whole text shown,
/// and [renderHighlight] and [renderTextState] draw the other states.
class LayerRepaintBoundary extends RepaintBoundary {
  /// Creates the boundary for a layer's content.
  const LayerRepaintBoundary({
    super.key,
    required Widget super.child,
    this.renderContent,
    this.renderHighlight,
    this.renderTextState,
  });

  /// Renders the content a capture should read instead of the boundary, or
  /// `null` when the boundary is what to capture.
  final LayerContentRenderer? renderContent;

  /// Renders a text layer with one of its highlights active, or `null` when
  /// the layer has no highlights.
  final LayerHighlightRenderer? renderHighlight;

  /// Renders a text layer in any state its highlights and its text reveal
  /// can be in, or `null` when the layer has neither.
  final LayerTextStateRenderer? renderTextState;

  @override
  RenderLayerRepaintBoundary createRenderObject(BuildContext context) {
    return RenderLayerRepaintBoundary();
  }
}

/// The render object of a [LayerRepaintBoundary].
class RenderLayerRepaintBoundary extends RenderRepaintBoundary {
  /// Captures the layer as it was last painted, or returns `null` when it has
  /// never been painted.
  ///
  /// [toImage] asserts that no paint is pending. A layer whose timeline
  /// window opens or closes while the editor is hidden, e.g. faded out by the
  /// route opened on done, is moved in the tree and then waits for a paint
  /// that only comes once the editor shows again. Moving it does not change
  /// what it paints, so its last paint is its content; release builds, which
  /// skip the assertion, capture exactly that.
  Future<ui.Image>? toImageOfLastPaint({double pixelRatio = 1.0}) {
    final offsetLayer = layer as OffsetLayer?;
    return offsetLayer?.toImage(captureBounds, pixelRatio: pixelRatio);
  }

  /// What a capture reads, in this boundary's coordinates: the boundary,
  /// grown by the text a box shows past itself
  /// (`TextLayerBoxOverflow.visible`).
  ///
  /// It grows by the same amount on both sides of an axis, so the image
  /// keeps the layer's center, where an export places it.
  Rect get captureBounds {
    var drawn = Offset.zero & size;
    void visit(RenderObject child) {
      final text = child is RenderCustomPaint ? child.painter : null;
      if (text is RoundedBackgroundTextPainter &&
          text.boxSize != null &&
          !text.clipToBox) {
        final glyphs = (text.hitBoxCorrectionOffset & text.painter.size)
            .inflate(text.outlineWidth);
        drawn = drawn.expandToInclude(
          MatrixUtils.transformRect(child.getTransformTo(this), glyphs),
        );
      }
      child.visitChildren(visit);
    }

    visitChildren(visit);
    final dx = math.max(math.max(-drawn.left, drawn.right - size.width), 0.0);
    final dy = math.max(math.max(-drawn.top, drawn.bottom - size.height), 0.0);
    return Rect.fromLTRB(-dx, -dy, size.width + dx, size.height + dy);
  }
}
