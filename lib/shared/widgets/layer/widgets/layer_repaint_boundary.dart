// Dart imports:
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/widgets.dart';

/// Renders a layer's untransformed content at [pixelRatio].
typedef LayerContentRenderer = Future<ui.Image> Function(double pixelRatio);

/// The repaint boundary a layer's content paints into — what
/// `Layer.captureAsPng` reads through `Layer.repaintBoundaryKey`.
///
/// While a paint layer is drawn from the shared raster cache its painter
/// draws nothing here, so a capture of the boundary would be blank;
/// [renderContent] then supplies the pixels from the layer's model instead.
/// It is `null` whenever the boundary holds the real paint.
class LayerRepaintBoundary extends RepaintBoundary {
  /// Creates the boundary for a layer's content.
  const LayerRepaintBoundary({
    super.key,
    required Widget super.child,
    this.renderContent,
  });

  /// Renders the content a capture should read while the boundary itself
  /// paints nothing, or `null` when the boundary is what to capture.
  final LayerContentRenderer? renderContent;
}
