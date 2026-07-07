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
/// custom-painted content on a canvas. A single layer can hold one or more
/// [PaintedModel] strokes (see [items]); a freshly drawn layer holds exactly
/// one stroke while a layer produced by merging several paint layers holds
/// several. You can specify the painted item(s) and their raw size, along with
/// optional properties like offset, rotation, scale, and more.
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
  /// Provide either a single [item] (the common case, a single stroke) or a
  /// list of [items] (a merged layer holding several strokes). Exactly one of
  /// them must be supplied. [rawSize] and [opacity] are required, and the other
  /// properties are optional.
  PaintLayer({
    PaintedModel? item,
    List<PaintedModel>? items,
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
    super.animations,
  }) : assert(
         item != null || (items != null && items.isNotEmpty),
         'Provide either `item` or a non-empty `items` list.',
       ),
       items = items != null ? List<PaintedModel>.of(items) : [item!];

  /// Factory constructor for creating a PaintLayer instance from a
  /// Layer and a map.
  factory PaintLayer.fromMap(
    Layer layer,
    Map<String, dynamic> map, {
    EditorKeyMinifier? minifier,
  }) {
    var keyConverter = minifier?.convertLayerKey ?? (String key) => key;
    var paintKeyConverter = minifier?.convertPaintKey;

    /// Reads the list of painted strokes.
    ///
    /// New payloads store every stroke in an `items` array. Legacy payloads
    /// (and payloads written by older versions for a single stroke) only carry
    /// a single `item` map, which is read as a one-element list.
    final rawItems = map[keyConverter('items')];
    final List<PaintedModel> items;
    if (rawItems is List && rawItems.isNotEmpty) {
      items = rawItems
          .map(
            (el) => PaintedModel.fromMap(
              Map<String, dynamic>.from(el as Map),
              keyConverter: paintKeyConverter,
            ),
          )
          .toList();
    } else {
      items = [
        PaintedModel.fromMap(
          map[keyConverter('item')] ?? {},
          keyConverter: paintKeyConverter,
        ),
      ];
    }

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
      animations: layer.animations,
      opacity: safeParseDouble(map[keyConverter('opacity')], fallback: 1.0),
      rawSize: Size(
        safeParseDouble(map[keyConverter('rawSize')]?['w'], fallback: 0),
        safeParseDouble(map[keyConverter('rawSize')]?['h'], fallback: 0),
      ),
      items: items,
      boxConstraints: layer.boxConstraints,
    );
  }

  /// The custom-painted strokes to display on the layer.
  ///
  /// Always holds at least one entry. A layer drawn in the paint editor has a
  /// single entry; a layer produced by [mergeSelectedLayers] holds every
  /// baked-in stroke, each with its own color/mode/strokeWidth/opacity and
  /// erased offsets.
  List<PaintedModel> items;

  /// The primary painted item.
  ///
  /// Back-compat accessor mapping to the first entry of [items]. Existing code
  /// that constructs, reads or mutates a single `item` keeps working unchanged.
  PaintedModel get item => items.first;
  set item(PaintedModel value) {
    if (items.isEmpty) {
      items.add(value);
    } else {
      items[0] = value;
    }
  }

  /// The raw size of the painted item before applying scaling.
  final Size rawSize;

  /// The opacity level of the drawing.
  double opacity;

  /// Returns the size of the layer after applying the scaling factor.
  Size get size => Size(rawSize.width * scale, rawSize.height * scale);

  /// Whether any stroke of this layer is currently marked as hit (hovered /
  /// pressed).
  bool get isHit => items.any((item) => item.hit);

  /// Resets the hit state of every stroke.
  void resetHit() {
    for (final item in items) {
      item.hit = false;
    }
  }

  /// Whether this layer represents a censor area (blur / pixelate). A censor
  /// layer always holds a single censor stroke.
  bool get isCensor => items.any((item) => item.isCensorArea);

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

      /// The first stroke is always written under the legacy `item` key so
      /// older readers keep rendering (at least) the first stroke.
      'item': items.first.toMap(
        maxDecimalPlaces: maxDecimalPlaces,
        enableMinify: enableMinify,
      ),

      /// Multi-stroke (merged) layers additionally serialize the full list.
      if (items.length > 1)
        'items': items
            .map(
              (item) => item.toMap(
                maxDecimalPlaces: maxDecimalPlaces,
                enableMinify: enableMinify,
              ),
            )
            .toList(),
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

    final bool itemsChanged = !_listEquals(paintLayer.items, items);

    return {
      ...super.toMapFromReference(
        layer,
        maxDecimalPlaces: maxDecimalPlaces,
        enableMinify: enableMinify,
      ),
      if (itemsChanged)
        'item': items.first.toMap(
          maxDecimalPlaces: maxDecimalPlaces,
          enableMinify: enableMinify,
        ),
      if (itemsChanged && items.length > 1)
        'items': items
            .map(
              (item) => item.toMap(
                maxDecimalPlaces: maxDecimalPlaces,
                enableMinify: enableMinify,
              ),
            )
            .toList(),
      if (paintLayer.rawSize != rawSize)
        'rawSize': {
          'w': rawSize.width.roundSmart(maxDecimalPlaces),
          'h': rawSize.height.roundSmart(maxDecimalPlaces),
        },
      if (paintLayer.opacity != opacity) 'opacity': opacity,
    };
  }

  bool _listEquals(List<PaintedModel> a, List<PaintedModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Creates a copy of this [PaintLayer] with the given fields replaced with
  /// new values.
  @override
  PaintLayer copyWith({
    PaintedModel? item,
    List<PaintedModel>? items,
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
    List<LayerAnimation>? animations,
  }) {
    return PaintLayer(
      items: items ?? (item != null ? [item] : this.items),
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
      animations: animations ?? this.animations,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('opacity', opacity))
      ..add(DiagnosticsProperty<Size>('rawSize', rawSize))
      ..add(DiagnosticsProperty<Size>('size', size))
      ..add(IntProperty('itemsCount', items.length));
    for (final item in items) {
      item.debugFillProperties(properties);
    }
  }
}
