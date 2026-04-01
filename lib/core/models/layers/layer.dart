// Dart imports:
import 'dart:math' as math;
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '/core/constants/int_constants.dart';
import '/core/models/editor_configs/image_generation_configs/image_generation_configs.dart';
import '/shared/extensions/box_constraints_extension.dart';
import '/shared/extensions/export_bool_extension.dart';
import '/shared/extensions/num_extension.dart';
import '/shared/services/content_recorder/controllers/content_recorder_controller.dart';
import '/shared/services/import_export/types/widget_loader.dart';
import '/shared/services/import_export/utils/key_minifier.dart';
import '/shared/utils/map_utils.dart';
import '/shared/utils/parser/bool_parser.dart';
import '/shared/utils/parser/double_parser.dart';
import '/shared/utils/unique_id_generator.dart';
import '../editor_image.dart';
import 'emoji_layer.dart';
import 'exported_layer.dart';
import 'layer_interaction.dart';
import 'paint_layer.dart';
import 'text_layer.dart';
import 'widget_layer.dart';

export 'emoji_layer.dart';
export 'paint_layer.dart';
export 'text_layer.dart';
export 'widget_layer.dart';

/// Represents a layer with common properties for widgets.
class Layer {
  /// Creates a new layer with optional properties.
  Layer({
    GlobalKey? key,
    String? id,
    LayerInteraction? interaction,
    this.offset = Offset.zero,
    this.rotation = 0,
    this.scale = 1,
    this.flipX = false,
    this.flipY = false,
    this.meta,
    this.boxConstraints,
    this.groupId,
  }) : key = key ??= GlobalKey(),
       keyInternalSize = GlobalKey(),
       repaintBoundaryKey = GlobalKey(),
       id = id ?? generateUniqueId(),
       interaction = interaction ?? LayerInteraction();

  /// Factory constructor for creating a Layer instance from a map and a list
  /// of stickers.
  factory Layer.fromMap(
    Map<String, dynamic> map, {
    List<Uint8List>? widgetRecords,
    WidgetLoader? widgetLoader,
    String? id,
    Function(EditorImage editorImage)? requirePrecache,
    EditorKeyMinifier? minifier,
  }) {
    var keyConverter = minifier?.convertLayerKey ?? (String key) => key;
    var keyInteractionConverter =
        minifier?.convertLayerInteractionKey ?? (String key) => key;

    BoxConstraints? boxConstraints;
    var constrainedMap = map[keyConverter('boxConstraints')];

    if (constrainedMap != null) {
      boxConstraints = BoxConstraints(
        minWidth: safeParseDouble(constrainedMap['minWidth']),
        minHeight: safeParseDouble(constrainedMap['minHeight']),
        maxWidth: safeParseDouble(
          constrainedMap['maxWidth'],
          fallback: double.infinity,
        ),
        maxHeight: safeParseDouble(
          constrainedMap['maxHeight'],
          fallback: double.infinity,
        ),
      );
    }

    Layer layer = Layer(
      id: id,
      flipX: safeParseBool(map[keyConverter('flipX')]),
      flipY: safeParseBool(map[keyConverter('flipY')]),
      interaction: LayerInteraction.fromMap(
        map[keyConverter('interaction')] ?? {},
        keyConverter: keyInteractionConverter,
      ),
      meta: map[keyConverter('meta')],
      offset: Offset(safeParseDouble(map['x']), safeParseDouble(map['y'])),
      rotation: safeParseDouble(map[keyConverter('rotation')]),
      scale: safeParseDouble(map[keyConverter('scale')], fallback: 1),
      boxConstraints: boxConstraints,
      groupId: map[keyConverter('groupId')],
    );

    /// Determines the layer type from the map and returns the appropriate
    /// LayerData subclass.
    switch (map[keyConverter('type')]) {
      case 'text':
        // Returns a TextLayer instance when type is 'text'.
        return TextLayer.fromMap(layer, map, keyConverter: keyConverter);
      case 'emoji':
        // Returns an EmojiLayer instance when type is 'emoji'.
        return EmojiLayer.fromMap(layer, map, keyConverter: keyConverter);
      case 'paint':
      case 'painting':
        // Returns a PaintLayer instance when type is 'paint'.
        return PaintLayer.fromMap(layer, map, minifier: minifier);
      case 'sticker':
      case 'widget':
        // Returns a WidgetLayer instance when type is 'widget' or 'sticker',
        // utilizing the widgets layer list.
        return WidgetLayer.fromMap(
          layer: layer,
          map: map,
          widgetRecords: widgetRecords ?? [],
          widgetLoader: widgetLoader,
          requirePrecache: requirePrecache,
          keyConverter: keyConverter,
        );
      default:
        // Returns the base Layer instance when type is unrecognized.
        return layer;
    }
  }

  /// Optional group identifier for grouping layers.
  String? groupId;

  /// Global key associated with the Layer instance, used for accessing the
  /// widget tree.
  GlobalKey key;

  /// A global key used to get the layer size.
  GlobalKey keyInternalSize;

  /// A global key attached to the layer's [RepaintBoundary].
  ///
  /// This key can be used to capture the layer's visual content as a PNG
  /// image via [captureAsPng].
  GlobalKey repaintBoundaryKey;

  /// The position offset of the widget.
  Offset offset;

  /// The rotation and scale values of the widget.
  double rotation, scale;

  /// Flags to control horizontal and vertical flipping.
  bool flipX, flipY;

  /// Optional constraints to temporarily limit the layer's dimensions.
  BoxConstraints? boxConstraints;

  /// The interaction settings for the layer.
  ///
  /// It holds the interaction properties, such as whether moving, scaling,
  /// rotating, or selecting the layer is enabled.
  LayerInteraction interaction;

  /// A unique identifier for the layer.
  String id;

  /// A map containing metadata associated with the layer.
  ///
  /// This can be used to store additional information about the layer
  /// that may be needed for processing or rendering.
  Map<String, dynamic>? meta;

  /// Indicates whether this layer is a [TextLayer].
  ///
  /// Subclasses can override this to return `true` if the layer represents
  /// a text-based element.
  bool get isTextLayer => false;

  /// Indicates whether this layer is a [PaintLayer].
  ///
  /// Subclasses can override this to return `true` if the layer contains
  /// freehand drawing or painted content.
  bool get isPaintLayer => false;

  /// Indicates whether this layer is an [EmojiLayer].
  ///
  /// Subclasses can override this to return `true` if the layer represents
  /// an emoji or similar symbolic element.
  bool get isEmojiLayer => false;

  /// Indicates whether this layer is a [WidgetLayer].
  ///
  /// Subclasses can override this to return `true` if the layer hosts a
  /// Flutter widget or sticker.
  bool get isWidgetLayer => false;

  /// Converts this transform object to a Map.
  ///
  /// Returns a Map representing the properties of this layer object,
  /// including the X and Y coordinates, rotation angle, scale factors, and
  /// flip flags.
  Map<String, dynamic> toMap({
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) {
    return {
      'x': offset.dx.roundSmart(maxDecimalPlaces),
      'y': offset.dy.roundSmart(maxDecimalPlaces),
      'rotation': rotation.roundSmart(maxDecimalPlaces),
      'scale': scale.roundSmart(maxDecimalPlaces),
      'flipX': flipX.minify(enableMinify),
      'flipY': flipY.minify(enableMinify),
      'interaction': interaction.toMap(enableMinify: enableMinify),
      if (meta != null) 'meta': meta,
      'type': 'default',
      if (boxConstraints != null)
        'boxConstraints': boxConstraints!.toMap(
          maxDecimalPlaces: maxDecimalPlaces,
        ),
      if (groupId != null) 'groupId': groupId,
    };
  }

  /// Converts the current layer to a map representation, comparing it with a
  /// reference layer.
  ///
  /// The resulting map will contain only the properties that differ from the
  /// reference layer.
  Map<String, dynamic> toMapFromReference(
    Layer layer, {
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) {
    return {
      'id': id,
      if (layer.offset.dx != offset.dx)
        'x': offset.dx.roundSmart(maxDecimalPlaces),
      if (layer.offset.dy != offset.dy)
        'y': offset.dy.roundSmart(maxDecimalPlaces),
      if (layer.rotation != rotation)
        'rotation': rotation.roundSmart(maxDecimalPlaces),
      if (layer.scale != scale) 'scale': scale.roundSmart(maxDecimalPlaces),
      if (layer.flipX != flipX) 'flipX': flipX.minify(enableMinify),
      if (layer.flipY != flipY) 'flipY': flipY.minify(enableMinify),
      if (!mapIsEqual(layer.meta, meta)) 'meta': meta,
      if (layer.interaction != interaction)
        'interaction': interaction.toMapFromReference(
          layer.interaction,
          enableMinify: enableMinify,
        ),
      if (layer.boxConstraints != boxConstraints)
        'boxConstraints': boxConstraints!.toMap(
          maxDecimalPlaces: maxDecimalPlaces,
        ),
      if (layer.groupId != groupId) 'groupId': groupId,
    };
  }

  /// Captures the visual content of this layer as a PNG-encoded byte array.
  ///
  /// The layer must be mounted in the widget tree with its
  /// [repaintBoundaryKey] attached to a [RepaintBoundary]. The [pixelRatio]
  /// controls the resolution of the output image. When `null`, it defaults
  /// to `devicePixelRatio * scale` to preserve sharpness for scaled and
  /// rotated layers.
  ///
  /// The [format] controls the output byte format and defaults to PNG for
  /// backward compatibility.
  ///
  /// When [applyTransforms] is `true` (default), the layer's [rotation],
  /// [flipX] and [flipY] are applied to the output image. Set it to `false`
  /// to get the raw, un-transformed content.
  ///
  /// Returns `null` if the layer is not currently mounted.
  Future<Uint8List?> captureAsPng({
    double? pixelRatio,
    bool applyTransforms = true,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
    ContentRecorderController? recorder,
  }) async {
    final context = repaintBoundaryKey.currentContext;
    if (context == null) return null;

    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 3.0;
    final effectivePixelRatio = pixelRatio ?? (dpr * scale);

    final boundary = context.findRenderObject() as RenderRepaintBoundary;
    final rawImage = await boundary.toImage(pixelRatio: effectivePixelRatio);

    final bool needsTransform =
        applyTransforms && (rotation != 0 || flipX || flipY);
    if (!needsTransform) {
      final bytes = await _encodeLayerImage(
        rawImage,
        format: format,
        recorder: recorder,
      );
      rawImage.dispose();
      return bytes;
    }

    final double w = rawImage.width.toDouble();
    final double h = rawImage.height.toDouble();

    final double cosR = math.cos(rotation).abs();
    final double sinR = math.sin(rotation).abs();
    final double newW = w * cosR + h * sinR;
    final double newH = w * sinR + h * cosR;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder, Rect.fromLTWH(0, 0, newW, newH))
      ..translate(newW / 2, newH / 2);
    if (flipX) canvas.scale(-1, 1);
    if (flipY) canvas.scale(1, -1);
    canvas
      ..rotate(rotation)
      ..translate(-w / 2, -h / 2)
      ..drawImage(rawImage, Offset.zero, Paint());

    final picture = pictureRecorder.endRecording();
    final transformed = await picture.toImage(newW.ceil(), newH.ceil());
    rawImage.dispose();
    picture.dispose();

    final bytes = await _encodeLayerImage(
      transformed,
      format: format,
      recorder: recorder,
    );
    transformed.dispose();

    return bytes;
  }

  /// Exports multiple layers in one run and reuses a single recorder for PNG
  /// encoding to avoid repeatedly creating and destroying isolate resources.
  ///
  /// If [format] is PNG and [recorder] is not provided, this method creates
  /// one recorder internally and reuses it for all layers.
  static Future<List<Uint8List?>> captureAllLayersAsBytes({
    required List<Layer> layers,
    double? pixelRatio,
    bool applyTransforms = true,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
    ContentRecorderController? recorder,
  }) async {
    ContentRecorderController? localRecorder;
    ContentRecorderController? sharedRecorder = recorder;

    if (format == ui.ImageByteFormat.png && sharedRecorder == null) {
      sharedRecorder = _createPngRecorderController();
      localRecorder = sharedRecorder;
    }

    try {
      final bytes = <Uint8List?>[];
      for (final layer in layers) {
        bytes.add(
          await layer.captureAsPng(
            pixelRatio: pixelRatio,
            applyTransforms: applyTransforms,
            format: format,
            recorder: sharedRecorder,
          ),
        );
      }
      return bytes;
    } finally {
      if (localRecorder != null) {
        await localRecorder.destroy();
      }
    }
  }

  /// Exports multiple layers in one run and returns metadata per exported
  /// layer.
  static Future<List<ExportedLayer>> captureAllLayers({
    required List<Layer> layers,
    double? pixelRatio,
    bool applyTransforms = true,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
    ContentRecorderController? recorder,
  }) async {
    final logicalSizes = <Size>[
      for (final layer in layers)
        (layer.repaintBoundaryKey.currentContext?.findRenderObject()
                    as RenderBox?)
                ?.size ??
            Size.zero,
    ];

    final allBytes = await captureAllLayersAsBytes(
      layers: layers,
      pixelRatio: pixelRatio,
      applyTransforms: applyTransforms,
      format: format,
      recorder: recorder,
    );

    final exported = <ExportedLayer>[];
    for (var i = 0; i < layers.length; i++) {
      final bytes = i < allBytes.length ? allBytes[i] : null;
      if (bytes == null) continue;
      exported.add(
        ExportedLayer(
          layer: layers[i],
          bytes: bytes,
          logicalSize: logicalSizes[i],
        ),
      );
    }

    return exported;
  }

  static ContentRecorderController _createPngRecorderController() {
    return ContentRecorderController(
      isVideoEditor: false,
      configs: const ImageGenerationConfigs(
        outputFormat: OutputFormat.png,
        processorConfigs: ProcessorConfigs(
          processorMode: ProcessorMode.minimum,
        ),
      ),
    );
  }

  Future<Uint8List?> _encodeLayerImage(
    ui.Image image, {
    required ui.ImageByteFormat format,
    ContentRecorderController? recorder,
  }) async {
    if (format != ui.ImageByteFormat.png) {
      final byteData = await image.toByteData(format: format);
      return byteData?.buffer.asUint8List();
    }

    ContentRecorderController? localRecorder;
    final activeRecorder =
        recorder ?? (localRecorder = _createPngRecorderController());

    try {
      return await activeRecorder.convertRawImageData(
        image: image,
        id: generateUniqueId(),
        outputFormat: OutputFormat.png,
        cropToDrawingBounds: false,
      );
    } finally {
      if (localRecorder != null) {
        await localRecorder.destroy();
      }
    }
  }

  RenderBox? get _renderBox {
    final renderObj = keyInternalSize.currentContext?.findRenderObject();
    return renderObj is RenderBox ? renderObj : null;
  }

  /// Computes the global offset within the render box using a fractional
  /// position relative to the center of the box.
  ///
  /// The [fractionalOffset] is specified with values relative to the center:
  /// - (0, 0) represents the exact center of the box,
  /// - (-0.5, -0.5) represents the top-left corner,
  /// - (0.5, 0.5) represents the bottom-right corner.
  ///
  /// Returns the computed global [Offset] based on the size of the render box
  /// and the provided [offset] as the origin. If the render box is not
  /// available or the [fractionalOffset] equals `Offset(-0.5, -0.5)`, the
  /// method returns [offset] directly as a fallback.
  Offset computeOffsetFromCenterFraction(Offset fractionalOffset) {
    final renderBox = _renderBox;
    if (renderBox == null || fractionalOffset == const Offset(-0.5, -0.5)) {
      return offset;
    }

    final size = renderBox.size;
    final dx = offset.dx + size.width * (fractionalOffset.dx + 0.5);
    final dy = offset.dy + size.height * (fractionalOffset.dy + 0.5);

    return Offset(dx, dy);
  }

  /// Computes the local offset within the render box using a fractional
  /// position relative to the center of the box (excluding the global
  /// [offset]).
  ///
  /// The [fractionalOffset] is specified with values relative to the center:
  /// - (0, 0) represents the center of the box,
  /// - (-0.5, -0.5) represents the top-left corner,
  /// - (0.5, 0.5) represents the bottom-right corner.
  ///
  /// Returns the computed local [Offset] inside the render box. If the render
  /// box is not available or the [fractionalOffset] equals
  /// `Offset(-0.5, -0.5)`, the method returns [Offset.zero] as a fallback.
  Offset computeLocalCenterOffset(Offset fractionalOffset) {
    final renderBox = _renderBox;
    if (renderBox == null || fractionalOffset == const Offset(-0.5, -0.5)) {
      return Offset.zero;
    }

    final size = renderBox.size;
    final dx = size.width * (fractionalOffset.dx + 0.5);
    final dy = size.height * (fractionalOffset.dy + 0.5);

    return Offset(dx, dy);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Layer &&
        other.id == id &&
        other.offset == offset &&
        other.rotation == rotation &&
        other.scale == scale &&
        other.flipX == flipX &&
        other.flipY == flipY &&
        other.interaction == interaction &&
        other.boxConstraints == boxConstraints &&
        other.groupId == groupId &&
        mapIsEqual(other.meta, meta);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        offset.hashCode ^
        rotation.hashCode ^
        scale.hashCode ^
        flipX.hashCode ^
        flipY.hashCode ^
        interaction.hashCode ^
        boxConstraints.hashCode ^
        meta.hashCode ^
        groupId.hashCode;
  }

  /// Creates a copy of this [Layer] with the given fields replaced with
  /// new values.
  Layer copyWith({
    String? id,
    String? groupId,
    Offset? offset,
    double? rotation,
    double? scale,
    bool? flipX,
    bool? flipY,
    LayerInteraction? interaction,
    Map<String, dynamic>? meta,
    BoxConstraints? boxConstraints,
  }) {
    return Layer(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      offset: offset ?? this.offset,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      interaction: interaction ?? this.interaction,
      meta: meta ?? this.meta,
      boxConstraints: boxConstraints ?? this.boxConstraints,
    );
  }

  /// Fills the given [DiagnosticPropertiesBuilder] with properties of this
  /// layer for debugging and development tools.
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(StringProperty('id', id))
      ..add(StringProperty('groupId', groupId))
      ..add(DoubleProperty('rotation', rotation))
      ..add(DoubleProperty('scale', scale))
      ..add(DiagnosticsProperty<bool>('flipX', flipX))
      ..add(DiagnosticsProperty<bool>('flipY', flipY))
      ..add(DiagnosticsProperty<Offset>('offset', offset))
      ..add(DiagnosticsProperty<Map<String, dynamic>>('meta', meta))
      ..add(
        DiagnosticsProperty<BoxConstraints>('boxConstraints', boxConstraints),
      )
      ..add(DiagnosticsProperty<LayerInteraction>('interaction', interaction))
      ..add(FlagProperty('isEmojiLayer', value: isEmojiLayer, ifTrue: 'true'))
      ..add(FlagProperty('isPaintLayer', value: isPaintLayer, ifTrue: 'true'))
      ..add(FlagProperty('isWidgetLayer', value: isWidgetLayer, ifTrue: 'true'))
      ..add(FlagProperty('isTextLayer', value: isTextLayer, ifTrue: 'true'));
  }
}
