// Flutter imports:
import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/core/models/transform_helper.dart';
import '/features/crop_rotate_editor/enums/crop_mode.enum.dart';
import '/features/crop_rotate_editor/widgets/crop_layer_painter.dart';
import 'layer_widget.dart';
import 'paint_layer_raster_cache_host.dart';

/// A stateful widget that represents a stack of layers in an image editing
/// application.
///
/// This widget manages the display and transformation of multiple layers,
/// allowing for complex image editing operations such as cropping, rotating,
/// and layering effects.
class LayerStack extends StatefulWidget {
  /// Creates a [LayerStack].
  ///
  /// This widget is responsible for rendering a collection of layers within a
  /// stack, applying transformations and managing interactions based on the
  /// provided configurations.
  ///
  /// Example:
  /// ```
  /// LayerStack(
  ///   configs: myEditorConfigs,
  ///   layers: myLayers,
  ///   cutOutsideImageArea: true,
  ///   transformHelper: myTransformHelper,
  /// )
  /// ```
  const LayerStack({
    super.key,
    required this.configs,
    required this.layers,
    required this.overlayColor,
    this.cutOutsideImageArea,
    this.enableLayerKey = false,
    this.transformHelper = const TransformHelper(
      editorBodySize: Size.zero,
      mainBodySize: Size.zero,
      mainImageSize: Size.zero,
    ),
    this.clipBehavior = Clip.hardEdge,
    this.suspendPaintLayerRasterCache = false,
  });

  /// The outside overlay color for layers.
  final Color overlayColor;

  /// The configuration settings for the image editor.
  ///
  /// These settings influence the behavior and appearance of the layer stack,
  /// such as rendering options and transformation parameters.
  final ProImageEditorConfigs configs;

  /// The list of layers to be displayed within the stack.
  ///
  /// Each layer is represented by a [Layer] object, allowing for individual
  /// customization and manipulation of its content.
  final List<Layer> layers;

  /// The clipping behavior applied to the layer stack.
  ///
  /// This determines how the contents of the stack are clipped to the widget's
  /// bounds.
  final Clip clipBehavior;

  /// A helper object providing transformation configurations for the layer
  /// stack.
  ///
  /// This includes parameters such as scale, rotation, and translation,
  /// affecting how layers are displayed and manipulated.
  final TransformHelper transformHelper;

  /// Determines whether to cut content outside the image area.
  ///
  /// This option allows for capturing only the background image area, ignoring
  /// content that extends beyond the boundaries.
  final bool? cutOutsideImageArea;

  /// A flag that determines whether the layer key functionality is enabled.
  /// When set to `true`, the layer key feature is active; otherwise, it is
  /// disabled.
  final bool enableLayerKey;

  /// Forces every paint layer to render live even when
  /// [MainEditorConfigs.enablePaintLayerRasterCache] is on.
  ///
  /// Sub-editors set this while a layer is changing continuously — the paint
  /// editor's partial eraser mutates strokes on every pointer move — and
  /// while the stack is drawn under a scale the cache does not know about,
  /// such as the paint editor's zoom or the crop editor's animated
  /// transforms, where a cached image would be resampled. Captures and route
  /// transitions are handled by the stack itself.
  final bool suspendPaintLayerRasterCache;

  @override
  State<LayerStack> createState() => _LayerStackState();
}

class _LayerStackState extends State<LayerStack>
    with PaintLayerRasterCacheHost {
  @override
  ProImageEditorConfigs get configs => widget.configs;

  bool get _cutOutsideImageArea =>
      widget.cutOutsideImageArea ??
      widget.configs.imageGeneration.cropToImageBounds;

  TransformConfigs? get _transformConfigs =>
      widget.transformHelper.transformConfigs?.isNotEmpty == true
      ? widget.transformHelper.transformConfigs
      : null;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Transform.scale(
            scale: widget.transformHelper.scale,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              clipBehavior: widget.clipBehavior,
              children: _buildLayerChildren(context),
            ),
          ),
          if (widget.configs.imageGeneration.cropToImageBounds)
            RepaintBoundary(
              child: Hero(
                tag: 'crop_layer_painter_hero',
                child: CustomPaint(
                  foregroundPainter: _cutOutsideImageArea
                      ? _buildCropPainter()
                      : null,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The stack children, with static paint layers drawn from the cache.
  ///
  /// The stack sits under a `Transform.scale`, so the images are rendered at
  /// the device pixel ratio times that scale to stay one raster pixel per
  /// device pixel.
  List<Widget> _buildLayerChildren(BuildContext context) {
    return buildRasterCachedLayers(
      layers: widget.layers,
      editorBodySize: widget.transformHelper.editorBodySize,
      pixelRatio:
          MediaQuery.devicePixelRatioOf(context) * widget.transformHelper.scale,
      suspend: widget.suspendPaintLayerRasterCache,
      buildLayer: _buildLayerWidget,
    );
  }

  Widget _buildLayerWidget(Layer layer, {bool isRasterCached = false}) {
    return LayerWidget(
      key: widget.enableLayerKey ? layer.key : null,
      layer: layer,
      configs: widget.configs,
      editorBodySize: widget.transformHelper.editorBodySize,
      isRasterCached: isRasterCached,
    );
  }

  CustomPainter _buildCropPainter() {
    final imgRatio =
        _transformConfigs?.cropRect.size.aspectRatio ??
        widget.configs.cropRotateEditor.initialOvalCropAspectRatio ??
        widget.transformHelper.mainImageSize.aspectRatio;
    final isRoundCropper =
        _transformConfigs?.isOvalCropper ??
        widget.configs.cropRotateEditor.initialCropMode == CropMode.oval;

    return CropLayerPainter(
      opacity: widget.configs.mainEditor.style.outsideCaptureAreaLayerOpacity,
      backgroundColor: widget.overlayColor,
      imgRatio: imgRatio,
      isRoundCropper: isRoundCropper,
      is90DegRotated: _transformConfigs?.is90DegRotated ?? false,
    );
  }
}
