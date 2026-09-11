// Dart imports:
import 'dart:async';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/features/paint_editor/enums/paint_editor_enum.dart';

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
    required this.pixels,
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

  /// The number of device pixels of the image.
  final int pixels;

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
///
/// Widgets that stack layers use it through `PaintLayerRasterCacheHost`,
/// which owns the cache and knows when it has to step aside.
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
  /// over this budget (64 MB of RGBA by default) or over [maxImages]. The
  /// runs of a single [plan] never claim more than this together; whatever
  /// does not fit renders live.
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

  /// The keys of the runs in the most recent [plan]. Those images are what
  /// the host draws right now, so eviction leaves them alone.
  Set<String> _plannedKeys = const <String>{};

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
  /// enter/exit fade and for a timeline layer under a custom
  /// [LayerTimelineConfigs.transitionBuilder], which may decorate the layer
  /// even at full progress.
  static bool isCacheable(
    Layer layer, {
    required Set<String> excludedIds,
    required Duration? playTime,
    required ProImageEditorConfigs configs,
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
    final start = layer.startTime;
    final end = layer.endTime;
    if (playTime != null) {
      if (start != null && playTime < start) return false;
      if (end != null && playTime > end) return false;
      if ((start != null || end != null) &&
          configs.videoEditor.layerTimeline.transitionBuilder !=
              LayerTimelineConfigs.defaultFadeTransition) {
        return false;
      }
    }
    // A merged layer with a layer opacity below 1 fades the composed stack
    // through an Opacity widget; reproducing that needs an offscreen per
    // layer, which is the cost this cache exists to avoid.
    if (layer.items.length > 1 && layer.opacity < 1.0) return false;
    for (final item in layer.items) {
      // A custom builder may draw anything; its opacity path goes through an
      // Opacity widget as well.
      if (configs.paintEditor.customPathBuilders.containsKey(item.mode)) {
        return false;
      }
    }
    return true;
  }

  static bool _isPositive(Duration? duration) =>
      duration != null && duration > Duration.zero;

  /// Groups the cacheable members of [layers] into runs.
  ///
  /// [editorBodySize] places each layer the way `LayerWidget` does;
  /// [pixelRatio] is the device pixel ratio the images are rendered at. A run
  /// whose image would exceed [maxPixels] is left out, and so is everything
  /// beyond [maxImages] runs or [maxTotalPixels] in total, so the cache never
  /// holds more than it is allowed to.
  PaintLayerRasterPlan plan({
    required List<Layer> layers,
    required Set<String> excludedIds,
    required Duration? playTime,
    required Size editorBodySize,
    required double pixelRatio,
    required ProImageEditorConfigs configs,
  }) {
    final runs = <PaintLayerRasterRun>[];
    var members = <PaintLayer>[];
    var insertIndex = 0;
    var budget = maxTotalPixels;

    void flush() {
      if (members.isEmpty) return;
      final run = _buildRun(
        members,
        insertIndex: insertIndex,
        editorBodySize: editorBodySize,
        fractionalOffset: configs.paintEditor.layerFractionalOffset,
        pixelRatio: pixelRatio,
      );
      if (run != null && runs.length < maxImages && run.pixels <= budget) {
        runs.add(run);
        budget -= run.pixels;
      }
      members = <PaintLayer>[];
    }

    for (var i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final cacheable = isCacheable(
        layer,
        excludedIds: excludedIds,
        playTime: playTime,
        configs: configs,
      );
      if (!cacheable) {
        flush();
        continue;
      }
      if (members.isEmpty) insertIndex = i;
      members.add(layer as PaintLayer);
    }
    flush();

    _plannedKeys = {for (final run in runs) run.key};
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
      if (rect.isEmpty) continue;
      bounds = bounds == null ? rect : bounds.expandToInclude(rect);
      keyBuffer
        ..write('|')
        ..write(layerKey(layer));
    }
    if (bounds == null) return null;

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
      pixels: pixels,
    );
  }

  /// The part of a run key contributed by [layer]: everything that changes
  /// its pixels, nothing that does not.
  ///
  /// The stroke points and erased spots go in as a hash of their content, not
  /// as a count: a layer keeps its id across history entries, so two states
  /// of it can hold the same number of points at different positions — an
  /// erase that is undone and redone elsewhere, say — and must not share an
  /// image.
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
        ..write('/')
        ..write(Object.hashAll(item.offsets))
        ..write(',')
        ..write(item.erasedOffsets.length)
        ..write('/')
        ..write(Object.hashAll(item.erasedOffsets));
    }
    return buffer.toString();
  }

  /// The axis-aligned area [layer] paints into, in editor body coordinates.
  ///
  /// Each stroke's extent is its [PaintedModel.bounds] — the same box hit
  /// testing uses, which already covers round caps and the arrowheads that
  /// reach past the outermost point — scaled by the layer, plus room for the
  /// miter joins of the shape modes. The union is placed and transformed the
  /// way `LayerWidget` places the layer: the box at `offset` shifted by
  /// [fractionalOffset] of its size, then flipped and rotated about the box
  /// center. An empty rect means the layer draws nothing.
  @visibleForTesting
  static Rect layerBounds(
    PaintLayer layer, {
    required Size editorBodySize,
    required Offset fractionalOffset,
  }) {
    final scale = layer.scale;
    Rect? extent;
    for (final item in layer.items) {
      final bounds = item.bounds;
      if (bounds.isEmpty) continue;
      final rect = Rect.fromLTRB(
        bounds.left * scale,
        bounds.top * scale,
        bounds.right * scale,
        bounds.bottom * scale,
      ).inflate(_miterPadding(item) * scale);
      extent = extent == null ? rect : extent.expandToInclude(rect);
    }
    if (extent == null) return Rect.zero;

    final size = layer.size;
    final topLeft = Offset(
      editorBodySize.width / 2 +
          layer.offset.dx +
          fractionalOffset.dx * size.width,
      editorBodySize.height / 2 +
          layer.offset.dy +
          fractionalOffset.dy * size.height,
    );
    // One pixel for the anti-aliased edge.
    final box = extent.shift(topLeft).inflate(1);
    if (layer.rotation == 0 && !layer.flipX && !layer.flipY) return box;

    final center = topLeft + size.center(Offset.zero);
    final transform = Matrix4.translationValues(center.dx, center.dy, 0)
      ..scaleByDouble(layer.flipX ? -1 : 1, layer.flipY ? -1 : 1, 1, 1)
      ..rotateZ(layer.rotation)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    return MatrixUtils.transformRect(transform, box);
  }

  /// How far a miter join may draw past [PaintedModel.bounds].
  ///
  /// The shape modes stroke their corners with the default miter join, whose
  /// tip reaches up to `strokeMiterLimit` (4) half-strokes from the corner;
  /// `bounds` only covers half a stroke. The freestyle modes use round joins
  /// and the arrow modes' padding already covers the head's miters.
  static double _miterPadding(PaintedModel item) {
    switch (item.mode) {
      case PaintMode.rect:
      case PaintMode.polygon:
      case PaintMode.hexagon:
        return item.strokeWidth * 1.5;
      default:
        return 0;
    }
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
    required double pixelRatio,
    required ProImageEditorConfigs configs,
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
        pixelRatio: pixelRatio,
        configs: configs,
      ),
    );
  }

  Future<void> _rasterize(
    PaintLayerRasterRun run, {
    required Size editorBodySize,
    required double pixelRatio,
    required ProImageEditorConfigs configs,
  }) async {
    ui.Image? image;
    try {
      final picture = recordRun(
        run,
        editorBodySize: editorBodySize,
        pixelRatio: pixelRatio,
        configs: configs,
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
  /// it — box at `offset` shifted by the paint editor's fractional offset,
  /// flips and rotation about the box center — and stroked through the same
  /// path builders with the same baked opacity, so the image matches the live
  /// render pixel for pixel. The recording is translated so the run's
  /// [PaintLayerRasterRun.bounds] start at the origin and scaled by
  /// [pixelRatio].
  @visibleForTesting
  static ui.Picture recordRun(
    PaintLayerRasterRun run, {
    required Size editorBodySize,
    required double pixelRatio,
    required ProImageEditorConfigs configs,
  }) {
    final fractionalOffset = configs.paintEditor.layerFractionalOffset;
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
      _drawLayer(canvas, layer, paintEditorConfigs: configs.paintEditor);
      canvas.restore();
    }

    return recorder.endRecording();
  }

  /// Renders the content of [layer] alone — what its own repaint boundary
  /// holds while it paints live — into an image of its size at [pixelRatio].
  ///
  /// `Layer.captureAsPng` reads this while the layer is drawn from the cache,
  /// because the boundary paints nothing then. The cache only admits layers
  /// whose paint it reproduces exactly, so the result is what the boundary
  /// would have captured.
  static Future<ui.Image> renderLayerContent(
    PaintLayer layer, {
    required double pixelRatio,
    required PaintEditorConfigs paintEditorConfigs,
  }) async {
    final size = layer.size;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    _drawLayer(canvas, layer, paintEditorConfigs: paintEditorConfigs);
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(
        (size.width * pixelRatio).ceil(),
        (size.height * pixelRatio).ceil(),
      );
    } finally {
      picture.dispose();
    }
  }

  /// Strokes [layer]'s items in its own box coordinates, with the opacity
  /// baked the way `LayerWidgetPaintItem` bakes it.
  static void _drawLayer(
    Canvas canvas,
    PaintLayer layer, {
    required PaintEditorConfigs paintEditorConfigs,
  }) {
    final size = layer.size;
    if (layer.items.length == 1) {
      _drawItem(
        canvas,
        layer.items.first,
        size: size,
        scale: layer.scale,
        opacity: layer.opacity,
        paintEditorConfigs: paintEditorConfigs,
      );
      return;
    }
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

  /// Plans this build's runs, starts rendering any missing image and returns
  /// the stack children: every layer of [layers] in z-order through
  /// [buildLayer], with each run whose image is ready preceded by that image
  /// and its members built with `isRasterCached` set, so they skip their own
  /// paint. A run whose image is still rendering stays live.
  ///
  /// [pixelRatio] is the ratio the images are rendered at — the device pixel
  /// ratio times whatever scale the stack is drawn under.
  List<Widget> buildChildren({
    required List<Layer> layers,
    required Set<String> excludedIds,
    required Duration? playTime,
    required Size editorBodySize,
    required double pixelRatio,
    required ProImageEditorConfigs configs,
    required Widget Function(Layer layer, {required bool isRasterCached})
    buildLayer,
  }) {
    final plan = this.plan(
      layers: layers,
      excludedIds: excludedIds,
      playTime: playTime,
      editorBodySize: editorBodySize,
      pixelRatio: pixelRatio,
      configs: configs,
    );

    final imagesByInsertIndex = <int, Widget>{};
    final cachedIds = <String>{};
    for (final run in plan.runs) {
      ensure(
        run,
        editorBodySize: editorBodySize,
        pixelRatio: pixelRatio,
        configs: configs,
      );
      final image = imageFor(run);
      if (image == null) continue;
      imagesByInsertIndex[run.insertIndex] = PaintRunImage(
        key: ValueKey<String>(run.key),
        image: image,
        bounds: run.bounds,
      );
      cachedIds.addAll(run.layerIds);
    }

    return [
      for (var i = 0; i < layers.length; i++) ...[
        ?imagesByInsertIndex[i],
        buildLayer(layers[i], isRasterCached: cachedIds.contains(layers[i].id)),
      ],
    ];
  }

  void _touch(String key) {
    _recentKeys
      ..remove(key)
      ..add(key);
  }

  int get _totalPixels =>
      _images.values.fold(0, (sum, image) => sum + image.width * image.height);

  /// Disposes the least recently used images until the rest fit the budget.
  ///
  /// Images of the current plan are skipped: the host draws them right now,
  /// and evicting one would only make it render again, land again and evict
  /// the next. [plan] keeps them within [maxImages] and [maxTotalPixels] on
  /// its own, so the loop always ends.
  void _evict() {
    var index = 0;
    while (index < _recentKeys.length &&
        (_recentKeys.length > maxImages || _totalPixels > maxTotalPixels)) {
      final key = _recentKeys[index];
      if (_plannedKeys.contains(key)) {
        index++;
        continue;
      }
      _recentKeys.removeAt(index);
      _images.remove(key)?.dispose();
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

/// One run's cached image, placed where its bottom-most member paints.
///
/// Pointer events pass through: the members' own widgets stay mounted and
/// keep hit-testing the real strokes.
class PaintRunImage extends StatelessWidget {
  /// Creates the image widget for a cached run.
  const PaintRunImage({super.key, required this.image, required this.bounds});

  /// The rendered run.
  final ui.Image image;

  /// Where the run paints, in editor body coordinates.
  final Rect bounds;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: bounds.left,
      top: bounds.top,
      width: bounds.width,
      height: bounds.height,
      child: IgnorePointer(
        // The image is rendered at exactly the device pixel ratio, so at an
        // integral ratio this is a 1:1 blit; bilinear filtering only matters
        // on fractional ratios, where nearest-neighbour would shift edges by
        // a pixel.
        child: RawImage(
          image: image,
          width: bounds.width,
          height: bounds.height,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.low,
        ),
      ),
    );
  }
}
