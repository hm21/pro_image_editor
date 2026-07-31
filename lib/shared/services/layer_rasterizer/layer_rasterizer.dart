// Dart imports:
import 'dart:async';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/exported_layer.dart';
import '/core/models/layers/layer.dart';
import 'layer_rasterizer_host.dart';

/// A pending rasterization, handed to a [LayerRasterizerHost] so it can mount
/// the layers that [LayerRasterizer.capture] is waiting on.
@immutable
class LayerRasterizationRequest {
  /// Creates a request for [layers] laid out against [editorBodySize].
  const LayerRasterizationRequest({
    required this.layers,
    required this.editorBodySize,
    required this.configs,
  });

  /// The layers to mount.
  final List<Layer> layers;

  /// The editor body size the layers were originally laid out against.
  ///
  /// Layer offsets are relative to this size, so passing the size the editor
  /// used is what makes the capture match the original session.
  final Size editorBodySize;

  /// The editor configuration used to build the layer widgets.
  final ProImageEditorConfigs configs;
}

/// Rasterizes [Layer]s into [ExportedLayer]s outside of a live editor session.
///
/// A layer can only be captured while it is mounted — [Layer.captureAsPng]
/// returns `null` when the layer's repaint boundary has no context. That makes
/// captured layers unavailable to anyone restoring a session from an exported
/// state history: the layers deserialize fine, but they have never been laid
/// out, so they cannot be baked into a render.
///
/// This controller closes that gap. [capture] mounts the given layers in the
/// [LayerRasterizerHost] that carries it, waits for them to paint, and returns
/// the result. The host paints them behind its own child, so they never become
/// visible.
///
/// Mount exactly one host per rasterizer, above anything that captures:
///
/// ```dart
/// final rasterizer = LayerRasterizer();
///
/// MaterialApp(
///   builder: (context, child) => LayerRasterizerHost(
///     rasterizer: rasterizer,
///     child: child!,
///   ),
/// );
///
/// final history = ImportStateHistory.fromMap(persistedHistory);
/// final captured = await rasterizer.capture(
///   layers: history.stateHistory[history.editorPosition].layers,
///   editorBodySize: history.lastRenderedImgSize,
///   configs: myEditorConfigs,
/// );
/// ```
///
/// Concurrent [capture] calls are serialized: only one set of layers is
/// mounted at a time, so captures cannot read each other's repaint boundaries.
///
/// The layers passed to [capture] must not be mounted anywhere else while they
/// are captured — no running editor, no `LayerStack` preview showing the same
/// [Layer] instances. Every layer carries [GlobalKey]s (and a [Hero] tag) that
/// `LayerWidget` attaches, so mounting it twice makes Flutter move the existing
/// element into the host: the visible copy loses its content, and release
/// builds do not report it. Layers already on screen need no host at all —
/// call [Layer.captureAllLayers] on them directly. Both this and the one-host
/// rule are asserted in debug mode.
class LayerRasterizer extends ChangeNotifier {
  LayerRasterizationRequest? _request;

  int _hostCount = 0;

  bool _isDisposed = false;

  Future<void> _queue = Future<void>.value();

  /// The layers of the preceding capture. They stay mounted until the host
  /// repaints, so a follow-up capture must not mistake them for a conflict.
  List<Layer> _previousLayers = const [];

  /// The layers currently waiting to be captured, or `null` when idle.
  ///
  /// Read by [LayerRasterizerHost]; not intended for other callers.
  LayerRasterizationRequest? get request => _request;

  /// Whether a [LayerRasterizerHost] is mounted for this rasterizer.
  ///
  /// [capture] throws without one, because there would be no widget tree to
  /// mount the layers into.
  bool get hasHost => _hostCount > 0;

  /// Registers a mounted host. Called by [LayerRasterizerHost] and not intended
  /// for other callers — faking a host makes [capture] wait for layers that are
  /// never mounted.
  void attachHost() => _hostCount++;

  /// Unregisters a disposed host. Called by [LayerRasterizerHost] and not
  /// intended for other callers.
  void detachHost() {
    _hostCount--;
    assert(
      _hostCount >= 0,
      'detachHost() was called more often than attachHost(). Both are managed '
      'by LayerRasterizerHost and must not be called directly.',
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Notifies listeners unless this rasterizer is already disposed.
  ///
  /// A capture can outlive the widget that owns the rasterizer (navigating away
  /// mid-capture), and [ChangeNotifier.notifyListeners] throws once [dispose]
  /// ran. Without this guard the notification in `_capture`'s `finally` would
  /// replace a successful result with that error.
  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  /// Captures [layers] and returns their rendered bytes with layout metadata.
  ///
  /// [editorBodySize] must be the body size the layers were laid out against
  /// in the original session — offsets are relative to it.
  ///
  /// [configs] must be the configuration of the session that created the
  /// layers, not just any configuration: the size of text, emoji and widget
  /// layers is derived from it (`textEditor.initFontSize * layer.scale`,
  /// `stickerEditor.initWidth`), and `configs.theme` decides which text theme
  /// layer content inherits. Capturing with the default configuration rescales
  /// every such layer without reporting anything.
  ///
  /// [pixelRatio] and [basePixelRatio] control the output resolution and are
  /// forwarded to [Layer.captureAllLayers]. [basePixelRatio] defaults to
  /// `configs.imageGeneration.customPixelRatio` — the value the editor's own
  /// export path passes — so a captured layer matches the resolution of a
  /// live-session export.
  ///
  /// Layers whose content loads asynchronously — network images, decoded
  /// assets, custom [WidgetLayer]s — are not painted yet one frame after
  /// mounting, and would be captured blank. Pass [awaitContentReady] to hold
  /// the capture until that content is resolved; it runs after the layers are
  /// mounted and is followed by another frame before the capture. Only the
  /// caller knows what its layers load, so there is no useful default.
  ///
  /// Returns an empty list when [layers] is empty. A layer that cannot be
  /// captured is dropped by [Layer.captureAllLayers], so the result can be
  /// shorter than [layers]; compare `ExportedLayer.layer` against the input to
  /// find out which ones. Throws a [StateError] when no [LayerRasterizerHost]
  /// is mounted, or when the host disappears before the layers are captured,
  /// and must not be called during a build — mounting the layers rebuilds the
  /// host.
  Future<List<ExportedLayer>> capture({
    required List<Layer> layers,
    required Size editorBodySize,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    double? pixelRatio,
    double? basePixelRatio,
    bool applyTransforms = true,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
    Future<void> Function()? awaitContentReady,
  }) {
    // Cheap enough to answer before queueing, so an empty request does not wait
    // behind an unrelated capture.
    if (layers.isEmpty) {
      return Future<List<ExportedLayer>>.value(const <ExportedLayer>[]);
    }

    final result = _queue.then(
      (_) => _capture(
        layers: layers,
        editorBodySize: editorBodySize,
        configs: configs,
        pixelRatio: pixelRatio,
        basePixelRatio: basePixelRatio,
        applyTransforms: applyTransforms,
        format: format,
        awaitContentReady: awaitContentReady,
      ),
    );
    // Keep the chain alive after a failed capture so one error does not block
    // every later capture.
    _queue = result.then((_) {}, onError: (_, _) {});
    return result;
  }

  Future<List<ExportedLayer>> _capture({
    required List<Layer> layers,
    required Size editorBodySize,
    required ProImageEditorConfigs configs,
    required double? pixelRatio,
    required double? basePixelRatio,
    required bool applyTransforms,
    required ui.ImageByteFormat format,
    required Future<void> Function()? awaitContentReady,
  }) async {
    if (!hasHost) {
      throw StateError(
        'LayerRasterizer.capture was called without a mounted '
        'LayerRasterizerHost. Layers can only be captured while they are in '
        'the widget tree, so a host carrying this rasterizer must be mounted '
        'above the call site.',
      );
    }
    assert(
      _hostCount == 1,
      'LayerRasterizer.capture found $_hostCount mounted '
      'LayerRasterizerHosts. Every host renders the requested layers, so the '
      'GlobalKeys a layer carries would be mounted once per host. Mount '
      'exactly one host per rasterizer.',
    );
    assert(_debugLayersAreFree(layers));

    _request = LayerRasterizationRequest(
      layers: layers,
      editorBodySize: editorBodySize,
      configs: configs,
    );
    _notify();

    try {
      // The first frame mounts and lays the layers out, the second guarantees
      // they have been painted — a repaint boundary has no image until then.
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;

      if (awaitContentReady != null) {
        await awaitContentReady();
        // Resolving content typically lands through a `setState`, so give it
        // the same build-then-paint pair the initial mount gets.
        await WidgetsBinding.instance.endOfFrame;
        await WidgetsBinding.instance.endOfFrame;
      }

      // The host can be gone by now — navigating away while the capture waits
      // for frames unmounts it. Without this every layer would come back null
      // and the caller would receive a silently empty list.
      if (!hasHost ||
          layers.every(
            (layer) => layer.repaintBoundaryKey.currentContext == null,
          )) {
        throw StateError(
          'The LayerRasterizerHost holding this rasterizer stopped rendering '
          'the layers before they were captured. Keep the host mounted and '
          'visible for the whole capture — a host that is unmounted, offstage '
          'or inside an invisible subtree never paints the layers.',
        );
      }

      return await Layer.captureAllLayers(
        layers: layers,
        pixelRatio: pixelRatio,
        basePixelRatio:
            basePixelRatio ?? configs.imageGeneration.customPixelRatio,
        applyTransforms: applyTransforms,
        format: format,
      );
    } finally {
      _request = null;
      _previousLayers = layers;
      _notify();
    }
  }

  /// Verifies that none of [layers] is already mounted somewhere else.
  ///
  /// A mounted layer already owns its [GlobalKey]s, so rendering it a second
  /// time inside the host steals them from the visible copy. Layers of the
  /// preceding capture are exempt: the host has not repainted since that
  /// capture cleared the request, so they are still mounted in the host itself
  /// and the rebuild that mounts this request replaces them.
  bool _debugLayersAreFree(List<Layer> layers) {
    for (final layer in layers) {
      if (layer.repaintBoundaryKey.currentContext == null) continue;
      if (_previousLayers.any((other) => identical(other, layer))) continue;

      throw FlutterError(
        'LayerRasterizer.capture was given a layer that is already mounted.\n'
        'Layer ${layer.id} is in the widget tree — an open editor, a '
        'LayerStack preview or another rasterizer host. Mounting it again '
        'moves the GlobalKeys it carries into this host, which empties the '
        'visible copy. Layers that are already mounted need no host: call '
        'Layer.captureAllLayers on them directly.',
      );
    }
    return true;
  }
}
