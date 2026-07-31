// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '/core/constants/example_constants.dart';
import '/core/constants/history_demo/import_history_6_3_0_minified.dart';
import '/shared/widgets/paragraph_info_widget.dart';
import '/shared/widgets/pixel_transparent_painter.dart';

/// Demonstrates how to rasterize layers **without** a running editor session.
///
/// A layer can only be captured while it is mounted — [Layer.captureAsPng]
/// returns `null` for a layer that was never laid out. Layers restored from an
/// exported state history are exactly that case: they deserialize fine, but
/// they have never been on screen, so they cannot be baked into a render.
///
/// [LayerRasterizer] closes that gap. [LayerRasterizerHost] mounts the layers
/// behind its own child — painted, never visible — so [LayerRasterizer.capture]
/// returns the same [ExportedLayer]s a live session would.
class LayerRasterizerExample extends StatefulWidget {
  /// Creates a new [LayerRasterizerExample] widget.
  const LayerRasterizerExample({super.key});

  @override
  State<LayerRasterizerExample> createState() => _LayerRasterizerExampleState();
}

class _LayerRasterizerExampleState extends State<LayerRasterizerExample> {
  final _rasterizer = LayerRasterizer();

  /// The configuration of the session that produced the layers.
  ///
  /// Not optional in practice: text, emoji and widget layer sizes are derived
  /// from it (`textEditor.initFontSize * layer.scale`,
  /// `stickerEditor.initWidth`), so rasterizing with a different configuration
  /// than the editor used silently rescales those layers.
  final _configs = const ProImageEditorConfigs();

  /// A persisted editor session. Nothing here ever opens the editor — the
  /// history is parsed and its layers go straight to the rasterizer.
  final _history = ImportStateHistory.fromMap(
    kImportHistoryDemoData,
    configs: ImportEditorConfigs(
      /// Only the main-editor import path recalculates offsets against the
      /// current image size. Standalone we keep the original values and lay
      /// the layers out against the size they were exported with.
      recalculateSizeAndPosition: false,
      widgetLoader: (String id, {Map<String, dynamic>? meta}) {
        switch (id) {
          case 'my-special-container':
            return Container(
              width: 100,
              height: 100,
              color: Colors.amber,
            );
        }
        throw ArgumentError('No widget found for the given id: $id');
      },
    ),
  );

  List<ExportedLayer>? _captured;
  bool _isCapturing = false;
  String? _error;
  int? _durationInMs;

  /// The size the image was rendered at in the original session.
  ///
  /// Layer offsets and scales are stored relative to it — that is the size the
  /// import path rescales against — and they are measured from its center, so
  /// laying the layers out in a box of exactly this size reproduces the
  /// original session. It is not the editor's body size, which also covers the
  /// letterboxing around the image.
  Size get _editorBodySize => _history.lastRenderedImgSize;

  List<Layer> get _layers {
    final states = _history.stateHistory;
    if (states.isEmpty) return const [];
    final position = _history.editorPosition.clamp(0, states.length - 1);
    return states[position].layers;
  }

  @override
  void dispose() {
    _rasterizer.dispose();
    super.dispose();
  }

  Future<void> _rasterize() async {
    setState(() {
      _isCapturing = true;
      _error = null;
    });

    final stopwatch = Stopwatch()..start();

    try {
      final captured = await _rasterizer.capture(
        layers: _layers,
        editorBodySize: _editorBodySize,
        configs: _configs,

        /// The history contains a widget layer that loads a network image. One
        /// frame after mounting it is still blank, so we hold the capture
        /// until every image the import flagged is resolved.
        awaitContentReady: _precacheLayerImages,
      );
      if (!mounted) return;

      setState(() {
        _captured = captured;
        _durationInMs = stopwatch.elapsedMilliseconds;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  /// Resolves the images the imported layers depend on.
  ///
  /// [ImportStateHistory.requirePrecacheList] collects every network, asset,
  /// file or memory image referenced by an imported widget layer.
  Future<void> _precacheLayerImages() async {
    if (!mounted) return;
    await Future.wait(
      _history.requirePrecacheList.toSet().map(
            (image) => precacheImage(image.toImageProvider(), context),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// The host must be mounted before `capture` runs — it is the widget tree
    /// the layers get mounted into. In a real app it usually goes around the
    /// whole app instead of a single page:
    ///
    /// ```dart
    /// MaterialApp(
    ///   builder: (context, child) => LayerRasterizerHost(
    ///     rasterizer: rasterizer,
    ///     child: child!,
    ///   ),
    /// );
    /// ```
    return LayerRasterizerHost(
      rasterizer: _rasterizer,
      child: Scaffold(
        appBar: AppBar(title: const Text('Layer Rasterizer')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            _buildInfo(),
            const SizedBox(height: 20),
            _buildActions(),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_captured != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Composed render'),
              const SizedBox(height: 8),
              _buildComposite(_captured!),
              const SizedBox(height: 24),
              _buildSectionTitle('Captured layers'),
              const SizedBox(height: 8),
              _buildLayerStrip(_captured!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return ParagraphInfoWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const Text(
            'This page never opens the editor. It parses a persisted state '
            'history and hands its layers to a `LayerRasterizer`, which mounts '
            'them inside the `LayerRasterizerHost` below the visible content, '
            'waits for them to paint and captures each one as a PNG.',
          ),
          Text(
            'Layers in the history: ${_layers.length}  •  '
            'Original rendered image size: ${_editorBodySize.width.round()}'
            ' × ${_editorBodySize.height.round()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final captured = _captured;

    return Row(
      spacing: 16,
      children: [
        FilledButton.icon(
          onPressed: _isCapturing ? null : _rasterize,
          icon: _isCapturing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome_motion_outlined),
          label: Text(
            captured == null ? 'Rasterize layers' : 'Rasterize again',
          ),
        ),
        if (captured != null && !_isCapturing)
          Expanded(
            child: Text(
              '${captured.length} of ${_layers.length} layers captured '
              'in $_durationInMs ms'
              // `capture` drops layers it could not render instead of
              // returning a placeholder, so a short result is worth naming.
              '${captured.length < _layers.length ? ' — the rest could not '
                  'be rendered' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }

  /// Places the captured PNGs back over the background image.
  ///
  /// Each layer offset is relative to the center of the editor body, and
  /// `applyTransforms` already baked rotation and flip into the bytes, so the
  /// bytes only need to be centered on that offset.
  Widget _buildComposite(List<ExportedLayer> layers) {
    final size = _editorBodySize;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 420),
        child: AspectRatio(
          aspectRatio: size.width / size.height,
          child: FittedBox(
            child: SizedBox.fromSize(
              size: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      kImageEditorExampleAssetPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                  for (final item in layers)
                    Positioned(
                      left: item.layer.offset.dx + size.width / 2,
                      top: item.layer.offset.dy + size.height / 2,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -0.5),
                        child: Image.memory(
                          item.bytes,
                          width: item.logicalSize.width,
                          height: item.logicalSize.height,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows every captured layer on a transparency grid so the alpha channel
  /// of the exported bytes is visible.
  Widget _buildLayerStrip(List<ExportedLayer> layers) {
    if (layers.isEmpty) {
      return const Text('No layer could be captured.');
    }

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: layers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final item = layers[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    painter: const PixelTransparentPainter(
                      primary: Color(0xFF9E9E9E),
                      secondary: Color(0xFF757575),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.memory(item.bytes, width: 120),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _layerLabel(item.layer),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                '${item.logicalSize.width.round()}'
                ' × ${item.logicalSize.height.round()} px',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  String _layerLabel(Layer layer) {
    if (layer is TextLayer) return 'Text';
    if (layer is EmojiLayer) return 'Emoji';
    if (layer is PaintLayer) return 'Paint';
    if (layer is WidgetLayer) return 'Widget';
    return 'Layer';
  }
}
