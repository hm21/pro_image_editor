import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Creates a separate display list for its child.
///
/// This render object creates a separate display list for its child, which
/// can improve performance if the subtree repaints at different times than
/// the surrounding parts of the tree. Specifically, when the child does not
/// repaint but its parent does, we can re-use the display list we recorded
/// previously. Similarly, when the child repaints but the surround tree does
/// not, we can re-record its display list without re-recording the display list
/// for the surround tree.
///
/// In some cases, it is necessary to place _two_ (or more) repaint boundaries
/// to get a useful effect. Consider, for example, an e-mail application that
/// shows an unread count and a list of e-mails. Whenever a new e-mail comes in,
/// the list would update, but so would the unread count. If only one of these
/// two parts of the application was behind a repaint boundary, the entire
/// application would repaint each time. On the other hand, if both were behind
/// a repaint boundary, a new e-mail would only change those two parts of the
/// application and the rest of the application would not repaint.
///
/// To tell if a particular RenderRepaintBoundary is useful, run your
/// application in debug mode, interacting with it in typical ways, and then
/// call [debugDumpRenderTree]. Each RenderRepaintBoundary will include the
/// ratio of cases where the repaint boundary was useful vs the cases where it
/// was not. These counts can also be inspected programmatically using
/// [debugAsymmetricPaintCount] and [debugSymmetricPaintCount] respectively.
class ExtendedRenderRepaintBoundary extends RenderProxyBox {
  /// Creates a repaint boundary around [child].
  ExtendedRenderRepaintBoundary({RenderBox? child}) : super(child);

  @override
  bool get isRepaintBoundary => true;

  /// Capture an image of the current state of this render object and its
  /// children.
  ///
  /// The returned [ui.Image] has uncompressed raw RGBA bytes in the dimensions
  /// of the render object, multiplied by the [pixelRatio].
  ///
  /// To use [toImage], the render object must have gone through the paint phase
  /// (i.e. [debugNeedsPaint] must be false).
  ///
  /// The [pixelRatio] describes the scale between the logical pixels and the
  /// size of the output image. It is independent of the
  /// [dart:ui.FlutterView.devicePixelRatio] for the device, so specifying 1.0
  /// (the default) will give you a 1:1 mapping between logical pixels and the
  /// output pixels in the image.
  ///
  /// {@tool snippet}
  ///
  /// The following is an example of how to go from a `GlobalKey` on a
  /// `RepaintBoundary` to a PNG:
  ///
  /// ```dart
  /// class PngHome extends StatefulWidget {
  ///   const PngHome({super.key});
  ///
  ///   @override
  ///   State<PngHome> createState() => _PngHomeState();
  /// }
  ///
  /// class _PngHomeState extends State<PngHome> {
  ///   GlobalKey globalKey = GlobalKey();
  ///
  ///   Future<void> _capturePng() async {
  ///     final RenderRepaintBoundary boundary =
  /// globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  ///     final ui.Image image = await boundary.toImage();
  ///     final ByteData? byteData =
  /// await image.toByteData(format: ui.ImageByteFormat.png);
  ///     final Uint8List pngBytes = byteData!.buffer.asUint8List();
  ///     print(pngBytes);
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return RepaintBoundary(
  ///       key: globalKey,
  ///       child: Center(
  ///         child: TextButton(
  ///           onPressed: _capturePng,
  ///           child: const Text('Hello World', textDirection:
  /// TextDirection.ltr),
  ///         ),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [OffsetLayer.toImage] for a similar API at the layer level.
  ///  * [dart:ui.Scene.toImage] for more information about the image returned.
  Future<ui.Image> toImage({
    Rect? rect,
    double pixelRatio = 1.0,
  }) {
    assert(!debugNeedsPaint);
    final OffsetLayer offsetLayer = layer! as OffsetLayer;
    return offsetLayer.toImage(
      rect ?? (Offset.zero & size),
      pixelRatio: pixelRatio,
    );
  }

  /// Capture an image of the current state of this render object and its
  /// children synchronously.
  ///
  /// The returned [ui.Image] has uncompressed raw RGBA bytes in the dimensions
  /// of the render object, multiplied by the [pixelRatio].
  ///
  /// To use [toImageSync], the render object must have gone through the paint
  /// phase
  /// (i.e. [debugNeedsPaint] must be false).
  ///
  /// The [pixelRatio] describes the scale between the logical pixels and the
  /// size of the output image. It is independent of the
  /// [dart:ui.FlutterView.devicePixelRatio] for the device, so specifying 1.0
  /// (the default) will give you a 1:1 mapping between logical pixels and the
  /// output pixels in the image.
  ///
  /// This API functions like [toImage], except that rasterization begins
  /// eagerly
  /// on the raster thread and the image is returned before this is completed.
  ///
  /// {@tool snippet}
  ///
  /// The following is an example of how to go from a `GlobalKey` on a
  /// `RepaintBoundary` to an image handle:
  ///
  /// ```dart
  /// class ImageCaptureHome extends StatefulWidget {
  ///   const ImageCaptureHome({super.key});
  ///
  ///   @override
  ///   State<ImageCaptureHome> createState() => _ImageCaptureHomeState();
  /// }
  ///
  /// class _ImageCaptureHomeState extends State<ImageCaptureHome> {
  ///   GlobalKey globalKey = GlobalKey();
  ///
  ///   void _captureImage() {
  ///     final RenderRepaintBoundary boundary =
  /// globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  ///     final ui.Image image = boundary.toImageSync();
  ///     print('Image dimensions: ${image.width}x${image.height}');
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return RepaintBoundary(
  ///       key: globalKey,
  ///       child: Center(
  ///         child: TextButton(
  ///           onPressed: _captureImage,
  ///           child: const Text('Hello World', textDirection:
  /// TextDirection.ltr),
  ///         ),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [OffsetLayer.toImageSync] for a similar API at the layer level.
  ///  * [dart:ui.Scene.toImageSync] for more information about the image
  /// returned.
  ui.Image toImageSync({double pixelRatio = 1.0}) {
    assert(!debugNeedsPaint);
    final OffsetLayer offsetLayer = layer! as OffsetLayer;
    return offsetLayer.toImageSync(Offset.zero & size, pixelRatio: pixelRatio);
  }

  /// The number of times that this render object repainted at the same time as
  /// its parent. Repaint boundaries are only useful when the parent and child
  /// paint at different times. When both paint at the same time, the repaint
  /// boundary is redundant, and may be actually making performance worse.
  ///
  /// Only valid when asserts are enabled. In release builds, always returns
  /// zero.
  ///
  /// Can be reset using [debugResetMetrics]. See [debugAsymmetricPaintCount]
  /// for the corresponding count of times where only the parent or only the
  /// child painted.
  int get debugSymmetricPaintCount => _debugSymmetricPaintCount;
  int _debugSymmetricPaintCount = 0;

  /// The number of times that either this render object repainted without the
  /// parent being painted, or the parent repainted without this object being
  /// painted. When a repaint boundary is used at a seam in the render tree
  /// where the parent tends to repaint at entirely different times than the
  /// child, it can improve performance by reducing the number of paint
  /// operations that have to be recorded each frame.
  ///
  /// Only valid when asserts are enabled. In release builds, always returns
  /// zero.
  ///
  /// Can be reset using [debugResetMetrics]. See [debugSymmetricPaintCount] for
  /// the corresponding count of times where both the parent and the child
  /// painted together.
  int get debugAsymmetricPaintCount => _debugAsymmetricPaintCount;
  int _debugAsymmetricPaintCount = 0;

  /// Resets the [debugSymmetricPaintCount] and [debugAsymmetricPaintCount]
  /// counts to zero.
  ///
  /// Only valid when asserts are enabled. Does nothing in release builds.
  void debugResetMetrics() {
    assert(() {
      _debugSymmetricPaintCount = 0;
      _debugAsymmetricPaintCount = 0;
      return true;
    }());
  }

  @override
  void debugRegisterRepaintBoundaryPaint(
      {bool includedParent = true, bool includedChild = false}) {
    assert(() {
      if (includedParent && includedChild) {
        _debugSymmetricPaintCount += 1;
      } else {
        _debugAsymmetricPaintCount += 1;
      }
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    bool inReleaseMode = true;
    assert(() {
      inReleaseMode = false;
      final int totalPaints =
          debugSymmetricPaintCount + debugAsymmetricPaintCount;
      if (totalPaints == 0) {
        properties.add(MessageProperty(
            'usefulness ratio', 'no metrics collected yet (never painted)'));
      } else {
        final double fraction = debugAsymmetricPaintCount / totalPaints;
        final String diagnosis = switch (fraction) {
          _ when totalPaints < 5 =>
            'insufficient data to draw conclusion (less than five repaints)',
          > 0.9 =>
            'this is an outstandingly useful repaint boundary and should '
                'definitely be kept',
          > 0.5 => 'this is a useful repaint boundary and should be kept',
          > 0.3 =>
            'this repaint boundary is probably useful, but maybe it would be '
                'more useful in tandem with adding more repaint boundaries '
                'elsewhere',
          > 0.1 =>
            'this repaint boundary does sometimes show value, though currently '
                'not that often',
          _ when debugAsymmetricPaintCount > 0 =>
            'this repaint boundary is not very effective and should probably '
                'be removed',
          _ =>
            'this repaint boundary is astoundingly ineffectual and should be '
                'removed',
        };

        properties
          ..add(
            PercentProperty(
              'metrics',
              fraction,
              unit: 'useful',
              tooltip:
                  '$debugSymmetricPaintCount bad vs $debugAsymmetricPaintCount '
                  'good',
            ),
          )
          ..add(
            MessageProperty('diagnosis', diagnosis),
          );
      }
      return true;
    }());
    if (inReleaseMode) {
      properties.add(DiagnosticsNode.message(
          '(run in debug mode to collect repaint boundary statistics)'));
    }
  }
}
