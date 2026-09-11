// Dart imports:
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '/core/models/layers/layer.dart';

/// A contiguous z-run of paint layers that is drawn from one cached image.
///
/// Runs never span another layer type: a text or sticker layer that sits
/// between two drawings splits them into two runs, so the stacking order of
/// everything on the canvas stays exactly what it was with live rendering.
@immutable
class PaintLayerRasterRun {
  /// Creates a run.
  const PaintLayerRasterRun({
    required this.layers,
    required this.insertIndex,
    required this.key,
    required this.bounds,
  });

  /// The paint layers of this run, bottom-most first.
  final List<PaintLayer> layers;

  /// The index in the editor's layer list at which the first member sits.
  ///
  /// The cached image is inserted right before that member so it paints at
  /// the run's z-position.
  final int insertIndex;

  /// Identifies the exact pixels of this run.
  ///
  /// It encodes the pixel ratio and every property that changes how a member
  /// paints — geometry, opacity, stroke set — but not the timeline window,
  /// so retiming a layer keeps its raster.
  final String key;

  /// The area the image covers, in editor body coordinates (logical pixels).
  final Rect bounds;

  /// The ids of the member layers.
  Iterable<String> get layerIds => layers.map((layer) => layer.id);
}

/// The result of [PaintLayerRasterCache.plan]: which layers the cache may
/// draw, grouped into runs.
@immutable
class PaintLayerRasterPlan {
  /// Creates a plan.
  const PaintLayerRasterPlan({required this.runs});

  /// A plan that caches nothing.
  static const PaintLayerRasterPlan none = PaintLayerRasterPlan(runs: []);

  /// The cacheable runs, in z-order.
  final List<PaintLayerRasterRun> runs;
}

/// Draws static paint layers from cached images instead of re-stroking their
/// paths on every frame.
///
/// Rendering a paint layer costs the engine a full rasterization of its path
/// per frame. Nothing about that is cached between frames, so a canvas with a
/// few hundred strokes re-renders all of them whenever anything on it changes,
/// which on a video canvas is every frame. That cost scales with the amount of
/// ink, not with the layer count, and it is the same whether the strokes live
/// in one merged layer or in one layer each.
///
/// This cache composites consecutive static paint layers into a single
/// [ui.Image] once and lets the editor draw that image until a member
/// changes. Which layers qualify is decided per build by [plan]: a layer that
/// is selected or being transformed, one that is mid-animation, one outside
/// its timeline window, and one whose appearance the composite could not
/// reproduce exactly stay live. Layers keep their widgets either way — the
/// cache only replaces their paint, never their hit-testing, selection or
/// keys — so the editor behaves the same with it enabled.
///
/// Rasterization runs asynchronously. Until an image lands, the run renders
/// live, so the canvas is never blank and a moved layer is pixel-exact the
/// moment it is released; the cached copy takes over a frame or two later.
class PaintLayerRasterCache extends ChangeNotifier {
  /// Creates a cache.
  PaintLayerRasterCache({
    this.maxPixels = 8 * 1024 * 1024,
    this.maxTotalPixels = 16 * 1024 * 1024,
    this.maxImages = 4,
    this.maxDimension = 4096,
  });

  /// The pixel budget of a single run's image.
  ///
  /// A run whose bounds exceed it at the current pixel ratio is not cached and
  /// renders live. The default of 8 M pixels is 32 MB of RGBA — three times a
  /// full-screen canvas on a 3× phone (about 2.5 M pixels), so a run that
  /// spills past the canvas still fits while a pathological one cannot claim
  /// a giant texture.
  final int maxPixels;

  /// The pixel budget of all kept images together.
  ///
  /// Scrubbing back and forth across a layer's timeline edge alternates
  /// between two run keys; keeping a few recent images avoids re-rendering
  /// each time. The oldest images are disposed first once the total goes
  /// over this budget (64 MB of RGBA by default) or over [maxImages].
  final int maxTotalPixels;

  /// The most images kept at once, whatever their size.
  final int maxImages;

  /// The longest side an image may have, in device pixels.
  ///
  /// A run whose image would be wider or taller than this at the current
  /// pixel ratio is not cached, even when it fits [maxPixels]: the GPU refuses
  /// textures beyond its limit, and Flutter does not expose that limit. 4096
  /// is what older mobile GPUs guarantee; a run only gets that large when its
  /// layers spill far past the canvas.
  final int maxDimension;

  final Map<String, ui.Image> _images = <String, ui.Image>{};
  final List<String> _recentKeys = <String>[];

  /// Runs whose render failed. They render live and are not retried: `ensure`
  /// runs on every build, so without this a run the GPU cannot render — one
  /// past its texture limit, say — would be attempted again on every frame,
  /// each attempt as expensive as a live frame and each reported as an error.
  /// A key stops mattering once any member changes, so the set is small and
  /// bounded anyway.
  final Set<String> _failedKeys = <String>{};
  static const int _maxFailedKeys = 32;

  /// The key being rendered right now. Only one image renders at a time: a
  /// burst of changes — every pointer move of an erase, say — would otherwise
  /// queue a render per change, each as expensive as a live frame. A request
  /// that arrives while busy just marks [_hasPendingRequest]; once the current
  /// render lands, listeners are told and re-plan against the latest state.
  String? _inFlightKey;
  bool _hasPendingRequest = false;
  bool _isDisposed = false;

  /// Whether [layer] can be drawn from a cached raster at [playTime].
  ///
  /// [excludedIds] are layers the caller wants live regardless — the selected
  /// and interacting ones. A layer with a timeline animation stays live even
  /// outside its animation window, because it would otherwise flip between
  /// cached and live at every window edge; the same goes for the legacy
  /// enter/exit fade.
  static bool isCacheable(
    Layer layer, {
    required Set<String> excludedIds,
    required Duration? playTime,
    required PaintEditorConfigs paintEditorConfigs,
  }) {
    if (layer is! PaintLayer) return false;
    if (excludedIds.contains(layer.id)) return false;
    if (layer.isCensor) return false;
    if (layer.boxConstraints != null) return false;
    if (layer.animations.isNotEmpty) return false;
    if (_isPositive(layer.enterDuration) || _isPositive(layer.exitDuration)) {
      return false;
    }
    if (layer.transitionBuilder != null) return false;
    if (playTime != null) {
      final start = layer.startTime;
      final end = layer.endTime;
      if (start != null && playTime < start) return false;
      if (end != null && playTime > end) return false;
    }
    // A merged layer with a layer opacity below 1 fades the composed stack
    // through an Opacity widget; reproducing that needs an offscreen per
    // layer, which is the cost this cache exists to avoid.
    if (layer.items.length > 1 && layer.opacity < 1.0) return false;
    for (final item in layer.items) {
      // A custom builder may draw anything; its opacity path goes through an
      // Opacity widget as well.
      if (paintEditorConfigs.customPathBuilders.containsKey(item.mode)) {
        return false;
      }
    }
    return true;
  }

  static bool _isPositive(Duration? duration) =>
      duration != null && duration > Duration.zero;

  /// Groups the cacheable members of [layers] into runs.
  ///
  /// [editorBodySize] and [fractionalOffset] place each layer the way
  /// `LayerWidget` does; [pixelRatio] is the device pixel ratio the images are
  /// rendered at. A run whose image would exceed [maxPixels] is left out, and
  /// so is everything beyond [maxImages] runs, so the cache never holds more
  /// than it is allowed to.
  PaintLayerRasterPlan plan({
    required List<Layer> layers,
    required Set<String> excludedIds,
    required Duration? playTime,
    required Size editorBodySize,
    required Offset fractionalOffset,
    required double pixelRatio,
    required PaintEditorConfigs paintEditorConfigs,
  }) {
    final runs = <PaintLayerRasterRun>[];
    var members = <PaintLayer>[];
    var insertIndex = 0;

    void flush() {
      if (members.isEmpty) return;
      final run = _buildRun(
        members,
        insertIndex: insertIndex,
        editorBodySize: editorBodySize,
        fractionalOffset: fractionalOffset,
        pixelRatio: pixelRatio,
      );
      if (run != null && runs.length < maxImages) runs.add(run);
      members = <PaintLayer>[];
    }

    for (var i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final cacheable = isCacheable(
        layer,
        excludedIds: excludedIds,
        playTime: playTime,
        paintEditorConfigs: paintEditorConfigs,
      );
      if (!cacheable) {
        flush();
        continue;
      }
      if (members.isEmpty) insertIndex = i;
      members.add(layer as PaintLayer);
    }
    flush();

    return PaintLayerRasterPlan(runs: runs);
  }

  PaintLayerRasterRun? _buildRun(
    List<PaintLayer> members, {
    required int insertIndex,
    required Size editorBodySize,
    required Offset fractionalOffset,
    required double pixelRatio,
  }) {
    Rect? bounds;
    final keyBuffer = StringBuffer()
      ..write(pixelRatio.toStringAsFixed(3))
      ..write('|')
      ..write(fractionalOffset.dx)
      ..write(',')
      ..write(fractionalOffset.dy)
      ..write('|')
      ..write(editorBodySize.width)
      ..write('x')
      ..write(editorBodySize.height);

    for (final layer in members) {
      final rect = layerBounds(
        layer,
        editorBodySize: editorBodySize,
        fractionalOffset: fractionalOffset,
      );
      bounds = bounds == null ? rect : bounds.expandToInclude(rect);
      keyBuffer
        ..write('|')
        ..write(layerKey(layer));
    }
    if (bounds == null || bounds.isEmpty) return null;

    // Snap to whole logical pixels so the image maps 1:1 onto the screen.
    final snapped = Rect.fromLTRB(
      bounds.left.floorToDouble(),
      bounds.top.floorToDouble(),
      bounds.right.ceilToDouble(),
      bounds.bottom.ceilToDouble(),
    );
    final width = (snapped.width * pixelRatio).ceil();
    final height = (snapped.height * pixelRatio).ceil();
    final pixels = width * height;
    if (pixels <= 0 || pixels > maxPixels) return null;
    if (width > maxDimension || height > maxDimension) return null;

    return PaintLayerRasterRun(
      layers: List<PaintLayer>.unmodifiable(members),
      insertIndex: insertIndex,
      key: keyBuffer.toString(),
      bounds: snapped,
    );
  }

  /// The part of a run key contributed by [layer]: everything that changes
  /// its pixels, nothing that does not.
  ///
  /// Stroke content is described by its shape parameters and point counts
  /// rather than hashed point-by-point: strokes are never edited in place —
  /// the paint editor hands back new layers — and the partial eraser only
  /// ever appends erased offsets, so the counts move whenever the ink does.
  @visibleForTesting
  static String layerKey(PaintLayer layer) {
    final buffer = StringBuffer()
      ..write(layer.id)
      ..write(':')
      ..write(layer.offset.dx)
      ..write(',')
      ..write(layer.offset.dy)
      ..write(':')
      ..write(layer.scale)
      ..write(':')
      ..write(layer.rotation)
      ..write(':')
      ..write(layer.flipX ? 1 : 0)
      ..write(layer.flipY ? 1 : 0)
      ..write(':')
      ..write(layer.opacity)
      ..write(':')
      ..write(layer.rawSize.width)
      ..write('x')
      ..write(layer.rawSize.height);
    for (final item in layer.items) {
      buffer
        ..write(':')
        ..write(item.mode.index)
        ..write(',')
        ..write(item.color.toARGB32())
        ..write(',')
        ..write(item.strokeWidth)
        ..write(',')
        ..write(item.opacity)
        ..write(',')
        ..write(item.fill ? 1 : 0)
        ..write(',')
        ..write(item.offsets.length)
        ..write(',')
        ..write(item.erasedOffsets.length);
    }
    return buffer.toString();
  }

  /// The axis-aligned area [layer] paints into, in editor body coordinates.
  ///
  /// Mirrors `LayerWidget`: the layer's box is placed at `offset` shifted by
  /// [fractionalOffset] of its size, then rotated about the box center. The
  /// box is padded by half the widest stroke, because a stroke's round caps
  /// reach past the points the box was sized from.
  @visibleForTesting
  static Rect layerBounds(
    PaintLayer layer, {
    required Size editorBodySize,
    required Offset fractionalOffset,
  }) {
    final size = layer.size;
    final topLeft = Offset(
      editorBodySize.width / 2 +
          layer.offset.dx +
          fractionalOffset.dx * size.width,
      editorBodySize.height / 2 +
          layer.offset.dy +
          fractionalOffset.dy * size.height,
    );
    var padding = 0.0;
    for (final item in layer.items) {
      padding = math.max(padding, item.strokeWidth * layer.scale / 2);
    }
    final box = Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      size.width,
      size.height,
    ).inflate(padding + 1);
    if (layer.rotation == 0) return box;

    final center = box.center;
    final cosR = math.cos(layer.rotation);
    final sinR = math.sin(layer.rotation);
    Offset rotate(Offset point) {
      final local = point - center;
      return center +
          Offset(
            local.dx * cosR - local.dy * sinR,
            local.dx * sinR + local.dy * cosR,
          );
    }

    final corners = [
      rotate(box.topLeft),
      rotate(box.topRight),
      rotate(box.bottomLeft),
      rotate(box.bottomRight),
    ];
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    for (final corner in corners) {
      minX = math.min(minX, corner.dx);
      minY = math.min(minY, corner.dy);
      maxX = math.max(maxX, corner.dx);
      maxY = math.max(maxY, corner.dy);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// The cached image for [run], or `null` while it has not been rendered.
  ui.Image? imageFor(PaintLayerRasterRun run) {
    final image = _images[run.key];
    if (image != null) _touch(run.key);
    return image;
  }

  /// Whether [run] has a cached image.
  bool contains(PaintLayerRasterRun run) => _images.containsKey(run.key);

  /// Whether rendering [run] failed, so it stays live and is not retried.
  @visibleForTesting
  bool hasFailed(PaintLayerRasterRun run) => _failedKeys.contains(run.key);

  /// Whether an image is currently being rendered.
  @visibleForTesting
  bool get isRendering => _inFlightKey != null;

  /// Starts rendering [run] unless its image exists or is already in flight.
  ///
  /// Listeners are notified once the image is available.
  void ensure(
    PaintLayerRasterRun run, {
    required Size editorBodySize,
    required Offset fractionalOffset,
    required double pixelRatio,
    required PaintEditorConfigs paintEditorConfigs,
  }) {
    if (_isDisposed) return;
    if (_images.containsKey(run.key) || _inFlightKey == run.key) return;
    if (_failedKeys.contains(run.key)) return;
    if (_inFlightKey != null) {
      _hasPendingRequest = true;
      return;
    }
    _inFlightKey = run.key;
    unawaited(
      _rasterize(
        run,
        editorBodySize: editorBodySize,
        fractionalOffset: fractionalOffset,
        pixelRatio: pixelRatio,
        paintEditorConfigs: paintEditorConfigs,
      ),
    );
  }

  Future<void> _rasterize(
    PaintLayerRasterRun run, {
    required Size editorBodySize,
    required Offset fractionalOffset,
    required double pixelRatio,
    required PaintEditorConfigs paintEditorConfigs,
  }) async {
    ui.Image? image;
    try {
      final picture = recordRun(
        run,
        editorBodySize: editorBodySize,
        fractionalOffset: fractionalOffset,
        pixelRatio: pixelRatio,
        paintEditorConfigs: paintEditorConfigs,
      );
      try {
        image = await toImage(
          picture,
          (run.bounds.width * pixelRatio).ceil(),
          (run.bounds.height * pixelRatio).ceil(),
        );
      } finally {
        picture.dispose();
      }
    } catch (error, stackTrace) {
      // Rendering into an image can fail when the engine is short of GPU
      // memory or the view is being torn down. The run then simply stays
      // live, which is the behavior without a cache, and is not retried.
      _failedKeys.add(run.key);
      if (_failedKeys.length > _maxFailedKeys) {
        _failedKeys.remove(_failedKeys.first);
      }
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'pro_image_editor',
          context: ErrorDescription('while rasterizing a paint layer run'),
        ),
      );
    } finally {
      _inFlightKey = null;
    }
    if (_isDisposed) {
      image?.dispose();
      return;
    }
    if (image != null) {
      _images[run.key]?.dispose();
      _images[run.key] = image;
      _touch(run.key);
      _evict();
    }
    // Notify even when this render failed or was superseded: the listener
    // re-plans, which starts whatever is needed now.
    final hadPending = _hasPendingRequest;
    _hasPendingRequest = false;
    if (image != null || hadPending) notifyListeners();
  }

  /// Renders [picture] into a [width]×[height] image.
  ///
  /// Overridable so tests can make a render fail.
  @protected
  @visibleForTesting
  Future<ui.Image> toImage(ui.Picture picture, int width, int height) =>
      picture.toImage(width, height);

  /// Records [run] the way its live widgets paint it.
  ///
  /// Each member is placed and transformed exactly like `LayerWidget` places
  /// it — box at `offset` shifted by [fractionalOffset], flips and rotation
  /// about the box center — and stroked through the same path builders with
  /// the same baked opacity, so the image matches the live render pixel for
  /// pixel. The recording is translated so the run's
  /// [PaintLayerRasterRun.bounds] start at the origin and scaled by
  /// [pixelRatio].
  @visibleForTesting
  static ui.Picture recordRun(
    PaintLayerRasterRun run, {
    required Size editorBodySize,
    required Offset fractionalOffset,
    required double pixelRatio,
    required PaintEditorConfigs paintEditorConfigs,
  }) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(pixelRatio)
      ..translate(-run.bounds.left, -run.bounds.top);

    for (final layer in run.layers) {
      final size = layer.size;
      canvas
        ..save()
        ..translate(
          editorBodySize.width / 2 +
              layer.offset.dx +
              fractionalOffset.dx * size.width,
          editorBodySize.height / 2 +
              layer.offset.dy +
              fractionalOffset.dy * size.height,
        )
        // LayerWidget composes `Rx(flipY)·Ry(flipX)·Rz(rotation)` about the
        // box center: the rotation is applied to the geometry first, then the
        // mirroring. Canvas transforms compose the same way when issued in
        // that order.
        ..translate(size.width / 2, size.height / 2)
        ..scale(layer.flipX ? -1 : 1, layer.flipY ? -1 : 1)
        ..rotate(layer.rotation)
        ..translate(-size.width / 2, -size.height / 2);

      if (layer.items.length == 1) {
        _drawItem(
          canvas,
          layer.items.first,
          size: size,
          scale: layer.scale,
          opacity: layer.opacity,
          paintEditorConfigs: paintEditorConfigs,
        );
      } else {
        for (final item in layer.items) {
          _drawItem(
            canvas,
            item,
            size: size,
            scale: layer.scale,
            opacity: item.opacity,
            paintEditorConfigs: paintEditorConfigs,
          );
        }
      }
      canvas.restore();
    }

    return recorder.endRecording();
  }

  static void _drawItem(
    Canvas canvas,
    PaintedModel item, {
    required Size size,
    required double scale,
    required double opacity,
    required PaintEditorConfigs paintEditorConfigs,
  }) {
    PathBuilderBase.fromMode(
        item: item,
        scale: scale,
        paintEditorConfigs: paintEditorConfigs,
      )
      ..opacity = opacity
      ..draw(canvas: canvas, size: size);
  }

  void _touch(String key) {
    _recentKeys
      ..remove(key)
      ..add(key);
  }

  int get _totalPixels =>
      _images.values.fold(0, (sum, image) => sum + image.width * image.height);

  void _evict() {
    while (_recentKeys.length > 1 &&
        (_recentKeys.length > maxImages || _totalPixels > maxTotalPixels)) {
      final stale = _recentKeys.removeAt(0);
      _images.remove(stale)?.dispose();
    }
  }

  /// Drops every cached image.
  ///
  /// Failed runs stay remembered: what made them fail — a texture past the
  /// GPU's limit — does not change with the cache contents.
  void clear() {
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
    _recentKeys.clear();
  }

  @override
  void dispose() {
    _isDisposed = true;
    clear();
    super.dispose();
  }
}
