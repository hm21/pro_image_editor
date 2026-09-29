// Dart imports:
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/widgets.dart';

/// Renders a layer's untransformed content at [pixelRatio].
typedef LayerContentRenderer = Future<ui.Image> Function(double pixelRatio);

/// Renders a text layer's untransformed content at [pixelRatio] with the
/// entry of `TextLayer.highlights` at [highlightIndex] active.
typedef LayerHighlightRenderer =
    Future<ui.Image> Function(double pixelRatio, int highlightIndex);

/// The repaint boundary a layer's content paints into — what
/// `Layer.captureAsPng` reads through `Layer.repaintBoundaryKey`.
///
/// While a paint layer is drawn from the shared raster cache its painter
/// draws nothing here, so a capture of the boundary would be blank;
/// [renderContent] then supplies the pixels from the layer's model instead.
/// It is `null` whenever the boundary holds the real paint.
///
/// A text layer with `TextLayer.highlights` paints whichever highlight the
/// playback position is on, so its capture comes from [renderContent] too,
/// with no highlight active, and [renderHighlight] draws each highlight.
class LayerRepaintBoundary extends RepaintBoundary {
  /// Creates the boundary for a layer's content.
  const LayerRepaintBoundary({
    super.key,
    required Widget super.child,
    this.renderContent,
    this.renderHighlight,
  });

  /// Renders the content a capture should read instead of the boundary, or
  /// `null` when the boundary is what to capture.
  final LayerContentRenderer? renderContent;

  /// Renders a text layer with one of its highlights active, or `null` when
  /// the layer has no highlights.
  final LayerHighlightRenderer? renderHighlight;
}
