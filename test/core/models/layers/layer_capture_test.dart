import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/layer_repaint_boundary.dart';

import '../../../mock/mock_image.dart';

void main() {
  group('Layer capture', () {
    Future<ProImageEditorState> pumpEditor(WidgetTester tester) async {
      final key = GlobalKey<ProImageEditorState>();

      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            mockMemoryImage,
            key: key,
            callbacks: const ProImageEditorCallbacks(),
            configs: const ProImageEditorConfigs(
              progressIndicatorConfigs: ProgressIndicatorConfigs(
                widgets: ProgressIndicatorWidgets(
                  circularProgressIndicator: SizedBox.shrink(),
                ),
              ),
              imageGeneration: ImageGenerationConfigs(
                enableBackgroundGeneration: false,
                enableIsolateGeneration: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ProImageEditor), findsOneWidget);
      return key.currentState!;
    }

    test('captureAsPng returns null for unmounted layer', () async {
      final layer = TextLayer(text: 'not mounted');
      final bytes = await layer.captureAsPng();
      expect(bytes, isNull);
    });

    test('captureAllLayersAsBytes returns empty list when no layers', () async {
      final result = await Layer.captureAllLayersAsBytes(layers: []);
      expect(result, isEmpty);
    });

    test('captureAllLayers returns empty list when no layers', () async {
      final result = await Layer.captureAllLayers(layers: []);
      expect(result, isEmpty);
    });

    test(
      'captureAllLayersAsBytes with unmounted layers returns nulls',
      () async {
        final layers = [TextLayer(text: 'a'), EmojiLayer(emoji: '😀')];
        final result = await Layer.captureAllLayersAsBytes(layers: layers);
        expect(result.length, 2);
        expect(result[0], isNull);
        expect(result[1], isNull);
      },
    );

    test('captureAllLayers skips unmounted layers (null bytes)', () async {
      final layers = [TextLayer(text: 'a'), EmojiLayer(emoji: '😀')];
      final result = await Layer.captureAllLayers(layers: layers);
      // All bytes are null since layers aren't mounted → no exported layers
      expect(result, isEmpty);
    });

    testWidgets('captureAsPng produces bytes for a mounted layer', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpEditor(tester);

        final layer = EmojiLayer(emoji: '😀');
        editor.addLayer(layer);
        await tester.pumpAndSettle();

        final bytes = await layer.captureAsPng(applyTransforms: false);
        expect(bytes, isNotNull);
        expect(bytes!, isNotEmpty);
      });
    });

    testWidgets('captureAsPng with applyTransforms bakes rotation/flip', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpEditor(tester);

        final layer = EmojiLayer(emoji: '🔥', rotation: 0.5, flipX: true);
        editor.addLayer(layer);
        await tester.pumpAndSettle();

        final bytes = await layer.captureAsPng(applyTransforms: true);
        expect(bytes, isNotNull);
        expect(bytes!, isNotEmpty);
      });
    });

    testWidgets('captureAsPng with non-png format uses toByteData path', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpEditor(tester);

        final layer = EmojiLayer(emoji: '🌟');
        editor.addLayer(layer);
        await tester.pumpAndSettle();

        final bytes = await layer.captureAsPng(
          format: ui.ImageByteFormat.rawRgba,
        );
        expect(bytes, isNotNull);
        expect(bytes!, isNotEmpty);
      });
    });

    testWidgets('captureAllLayersAsBytes captures multiple mounted layers', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpEditor(tester);

        final emoji = EmojiLayer(emoji: '😀');
        final text = TextLayer(text: 'Test');
        editor
          ..addLayer(emoji)
          ..addLayer(text);
        await tester.pumpAndSettle();

        final result = await Layer.captureAllLayersAsBytes(
          layers: editor.activeLayers,
          applyTransforms: false,
        );

        expect(result.length, 2);
        for (final bytes in result) {
          expect(bytes, isNotNull);
          expect(bytes!, isNotEmpty);
        }
      });
    });

    testWidgets('captureAllLayers returns ExportedLayer list with metadata', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpEditor(tester);

        final emoji = EmojiLayer(emoji: '😀');
        final text = TextLayer(text: 'Hello');
        editor
          ..addLayer(emoji)
          ..addLayer(text);
        await tester.pumpAndSettle();

        final exported = await Layer.captureAllLayers(
          layers: editor.activeLayers,
          applyTransforms: false,
        );

        expect(exported.length, 2);
        for (final e in exported) {
          expect(e, isA<ExportedLayer>());
          expect(e.bytes, isNotEmpty);
          expect(e.logicalSize, isNot(Size.zero));
          expect(e.logicalSize.width, greaterThan(0));
          expect(e.logicalSize.height, greaterThan(0));
        }
      });
    });

    // Note: ProImageEditorState.captureAllLayersWithMeta and
    // captureAllLayers use `await WidgetsBinding.instance.endOfFrame`
    // which hangs in test environments. They are thin wrappers around
    // Layer.captureAllLayers which is tested above.

    testWidgets('captureAsPng with explicit pixelRatio', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpEditor(tester);

        final layer = EmojiLayer(emoji: '📏');
        editor.addLayer(layer);
        await tester.pumpAndSettle();

        final bytes = await layer.captureAsPng(
          pixelRatio: 1.0,
          applyTransforms: false,
        );
        expect(bytes, isNotNull);
        expect(bytes!, isNotEmpty);
      });
    });

    testWidgets(
      'captureAsPng reads the last paint of a layer laid out while hidden',
      (WidgetTester tester) async {
        final layer = EmojiLayer(emoji: '😀');
        // Like the editor faded out by the route opened on done, while the
        // layer's timeline window opens and it is laid out again.
        Widget build({required bool hidden, required double maxWidth}) {
          return Center(
            child: Opacity(
              opacity: hidden ? 0 : 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: LayerRepaintBoundary(
                  key: layer.repaintBoundaryKey,
                  child: const SizedBox.square(
                    dimension: 4,
                    child: ColoredBox(color: Color(0xFFFF0000)),
                  ),
                ),
              ),
            ),
          );
        }

        await tester.pumpWidget(build(hidden: false, maxWidth: 100));
        await tester.pumpWidget(build(hidden: true, maxWidth: 100));
        await tester.pumpWidget(build(hidden: true, maxWidth: 50));

        final bytes = await tester.runAsync(
          () => layer.captureAsPng(
            pixelRatio: 1,
            applyTransforms: false,
            format: ui.ImageByteFormat.rawRgba,
          ),
        );

        expect(bytes, hasLength(4 * 4 * 4));
        expect(bytes!.sublist(0, 4), [255, 0, 0, 255]);
      },
    );
  });
}
