import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/core/models/layers/layer_interaction.dart';
import 'package:pro_image_editor/features/paint_editor/paint_editor.dart';

void main() {
  group('Layer', () {
    test('Default constructor initializes properties correctly', () {
      final layer = Layer();

      expect(layer.offset, Offset.zero);
      expect(layer.rotation, 0);
      expect(layer.scale, 1);
      expect(layer.flipX, false);
      expect(layer.flipY, false);
      expect(layer.meta, isNull);
      expect(layer.boxConstraints, isNull);
      expect(layer.interaction, isA<LayerInteraction>());
      expect(layer.key, isA<GlobalKey>());
      expect(layer.keyInternalSize, isA<GlobalKey>());
    });

    test('Factory constructor fromMap initializes properties correctly', () {
      final map = {
        'x': 10.0,
        'y': 20.0,
        'rotation': 45.0,
        'scale': 2.0,
        'flipX': true,
        'flipY': false,
        'meta': {'key': 'value'},
        'interaction': {'movable': true},
        'boxConstraints': {
          'minWidth': 50.0,
          'minHeight': 50.0,
          'maxWidth': 100.0,
          'maxHeight': 100.0,
        },
        'type': 'default',
      };

      final layer = Layer.fromMap(map);

      expect(layer.offset, const Offset(10.0, 20.0));
      expect(layer.rotation, 45.0);
      expect(layer.scale, 2.0);
      expect(layer.flipX, true);
      expect(layer.flipY, false);
      expect(layer.meta, {'key': 'value'});
      expect(layer.boxConstraints, isNotNull);
      expect(layer.boxConstraints!.minWidth, 50.0);
      expect(layer.boxConstraints!.minHeight, 50.0);
      expect(layer.boxConstraints!.maxWidth, 100.0);
      expect(layer.boxConstraints!.maxHeight, 100.0);
    });

    test('toMap converts Layer properties to a map', () {
      final layer = Layer(
        offset: const Offset(10.0, 20.0),
        rotation: 45.0,
        scale: 2.0,
        flipX: true,
        flipY: false,
        meta: {'key': 'value'},
        boxConstraints: const BoxConstraints(
          minWidth: 50.0,
          minHeight: 50.0,
          maxWidth: 100.0,
          maxHeight: 100.0,
        ),
      );

      final map = layer.toMap();

      expect(map['x'], 10.0);
      expect(map['y'], 20.0);
      expect(map['rotation'], 45.0);
      expect(map['scale'], 2.0);
      expect(map['flipX'], true);
      expect(map['flipY'], false);
      expect(map['meta'], {'key': 'value'});
      expect(map['boxConstraints'], isNotNull);
      expect(map['boxConstraints']['minWidth'], 50.0);
      expect(map['boxConstraints']['minHeight'], 50.0);
      expect(map['boxConstraints']['maxWidth'], 100.0);
      expect(map['boxConstraints']['maxHeight'], 100.0);
    });
  });

  group('Layer toMap/fromMap tests', () {
    test('Base Layer', () {
      final original = Layer(
        id: 'base-id',
        offset: const Offset(20, 30),
        rotation: 15.5,
        scale: 2.0,
        flipX: true,
        flipY: false,
        meta: {'custom': 'value'},
        interaction: LayerInteraction(
          enableEdit: true,
          enableMove: false,
          enableRotate: true,
          enableScale: false,
          enableSelection: true,
        ),
        boxConstraints: const BoxConstraints(
          minWidth: 10,
          minHeight: 20,
          maxWidth: 100,
          maxHeight: 200,
        ),
      );

      final map = original.toMap();
      final recreated = Layer.fromMap(map, id: original.id);

      expect(recreated, equals(original));
    });

    test('EmojiLayer', () {
      final original = EmojiLayer(
        id: 'emoji-id',
        emoji: '😎',
        offset: const Offset(50, 100),
        rotation: 90,
        scale: 0.5,
        flipX: false,
        flipY: true,
        meta: {'emojiMeta': 'value'},
        boxConstraints: const BoxConstraints(minWidth: 1, maxWidth: 500),
        interaction: LayerInteraction(
          enableEdit: true,
          enableMove: false,
          enableRotate: true,
          enableScale: false,
          enableSelection: true,
        ),
      );

      final map = original.toMap();
      final recreated = Layer.fromMap(map, id: original.id);

      expect(recreated, equals(original));
    });

    test('TextLayer', () {
      final original = TextLayer(
        id: 'text-id',
        text: 'Hello, Flutter!',
        textStyle: const TextStyle(fontSize: 20, color: Colors.blue),
        offset: const Offset(0, 0),
        rotation: 0,
        scale: 1,
        interaction: LayerInteraction(
          enableEdit: true,
          enableMove: false,
          enableRotate: true,
          enableScale: false,
          enableSelection: true,
        ),
        align: TextAlign.left,
        background: Colors.red,
        boxConstraints: const BoxConstraints(minWidth: 1, maxWidth: 500),
        color: Colors.blue,
        colorMode: LayerBackgroundMode.backgroundAndColor,
        customSecondaryColor: true,
        flipX: true,
        flipY: false,
        fontScale: 12,
        maxTextWidth: 20,
        meta: {'lang': 'en'},
      );

      final map = original.toMap();
      final recreated = Layer.fromMap(map, id: original.id);

      expect(recreated, equals(original));
    });

    test('PaintLayer', () {
      final original = PaintLayer(
        id: 'paint-id',
        item: PaintedModel(
          mode: PaintMode.arrow,
          offsets: [Offset.zero, const Offset(50, 50)],
          erasedOffsets: [],
          color: Colors.amber,
          strokeWidth: 10,
          opacity: 0.8,
          fill: false,
        ),
        offset: const Offset(10, 20),
        scale: 1.2,
        opacity: 0.5,
        rawSize: const Size(50, 50),
        rotation: 10,
        flipX: true,
        flipY: false,
        boxConstraints: const BoxConstraints(minWidth: 1, maxWidth: 500),
        interaction: LayerInteraction(
          enableEdit: true,
          enableMove: false,
          enableRotate: true,
          enableScale: false,
          enableSelection: true,
        ),
        meta: {'meta': 'test'},
      );

      final map = original.toMap();
      final recreated = Layer.fromMap(map, id: original.id);

      expect(recreated, equals(original));
    });

    test('WidgetLayer', () {
      final original = WidgetLayer(
        id: 'widget-id',
        offset: const Offset(10, 20),
        rotation: 180,
        scale: 0.9,
        flipX: true,
        flipY: false,
        boxConstraints: const BoxConstraints(minWidth: 1, maxWidth: 500),
        interaction: LayerInteraction(
          enableEdit: true,
          enableMove: false,
          enableRotate: true,
          enableScale: false,
          enableSelection: true,
        ),
        meta: {'meta': 'test'},
        exportConfigs: const WidgetLayerExportConfigs(networkUrl: 'Test-Url'),
        widget: Container(),
      );

      final map = original.toMap();
      final recreated = Layer.fromMap(map, id: original.id);

      expect(recreated, equals(original));
    });
  });

  group('Layer animations', () {
    const acceptanceAnimations = [
      LayerAnimation(
        type: LayerAnimationType.slide,
        phase: AnimationPhase.animateIn,
        duration: Duration(milliseconds: 400),
        slideDirection: SlideDirection.left,
        curve: AnimationCurve.easeOut,
      ),
      LayerAnimation(
        type: LayerAnimationType.fade,
        phase: AnimationPhase.animateOut,
        duration: Duration(milliseconds: 300),
      ),
    ];

    test('toMap serializes animations only when non-empty', () {
      expect(Layer().toMap().containsKey('animations'), isFalse);

      final map = Layer(animations: acceptanceAnimations).toMap();
      expect(map['animations'], isA<List<dynamic>>());
      expect(map['animations'], hasLength(2));
      expect(map['animations'][0]['type'], 'slide');
      expect(map['animations'][0]['slideDirection'], 'left');
      expect(map['animations'][0]['curve'], 'easeOut');
      expect(map['animations'][1]['type'], 'fade');
      expect(map['animations'][1]['phase'], 'animateOut');
    });

    test('base Layer round-trips animations', () {
      final original = Layer(
        id: 'anim-id',
        startTime: const Duration(seconds: 1),
        endTime: const Duration(seconds: 5),
        animations: acceptanceAnimations,
      );

      final recreated = Layer.fromMap(original.toMap(), id: original.id);

      expect(recreated.animations, acceptanceAnimations);
      expect(recreated, equals(original));
    });

    test('WidgetLayer round-trips animations', () {
      final original = WidgetLayer(
        id: 'widget-anim-id',
        widget: Container(),
        startTime: const Duration(seconds: 1),
        endTime: const Duration(seconds: 5),
        exportConfigs: const WidgetLayerExportConfigs(networkUrl: 'Test-Url'),
        animations: const [
          LayerAnimation(
            type: LayerAnimationType.scale,
            phase: AnimationPhase.animateInOut,
            duration: Duration(milliseconds: 250),
            scaleFrom: 0.4,
          ),
        ],
      );

      final recreated = Layer.fromMap(original.toMap(), id: original.id);

      expect(recreated, isA<WidgetLayer>());
      expect(recreated.animations, original.animations);
    });

    test('copyWith carries and overrides animations', () {
      final layer = TextLayer(text: 'hi', animations: acceptanceAnimations);

      expect(layer.copyWith().animations, acceptanceAnimations);
      expect(layer.copyWith(animations: const []).animations, isEmpty);
    });

    test('effectiveAnimations returns explicit animations when present', () {
      final layer = Layer(
        enterDuration: const Duration(milliseconds: 500),
        animations: acceptanceAnimations,
      );

      expect(layer.effectiveAnimations, acceptanceAnimations);
    });

    test('effectiveAnimations derives fades from legacy duration fields', () {
      final layer = Layer(
        enterDuration: const Duration(milliseconds: 500),
        exitDuration: const Duration(milliseconds: 300),
        enterCurve: Curves.easeOut,
      );

      final derived = layer.effectiveAnimations;
      expect(derived, hasLength(2));
      expect(derived[0].type, LayerAnimationType.fade);
      expect(derived[0].phase, AnimationPhase.animateIn);
      expect(derived[0].duration, const Duration(milliseconds: 500));
      expect(derived[0].curve, AnimationCurve.easeOut);
      expect(derived[1].type, LayerAnimationType.fade);
      expect(derived[1].phase, AnimationPhase.animateOut);
      expect(derived[1].duration, const Duration(milliseconds: 300));
    });

    test('effectiveAnimations is empty when nothing is configured', () {
      expect(Layer().effectiveAnimations, isEmpty);
    });

    test('effectiveAnimations defaults curves to the preview defaults', () {
      // No explicit curve → must mirror the preview defaults
      // (LayerTimelineConfigs.enterCurve easeIn / exitCurve easeOut) instead of
      // falling back to linear, so the export matches the in-editor preview.
      final layer = Layer(
        enterDuration: const Duration(milliseconds: 500),
        exitDuration: const Duration(milliseconds: 300),
      );

      final derived = layer.effectiveAnimations;
      expect(derived[0].curve, AnimationCurve.easeIn);
      expect(derived[1].curve, AnimationCurve.easeOut);
    });

    test('default animations list is growable and mutable', () {
      final layer = Layer();
      expect(
        () => layer.animations.add(
          const LayerAnimation(
            type: LayerAnimationType.fade,
            phase: AnimationPhase.animateIn,
            duration: Duration(milliseconds: 200),
          ),
        ),
        returnsNormally,
      );
      expect(layer.animations, hasLength(1));
    });
  });
}
