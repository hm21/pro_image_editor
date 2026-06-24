// Dart imports:
import 'dart:math' as math;
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '/core/constants/int_constants.dart';
import '/core/models/editor_configs/image_generation_configs/image_generation_configs.dart';
import '/core/models/editor_configs/video/layer_timeline_configs.dart';
import '/shared/extensions/box_constraints_extension.dart';
import '/shared/extensions/export_bool_extension.dart';
import '/shared/extensions/num_extension.dart';
import '/shared/services/content_recorder/controllers/content_recorder_controller.dart';
import '/shared/services/import_export/types/widget_loader.dart';
import '/shared/services/import_export/utils/key_minifier.dart';
import '/shared/utils/map_utils.dart';
import '/shared/utils/parser/animation_curve_parser.dart';
import '/shared/utils/parser/bool_parser.dart';
import '/shared/utils/parser/curve_parser.dart';
import '/shared/utils/parser/double_parser.dart';
import '/shared/utils/unique_id_generator.dart';
import '../editor_image.dart';
import 'emoji_layer.dart';
import 'exported_layer.dart';
import 'layer_animation.dart';
import 'layer_interaction.dart';
import 'paint_layer.dart';
import 'text_layer.dart';
import 'widget_layer.dart';

export '/core/models/editor_configs/video/layer_timeline_configs.dart'
    show LayerTimelineTransitionBuilder;
export 'emoji_layer.dart';
export 'layer_animation.dart';
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
    this.startTime,
    this.endTime,
    this.enterDuration,
    this.exitDuration,
    this.enterCurve,
    this.exitCurve,
    this.transitionBuilder,
    List<LayerAnimation>? animations,
  }) : key = key ??= GlobalKey(),
       keyInternalSize = GlobalKey(),
       repaintBoundaryKey = GlobalKey(),
       id = id ?? generateUniqueId(),
       interaction = interaction ?? LayerInteraction(),
       animations = animations ?? <LayerAnimation>[];

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
      startTime: map[keyConverter('startTime')] != null
          ? Duration(milliseconds: map[keyConverter('startTime')] as int)
          : null,
      endTime: map[keyConverter('endTime')] != null
          ? Duration(milliseconds: map[keyConverter('endTime')] as int)
          : null,
      enterDuration: map[keyConverter('enterDuration')] != null
          ? Duration(milliseconds: map[keyConverter('enterDuration')] as int)
          : null,
      exitDuration: map[keyConverter('exitDuration')] != null
          ? Duration(milliseconds: map[keyConverter('exitDuration')] as int)
          : null,
      enterCurve: parseCurve(map[keyConverter('enterCurve')] as String?),
      exitCurve: parseCurve(map[keyConverter('exitCurve')] as String?),
      animations: (map[keyConverter('animations')] as List<dynamic>?)
          ?.map(
            (e) => LayerAnimation.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
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

  /// The time at which this layer becomes visible.
  ///
  /// Only used in the video editor. When `null`, the layer is always visible.
  Duration? startTime;

  /// The time at which this layer stops being visible.
  ///
  /// Only used in the video editor. When `null`, the layer is always visible.
  Duration? endTime;

  /// How long the fade-in animation lasts in **video time**.
  ///
  /// The transition starts at [startTime] and finishes at
  /// `startTime + enterDuration`. When `null`, no fade-in is applied.
  Duration? enterDuration;

  /// How long the fade-out animation lasts in **video time**.
  ///
  /// The transition starts at `endTime - exitDuration` and finishes at
  /// [endTime]. When `null`, no fade-out is applied.
  Duration? exitDuration;

  /// The curve applied to the fade-in animation for this layer.
  ///
  /// When `null`, falls back to [LayerTimelineConfigs.enterCurve].
  Curve? enterCurve;

  /// The curve applied to the fade-out animation for this layer.
  ///
  /// When `null`, falls back to [LayerTimelineConfigs.exitCurve].
  Curve? exitCurve;

  /// A builder that wraps this layer with an animated transition.
  ///
  /// When `null`, falls back to [LayerTimelineConfigs.transitionBuilder].
  ///
  /// Only used as the legacy fade convenience when [animations] is empty. When
  /// [animations] is not empty, the phase-aware fade/slide/scale composition
  /// takes over and this builder is ignored.
  LayerTimelineTransitionBuilder? transitionBuilder;

  /// Per-layer enter/leave animations for the video timeline.
  ///
  /// Each [LayerAnimation] drives a fade, slide, or scale effect during the
  /// layer's enter window (`[startTime, startTime + duration]`) and/or exit
  /// window (`[endTime - duration, endTime]`). Multiple animations can be
  /// combined on the same phase (e.g. a slide-in together with a fade-in).
  ///
  /// When empty, the layer falls back to the legacy fade convenience driven by
  /// [enterDuration] / [exitDuration] / [enterCurve] / [exitCurve] and
  /// [transitionBuilder].
  ///
  /// Mirrors the `animations` model in the sister package `pro_video_editor`
  /// so the in-editor preview matches the exported result.
  List<LayerAnimation> animations;

  /// The animations effectively applied to this layer, deriving a fade from the
  /// legacy [enterDuration] / [exitDuration] when [animations] is empty.
  ///
  /// Returns [animations] unchanged when it is not empty. Otherwise synthesizes
  /// fade [AnimationPhase.animateIn] / [AnimationPhase.animateOut] entries from
  /// the legacy fade fields, so callers (e.g. exporters bridging to
  /// `pro_video_editor`) get a single, unified animation list.
  ///
  /// When [enterCurve] / [exitCurve] are `null`, the synthesized fades fall back
  /// to the same defaults the in-editor preview uses
  /// ([LayerTimelineConfigs.enterCurve] `Curves.easeIn` /
  /// [LayerTimelineConfigs.exitCurve] `Curves.easeOut`), so the exported result
  /// matches the preview for the common legacy case.
  List<LayerAnimation> get effectiveAnimations {
    if (animations.isNotEmpty) return animations;

    return [
      if (enterDuration != null && enterDuration! > Duration.zero)
        LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: enterDuration!,
          curve: animationCurveFromCurve(enterCurve ?? Curves.easeIn),
        ),
      if (exitDuration != null && exitDuration! > Duration.zero)
        LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateOut,
          duration: exitDuration!,
          curve: animationCurveFromCurve(exitCurve ?? Curves.easeOut),
        ),
    ];
  }

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
      if (startTime != null) 'startTime': startTime!.inMilliseconds,
      if (endTime != null) 'endTime': endTime!.inMilliseconds,
      if (enterDuration != null) 'enterDuration': enterDuration!.inMilliseconds,
      if (exitDuration != null) 'exitDuration': exitDuration!.inMilliseconds,
      if (enterCurve != null) 'enterCurve': curveToString(enterCurve!),
      if (exitCurve != null) 'exitCurve': curveToString(exitCurve!),
      if (animations.isNotEmpty)
        'animations': animations.map((a) => a.toMap()).toList(),
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
      if (layer.startTime != startTime) 'startTime': startTime?.inMilliseconds,
      if (layer.endTime != endTime) 'endTime': endTime?.inMilliseconds,
      if (layer.enterDuration != enterDuration)
        'enterDuration': enterDuration?.inMilliseconds,
      if (layer.exitDuration != exitDuration)
        'exitDuration': exitDuration?.inMilliseconds,
      if (layer.enterCurve != enterCurve)
        'enterCurve': curveToString(enterCurve!),
      if (layer.exitCurve != exitCurve) 'exitCurve': curveToString(exitCurve!),
      if (!listEquals(layer.animations, animations))
        'animations': animations.map((a) => a.toMap()).toList(),
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
    double? basePixelRatio,
    bool applyTransforms = true,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
    ContentRecorderController? recorder,
  }) async {
    final context = repaintBoundaryKey.currentContext;
    if (context == null) return null;

    final dpr =
        basePixelRatio ?? MediaQuery.maybeDevicePixelRatioOf(context) ?? 3.0;
    final effectivePixelRatio = pixelRatio ?? dpr;

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
      ..drawImage(
        rawImage,
        Offset.zero,
        Paint()..filterQuality = FilterQuality.high,
      );

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
    double? basePixelRatio,
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
            basePixelRatio: basePixelRatio,
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
    double? basePixelRatio,
    bool applyTransforms = true,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
    ContentRecorderController? recorder,
  }) async {
    final logicalSizes = <Size>[];
    for (var i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final box =
          layer.repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderBox?;
      var size = box?.size ?? Size.zero;

      if (applyTransforms && (layer.rotation != 0)) {
        final double cosR = math.cos(layer.rotation).abs();
        final double sinR = math.sin(layer.rotation).abs();
        size = Size(
          size.width * cosR + size.height * sinR,
          size.width * sinR + size.height * cosR,
        );
      }

      logicalSizes.add(size);
    }

    final allBytes = await captureAllLayersAsBytes(
      layers: layers,
      pixelRatio: pixelRatio,
      basePixelRatio: basePixelRatio,
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
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.enterDuration == enterDuration &&
        other.exitDuration == exitDuration &&
        other.enterCurve == enterCurve &&
        other.exitCurve == exitCurve &&
        other.transitionBuilder == transitionBuilder &&
        listEquals(other.animations, animations) &&
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
        groupId.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        enterDuration.hashCode ^
        exitDuration.hashCode ^
        enterCurve.hashCode ^
        exitCurve.hashCode ^
        transitionBuilder.hashCode ^
        Object.hashAll(animations);
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
    Duration? startTime,
    Duration? endTime,
    Duration? enterDuration,
    Duration? exitDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    LayerTimelineTransitionBuilder? transitionBuilder,
    List<LayerAnimation>? animations,
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
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enterDuration: enterDuration ?? this.enterDuration,
      exitDuration: exitDuration ?? this.exitDuration,
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
      animations: animations ?? this.animations,
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
      ..add(FlagProperty('isTextLayer', value: isTextLayer, ifTrue: 'true'))
      ..add(DiagnosticsProperty<Duration>('startTime', startTime))
      ..add(DiagnosticsProperty<Duration>('endTime', endTime))
      ..add(DiagnosticsProperty<Duration>('enterDuration', enterDuration))
      ..add(DiagnosticsProperty<Duration>('exitDuration', exitDuration))
      ..add(DiagnosticsProperty<Curve>('enterCurve', enterCurve))
      ..add(DiagnosticsProperty<Curve>('exitCurve', exitCurve))
      ..add(
        ObjectFlagProperty<LayerTimelineTransitionBuilder>.has(
          'transitionBuilder',
          transitionBuilder,
        ),
      )
      ..add(IterableProperty<LayerAnimation>('animations', animations));
  }
}
