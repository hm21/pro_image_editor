import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/features/main_editor/services/layer_copy_manager.dart';
import 'package:pro_image_editor/features/main_editor/services/layer_interaction_manager.dart';

void main() {
  TextLayer outlinedLayer() => TextLayer(
    text: 'Outlined',
    outlineWidth: 2.5,
    outlineColor: const Color(0xFFFF0000),
    textStyle: const TextStyle(
      shadows: [Shadow(blurRadius: 4, offset: Offset(1, 2))],
    ),
  );

  group(LayerCopyManager, () {
    test('keeps the outline and shadows of a text layer', () {
      final layer = outlinedLayer();

      final copy = LayerCopyManager().copyLayer(layer) as TextLayer;

      expect(copy, isNot(same(layer)));
      expect(copy.outlineWidth, 2.5);
      expect(copy.outlineColor, const Color(0xFFFF0000));
      expect(copy.textStyle?.shadows, layer.textStyle?.shadows);
    });
  });

  group(LayerInteractionManager, () {
    test('keeps the outline of a text layer it groups', () {
      final layer = outlinedLayer();
      final other = TextLayer(text: 'Other');
      final manager =
          LayerInteractionManager(
              helperLinesCallbacks: null,
              configs: const ProImageEditorConfigs(),
              onSelectedLayersChanged: null,
            )
            ..addSelectedLayer(layer.id)
            ..addSelectedLayer(other.id);

      List<Layer>? history;
      manager.groupSelectedLayers([layer, other], (layers) => history = layers);

      final grouped = history!.whereType<TextLayer>().firstWhere(
        (candidate) => candidate.id == layer.id,
      );
      expect(grouped.groupId, isNotNull);
      expect(grouped.outlineWidth, 2.5);
      expect(grouped.outlineColor, const Color(0xFFFF0000));
    });

    test('a duplicate moves its keyframes with it', () {
      final layer = EmojiLayer(
        emoji: '😀',
        offset: const Offset(10, 10),
        keyframes: const [
          LayerKeyframe(time: Duration.zero, offset: Offset(10, 10)),
          LayerKeyframe(time: Duration(seconds: 1), offset: Offset(-5, 0)),
        ],
      );

      final duplicate = LayerCopyManager().duplicateLayer(layer);

      expect(duplicate.offset, const Offset(40, 40));
      expect(duplicate.keyframes.map((k) => k.offset), const [
        Offset(40, 40),
        Offset(25, 30),
      ]);
      expect(layer.keyframes.first.offset, const Offset(10, 10));
    });

    group('keeps the time range, animations, keyframes and opacity', () {
      const keyframes = [
        LayerKeyframe(time: Duration.zero, offset: Offset(1, 2)),
        LayerKeyframe(time: Duration(seconds: 1), offset: Offset(3, 4)),
      ];
      const animations = [
        LayerAnimation(
          type: LayerAnimationType.fade,
          phase: AnimationPhase.animateIn,
          duration: Duration(milliseconds: 300),
        ),
      ];

      final timedLayers = <String, Layer Function()>{
        'TextLayer': () => TextLayer(text: 'Timed'),
        'EmojiLayer': () => EmojiLayer(emoji: '😀'),
        'WidgetLayer': () => WidgetLayer(widget: const SizedBox()),
        'Layer': Layer.new,
      };

      for (final MapEntry(key: name, value: create) in timedLayers.entries) {
        test('of a $name it groups and ungroups', () {
          final layer = create()
            ..startTime = const Duration(seconds: 2)
            ..endTime = const Duration(seconds: 5)
            ..animations = animations
            ..keyframes = keyframes
            ..opacity = 0.4;
          final other = TextLayer(text: 'Other');
          final manager =
              LayerInteractionManager(
                  helperLinesCallbacks: null,
                  configs: const ProImageEditorConfigs(),
                  onSelectedLayersChanged: null,
                )
                ..addSelectedLayer(layer.id)
                ..addSelectedLayer(other.id);

          void expectKept(Layer copy) {
            expect(copy, isNot(same(layer)));
            expect(copy.startTime, const Duration(seconds: 2));
            expect(copy.endTime, const Duration(seconds: 5));
            expect(copy.animations, animations);
            expect(copy.keyframes, keyframes);
            expect(copy.opacity, 0.4);
          }

          List<Layer>? grouped;
          manager.groupSelectedLayers([
            layer,
            other,
          ], (layers) => grouped = layers);
          final groupedLayer = grouped!.firstWhere((l) => l.id == layer.id);
          expect(groupedLayer.groupId, isNotNull);
          expectKept(groupedLayer);

          List<Layer>? ungrouped;
          manager.ungroupLayer(
            groupedLayer,
            grouped!,
            (layers) => ungrouped = layers,
          );
          final ungroupedLayer = ungrouped!.firstWhere((l) => l.id == layer.id);
          expect(ungroupedLayer.groupId, isNull);
          expectKept(ungroupedLayer);
        });
      }
    });
  });
}
