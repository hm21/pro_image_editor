// Flutter imports:
import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/features/main_editor/services/paint_layer_raster_cache.dart';
import '/shared/services/content_recorder/controllers/content_recorder_controller.dart';
import '/shared/services/content_recorder/widgets/content_recorder.dart';

/// Lets the state of a widget that stacks `LayerWidget`s draw its static paint
/// layers from a [PaintLayerRasterCache].
///
/// The mixin owns the cache (when
/// [MainEditorConfigs.enablePaintLayerRasterCache] is on), rebuilds the host
/// once an image lands, and knows the two moments every host has to step
/// aside in:
///
/// * while the enclosing [ContentRecorder] reads the tree — a cached image
///   is rendered at the device pixel ratio and would be upscaled into the
///   capture, and a cached layer's own repaint boundary is blank;
/// * while the route the host sits on is animating — hero shuttles fly in
///   the overlay while their destination widgets are hidden, so the image
///   would show the strokes a second time at their final spot.
///
/// A host adds its own conditions through the `suspend` argument of
/// [buildRasterCachedLayers].
mixin PaintLayerRasterCacheHost<T extends StatefulWidget> on State<T> {
  /// The editor configuration the layers are built with.
  ProImageEditorConfigs get configs;

  PaintLayerRasterCache? _rasterCache;
  LiveLayerRequests? _liveLayerRequests;
  Animation<double>? _routeAnimation;

  /// The cache, or `null` when the feature is off.
  PaintLayerRasterCache? get rasterCache => _rasterCache;

  /// Whether the cache has to stay out of this build because a capture is
  /// reading the tree or the route is animating.
  bool get isRasterCacheSuspended =>
      (_liveLayerRequests?.value ?? 0) > 0 ||
      (_routeAnimation?.isAnimating ?? false);

  @override
  void initState() {
    super.initState();
    if (configs.mainEditor.enablePaintLayerRasterCache) {
      _rasterCache = PaintLayerRasterCache()..addListener(_rebuild);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rasterCache == null) return;

    final requests = ContentRecorder.maybeControllerOf(
      context,
    )?.liveLayerRequests;
    if (!identical(requests, _liveLayerRequests)) {
      _liveLayerRequests?.removeListener(_rebuild);
      _liveLayerRequests = requests?..addListener(_rebuild);
    }

    final animation = ModalRoute.of(context)?.animation;
    if (!identical(animation, _routeAnimation)) {
      _routeAnimation?.removeStatusListener(_onRouteStatusChanged);
      _routeAnimation = animation?..addStatusListener(_onRouteStatusChanged);
    }
  }

  @override
  void dispose() {
    _liveLayerRequests?.removeListener(_rebuild);
    _routeAnimation?.removeStatusListener(_onRouteStatusChanged);
    _rasterCache?.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _onRouteStatusChanged(AnimationStatus status) => _rebuild();

  /// The stack children for this build: every layer of [layers] in z-order
  /// through [buildLayer], with each cached run preceded by its image.
  ///
  /// Everything renders live when the feature is off, when [suspend] holds
  /// or while [isRasterCacheSuspended]. [excludedIds] are layers the host
  /// wants live regardless, [playTime] the video position for timeline
  /// layers, [pixelRatio] the ratio the images are rendered at.
  List<Widget> buildRasterCachedLayers({
    required List<Layer> layers,
    required Size editorBodySize,
    required double pixelRatio,
    required Widget Function(Layer layer, {required bool isRasterCached})
    buildLayer,
    Set<String> excludedIds = const {},
    Duration? playTime,
    bool suspend = false,
  }) {
    final cache = _rasterCache;
    if (cache == null || suspend || isRasterCacheSuspended) {
      return [
        for (final layer in layers) buildLayer(layer, isRasterCached: false),
      ];
    }
    return cache.buildChildren(
      layers: layers,
      excludedIds: excludedIds,
      playTime: playTime,
      editorBodySize: editorBodySize,
      pixelRatio: pixelRatio,
      configs: configs,
      buildLayer: buildLayer,
    );
  }
}
