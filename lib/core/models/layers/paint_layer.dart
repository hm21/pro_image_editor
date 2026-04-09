import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '/core/constants/int_constants.dart';
import '/features/paint_editor/models/painted_model.dart';
import '/shared/extensions/num_extension.dart';
import '/shared/services/import_export/utils/key_minifier.dart';
import '/shared/utils/parser/double_parser.dart';
import 'layer.dart';
import 'layer_interaction.dart';

/// A class representing a layer with custom paint content.
///
/// PaintLayer is a subclass of [Layer] that allows you to display
/// custom-painted content on a canvas. You can specify the painted item and
/// its raw size, along with optional properties like offset, rotation,
/// scale, and more.
///
/// Example usage:
/// ```dart
/// PaintLayer(
///   item: CustomPaintedItem(),
///   rawSize: Size(200.0, 150.0),
///   offset: Offset(50.0, 50.0),
///   rotation: -30.0,
///   scale: 1.5,
/// );
/// ```
class PaintLayer extends Layer {
  /// Creates an instance of PaintLayer.
  ///
  /// The [item] and [rawSize] parameters are required, and other properties
  /// are optional.
  PaintLayer({
    required this.item,
    required this.rawSize,
    required this.opacity,
    super.offset,
    super.rotation,
    super.scale,
    super.id,
    super.flipX,
    super.flipY,
    super.interaction,
    super.meta,
    super.boxConstraints,
    super.key,
    super.groupId,
    super.startTime,
    super.endTime,
    super.enterDuration,
    super.exitDuration,
    super.enterCurve,
    super.exitCurve,
    super.transitionBuilder,
  });

  /// Factory constructor for creating a PaintLayer instance from a
  /// Layer and a map.
  factory PaintLayer.fromMap(
    Layer layer,
    Map<String, dynamic> map, {
    EditorKeyMinifier? minifier,
  }) {
    var keyConverter = minifier?.convertLayerKey ?? (String key) => key;

    /// Constructs and returns a PaintLayer instance with properties
    /// derived from the layer and map.
    return PaintLayer(
      id: layer.id,
      flipX: layer.flipX,
      flipY: layer.flipY,
      interaction: layer.interaction,
      offset: layer.offset,
      rotation: layer.rotation,
      scale: layer.scale,
      meta: layer.meta,
      groupId: layer.groupId,
      startTime: layer.startTime,
      endTime: layer.endTime,
      enterDuration: layer.enterDuration,
      exitDuration: layer.exitDuration,
      opacity: safeParseDouble(map[keyConverter('opacity')], fallback: 1.0),
      rawSize: Size(
        safeParseDouble(map[keyConverter('rawSize')]?['w'], fallback: 0),
        safeParseDouble(map[keyConverter('rawSize')]?['h'], fallback: 0),
      ),
      item: PaintedModel.fromMap(
        map[keyConverter('item')] ?? {},
        keyConverter: minifier?.convertPaintKey,
      ),
      boxConstraints: layer.boxConstraints,
    );
  }

  /// The custom-painted item to display on the layer.
  PaintedModel item;

  /// The raw size of the painted item before applying scaling.
  final Size rawSize;

  /// The opacity level of the drawing.
  double opacity;

  /// Returns the size of the layer after applying the scaling factor.
  Size get size => Size(rawSize.width * scale, rawSize.height * scale);

  @override
  bool get isPaintLayer => true;

  @override
  Map<String, dynamic> toMap({
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) {
    return {
      ...super.toMap(
        maxDecimalPlaces: maxDecimalPlaces,
        enableMinify: enableMinify,
      ),
      'item': item.toMap(
        maxDecimalPlaces: maxDecimalPlaces,
        enableMinify: enableMinify,
      ),
      'rawSize': {
        'w': rawSize.width.roundSmart(maxDecimalPlaces),
        'h': rawSize.height.roundSmart(maxDecimalPlaces),
      },
      'opacity': opacity.roundSmart(maxDecimalPlaces),
      'type': 'paint',
    };
  }

  @override
  Map<String, dynamic> toMapFromReference(
    Layer layer, {
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
    bool enableMinify = false,
  }) {
    var paintLayer = layer as PaintLayer;
    return {
      ...super.toMapFromReference(
        layer,
        maxDecimalPlaces: maxDecimalPlaces,
        enableMinify: enableMinify,
      ),
      if (paintLayer.item != item)
        'item': item.toMap(
          maxDecimalPlaces: maxDecimalPlaces,
          enableMinify: enableMinify,
        ),
      if (paintLayer.rawSize != rawSize)
        'rawSize': {
          'w': rawSize.width.roundSmart(maxDecimalPlaces),
          'h': rawSize.height.roundSmart(maxDecimalPlaces),
        },
      if (paintLayer.opacity != opacity) 'opacity': opacity,
    };
  }

  /// Creates a copy of this [PaintLayer] with the given fields replaced with
  /// new values.
  @override
  PaintLayer copyWith({
    PaintedModel? item,
    Size? rawSize,
    double? opacity,
    Offset? offset,
    double? rotation,
    double? scale,
    bool? flipX,
    bool? flipY,
    LayerInteraction? interaction,
    Map<String, dynamic>? meta,
    BoxConstraints? boxConstraints,
    String? id,
    String? groupId,
    Duration? startTime,
    Duration? endTime,
    Duration? enterDuration,
    Duration? exitDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    LayerTimelineTransitionBuilder? transitionBuilder,
  }) {
    return PaintLayer(
      item: item ?? this.item,
      rawSize: rawSize ?? this.rawSize,
      opacity: opacity ?? this.opacity,
      offset: offset ?? this.offset,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      id: id ?? this.id,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      interaction: interaction ?? this.interaction,
      meta: meta ?? this.meta,
      boxConstraints: boxConstraints ?? this.boxConstraints,
      groupId: groupId ?? this.groupId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enterDuration: enterDuration ?? this.enterDuration,
      exitDuration: exitDuration ?? this.exitDuration,
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('opacity', opacity))
      ..add(DiagnosticsProperty<Size>('rawSize', rawSize))
      ..add(DiagnosticsProperty<Size>('size', size));
    item.debugFillProperties(properties);
  }
}
