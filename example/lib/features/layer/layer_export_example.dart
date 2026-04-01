// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';

/// Demonstrates how to export individual layers as PNG images.
///
/// Each layer has a [RepaintBoundary] with a [GlobalKey] attached, accessible
/// via [Layer.repaintBoundaryKey]. Use [Layer.captureAsPng] to capture the
/// visual content of any mounted layer.
class LayerExportExample extends StatefulWidget {
  /// Creates a new [LayerExportExample] widget.
  const LayerExportExample({super.key});

  @override
  State<LayerExportExample> createState() => _LayerExportExampleState();
}

class _LayerExportExampleState extends State<LayerExportExample>
    with ExampleHelperState<LayerExportExample> {
  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  Future<void> _exportLayers(
    ProImageEditorState editor, {
    required bool overlay,
  }) async {
    final layers = editor.activeLayers;
    if (layers.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No layers to export.')),
      );
      return;
    }

    final bodySize = editor.sizesManager.bodySize;
    final exported = await editor.captureAllLayersWithMeta(
      applyTransforms: false,
    );

    if (!mounted) return;

    if (overlay) {
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => _ExportedLayersOverlay(
            layers: exported,
            editorBodySize: bodySize,
          ),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _ExportedLayersPreview(
            layers: exported,
            editorBodySize: bodySize,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return ProImageEditor.asset(
      kImageEditorExampleAssetPath,
      key: editorKey,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: (editorMode) => onCloseEditor(
          editorMode: editorMode,
          enablePop: !isDesktopMode(context),
        ),
        mainEditorCallbacks: MainEditorCallbacks(
          helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
        ),
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        mainEditor: MainEditorConfigs(
          enableCloseButton: !isDesktopMode(context),
          widgets: MainEditorWidgets(
            appBar: (editor, rebuildStream) => ReactiveAppbar(
              stream: rebuildStream,
              builder: (_) => AppBar(
                automaticallyImplyLeading: false,
                foregroundColor:
                    Theme.of(context).appBarTheme.foregroundColor ??
                        Colors.white,
                backgroundColor: Colors.black,
                title: const Text('Layer Export'),
                actions: [
                  PopupMenuButton<bool>(
                    icon: const Icon(Icons.visibility),
                    tooltip: 'Export all layers as PNG',
                    onSelected: (overlay) =>
                        _exportLayers(editor, overlay: overlay),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: false,
                        child: Text('Preview (new page)'),
                      ),
                      PopupMenuItem(
                        value: true,
                        child: Text('Overlay (50% opacity)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        imageGeneration: const ImageGenerationConfigs(
          processorConfigs: ProcessorConfigs(
            processorMode: ProcessorMode.auto,
          ),
        ),
      ),
    );
  }
}

class _ExportedLayersOverlay extends StatelessWidget {
  const _ExportedLayersOverlay({
    required this.layers,
    required this.editorBodySize,
  });
  final List<ExportedLayer> layers;
  final Size editorBodySize;

  @override
  Widget build(BuildContext context) {
    final halfWidth = editorBodySize.width / 2;
    final halfHeight = editorBodySize.height / 2;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Opacity(
            opacity: 0.5,
            child: SizedBox(
              width: editorBodySize.width,
              height: editorBodySize.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final item in layers)
                    Positioned(
                      left: item.layer.offset.dx + halfWidth,
                      top: item.layer.offset.dy + halfHeight,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -0.5),
                        child: Transform(
                          transform: Matrix4.identity()
                            ..rotateX(item.layer.flipY ? pi : 0)
                            ..rotateY(item.layer.flipX ? pi : 0)
                            ..rotateZ(item.layer.rotation),
                          alignment: Alignment.center,
                          child: Image.memory(
                            item.bytes,
                            width: item.logicalSize.width,
                            height: item.logicalSize.height,
                          ),
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
}

class _ExportedLayersPreview extends StatelessWidget {
  const _ExportedLayersPreview({
    required this.layers,
    required this.editorBodySize,
  });
  final List<ExportedLayer> layers;
  final Size editorBodySize;

  @override
  Widget build(BuildContext context) {
    final halfWidth = editorBodySize.width / 2;
    final halfHeight = editorBodySize.height / 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Exported Layers')),
      body: Center(
        child: SizedBox(
          width: editorBodySize.width,
          height: editorBodySize.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Image.asset(
                  kImageEditorExampleAssetPath,
                  fit: BoxFit.contain,
                ),
              ),
              for (final item in layers)
                Positioned(
                  left: item.layer.offset.dx + halfWidth,
                  top: item.layer.offset.dy + halfHeight,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Transform(
                      transform: Matrix4.identity()
                        ..rotateX(item.layer.flipY ? pi : 0)
                        ..rotateY(item.layer.flipX ? pi : 0)
                        ..rotateZ(item.layer.rotation),
                      alignment: Alignment.center,
                      child: Image.memory(
                        item.bytes,
                        width: item.logicalSize.width,
                        height: item.logicalSize.height,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
