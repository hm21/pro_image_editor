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
///   editorBodySize: persistedBodySize,
///   configs: myEditorConfigs,
/// );
/// ```
///
/// Concurrent [capture] calls are serialized: only one set of layers is
/// mounted at a time, so captures cannot read each other's repaint boundaries.
class LayerRasterizer extends ChangeNotifier {
  LayerRasterizationRequest? _request;

  int _hostCount = 0;

  Future<void> _queue = Future<void>.value();

  /// The layers currently waiting to be captured, or `null` when idle.
  ///
  /// Read by [LayerRasterizerHost]; not intended for other callers.
  LayerRasterizationRequest? get request => _request;

  /// Whether a [LayerRasterizerHost] is mounted for this rasterizer.
  ///
  /// [capture] throws without one, because there would be no widget tree to
  /// mount the layers into.
  bool get hasHost => _hostCount > 0;

  /// Registers a mounted host. Called by [LayerRasterizerHost].
  void attachHost() => _hostCount++;

  /// Unregisters a disposed host. Called by [LayerRasterizerHost].
  void detachHost() => _hostCount--;

  /// Captures [layers] and returns their rendered bytes with layout metadata.
  ///
  /// [editorBodySize] must be the body size the layers were laid out against
  /// in the original session — offsets are relative to it.
  ///
  /// [pixelRatio] and [basePixelRatio] control the output resolution and are
  /// forwarded to [Layer.captureAllLayers]. Pass the same `basePixelRatio` the
  /// export path uses (typically `configs.imageGeneration.customPixelRatio`)
  /// so a captured layer matches the resolution of a live-session export.
  ///
  /// Layers whose content loads asynchronously — network images, decoded
  /// assets, custom [WidgetLayer]s — are not painted yet one frame after
  /// mounting, and would be captured blank. Pass [awaitContentReady] to hold
  /// the capture until that content is resolved; it runs after the layers are
  /// mounted and is followed by another frame before the capture. Only the
  /// caller knows what its layers load, so there is no useful default.
  ///
  /// Returns an empty list when [layers] is empty. Throws a [StateError] when
  /// no [LayerRasterizerHost] is mounted, and must not be called during a
  /// build — mounting the layers rebuilds the host.
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
    if (layers.isEmpty) return const <ExportedLayer>[];

    if (!hasHost) {
      throw StateError(
        'LayerRasterizer.capture was called without a mounted '
        'LayerRasterizerHost. Layers can only be captured while they are in '
        'the widget tree, so a host carrying this rasterizer must be mounted '
        'above the call site.',
      );
    }

    _request = LayerRasterizationRequest(
      layers: layers,
      editorBodySize: editorBodySize,
      configs: configs,
    );
    notifyListeners();

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

      return await Layer.captureAllLayers(
        layers: layers,
        pixelRatio: pixelRatio,
        basePixelRatio: basePixelRatio,
        applyTransforms: applyTransforms,
        format: format,
      );
    } finally {
      _request = null;
      notifyListeners();
    }
  }
}
