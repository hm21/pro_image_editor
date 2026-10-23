import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/layer_repaint_boundary.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/layer_widget_censor_item.dart';

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

    testWidgets('a box that shows its overflow captures the text past it, '
        'centered on the layer', (WidgetTester tester) async {
      await tester.runAsync(() async {
        final editor = await pumpEditor(tester);
        TextLayer boxed(TextLayerBoxOverflow overflow) => TextLayer(
          text: 'one\ntwo\nthree\nfour',
          background: const Color(0xFF000000),
          box: TextLayerBox(size: const Size(200, 40), overflow: overflow),
        );
        editor
          ..addLayer(
            boxed(TextLayerBoxOverflow.visible),
            autoCorrectZoomScale: false,
          )
          ..addLayer(
            boxed(TextLayerBoxOverflow.clip),
            autoCorrectZoomScale: false,
          );
        await tester.pumpAndSettle();
        final visible = editor.activeLayers[0] as TextLayer;

        final exported = await Layer.captureAllLayers(
          layers: editor.activeLayers,
          pixelRatio: 1,
          applyTransforms: false,
        );
        final box = Size(200 * visible.scale, 40 * visible.scale);
        Future<ui.Image> decode(Uint8List bytes) async =>
            (await (await ui.instantiateImageCodec(bytes)).getNextFrame())
                .image;

        final open = await decode(exported[0].bytes);
        expect(open.width.toDouble(), closeTo(box.width, 1));
        expect(open.height.toDouble(), greaterThan(box.height * 2));
        expect(exported[0].logicalSize.height, closeTo(open.height, 1));
        expect(exported[0].logicalSize.width, closeTo(open.width, 1));

        final cut = await decode(exported[1].bytes);
        expect(cut.height.toDouble(), closeTo(box.height, 1));
        expect(exported[1].logicalSize.height, closeTo(box.height, 0.01));
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

    group('capturePixelRatio', () {
      WidgetLayer squareLayer() => WidgetLayer(
        widget: const ColoredBox(
          color: Color(0xFFFF0000),
          child: SizedBox(width: 20, height: 20),
        ),
      );

      /// The width and height of a laid-out [layer] at [pixelRatio].
      (int, int) pixelsAt(Layer layer, double pixelRatio) {
        final size = layer.repaintBoundaryKey.currentContext!.size!;
        return (
          (size.width * pixelRatio).ceil(),
          (size.height * pixelRatio).ceil(),
        );
      }

      testWidgets('captures a layer at the pixel ratio it returns', (
        tester,
      ) async {
        await tester.runAsync(() async {
          final editor = await pumpEditor(tester);
          final layer = squareLayer();
          editor.addLayer(layer);
          await tester.pumpAndSettle();

          final calls = <(Layer, Size, double)>[];
          final bytes = await layer.captureAsPng(
            format: ui.ImageByteFormat.rawRgba,
            basePixelRatio: 2,
            applyTransforms: false,
            capturePixelRatio: (layer, size, pixelRatio) {
              calls.add((layer, size, pixelRatio));
              return 1;
            },
          );

          expect(calls, hasLength(1));
          expect(calls.single.$1, same(layer));
          expect(
            calls.single.$2,
            layer.repaintBoundaryKey.currentContext!.size,
          );
          expect(calls.single.$3, 2);
          final (width, height) = pixelsAt(layer, 1);
          expect(bytes, hasLength(width * height * 4));
        });
      });

      testWidgets('lowers only the layers it picks and keeps their sizes', (
        tester,
      ) async {
        await tester.runAsync(() async {
          final editor = await pumpEditor(tester);
          editor
            ..addLayer(squareLayer())
            ..addLayer(squareLayer());
          await tester.pumpAndSettle();
          // The editor mounts copies of the added layers.
          final [full, reduced] = editor.activeLayers;

          final exported = await Layer.captureAllLayers(
            layers: [full, reduced],
            basePixelRatio: 2,
            applyTransforms: false,
            format: ui.ImageByteFormat.rawRgba,
            capturePixelRatio: (layer, size, pixelRatio) =>
                identical(layer, reduced) ? pixelRatio / 4 : pixelRatio,
          );

          expect(exported, hasLength(2));
          final (fullWidth, fullHeight) = pixelsAt(full, 2);
          final (reducedWidth, reducedHeight) = pixelsAt(reduced, 0.5);
          expect(exported[0].bytes, hasLength(fullWidth * fullHeight * 4));
          expect(
            exported[1].bytes,
            hasLength(reducedWidth * reducedHeight * 4),
          );
          expect(exported[1].logicalSize, exported[0].logicalSize);
        });
      });

      testWidgets('asserts on a pixel ratio that is not above 0', (
        tester,
      ) async {
        await tester.runAsync(() async {
          final editor = await pumpEditor(tester);
          final layer = squareLayer();
          editor.addLayer(layer);
          await tester.pumpAndSettle();

          for (final invalid in [0.0, -1.0, double.nan, double.infinity]) {
            await expectLater(
              layer.captureAsPng(
                format: ui.ImageByteFormat.rawRgba,
                capturePixelRatio: (_, _, _) => invalid,
              ),
              throwsAssertionError,
            );
          }
        });
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

  group('Layer opacity', () {
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
      return key.currentState!;
    }

    const contentKey = ValueKey('opaque-content');

    WidgetLayer opaqueLayer({double opacity = 1, List<LayerKeyframe>? kf}) =>
        WidgetLayer(
          widget: const ColoredBox(
            key: contentKey,
            color: Color(0xFFFF0000),
            child: SizedBox(width: 20, height: 20),
          ),
          opacity: opacity,
          keyframes: kf,
        );

    /// The alpha of the pixel in the middle of [bytes], an RGBA image of a
    /// square layer.
    int centerAlpha(Uint8List bytes) {
      final side = math.sqrt(bytes.length / 4).round();
      final center = (side ~/ 2) * side + side ~/ 2;
      return bytes[center * 4 + 3];
    }

    testWidgets('fades a layer on the canvas', (tester) async {
      final editor = await pumpEditor(tester);
      editor.addLayer(opaqueLayer(opacity: 0.5));
      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byKey(contentKey),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.5);
    });

    testWidgets('bakes the opacity into the captured image', (tester) async {
      await tester.runAsync(() async {
        final editor = await pumpEditor(tester);
        final layer = opaqueLayer(opacity: 0.5);
        editor.addLayer(layer);
        await tester.pumpAndSettle();

        final faded = await layer.captureAsPng(
          format: ui.ImageByteFormat.rawRgba,
          pixelRatio: 1,
        );
        final raw = await layer.captureAsPng(
          format: ui.ImageByteFormat.rawRgba,
          pixelRatio: 1,
          applyTransforms: false,
        );

        expect(centerAlpha(faded!), closeTo(128, 1));
        expect(centerAlpha(raw!), 255);
      });
    });

    for (final keyframed in [false, true]) {
      testWidgets('draws a ${keyframed ? 'keyframed ' : ''}drawing with '
          '${keyframed ? 'no' : 'its'} opacity', (tester) async {
        await tester.runAsync(() async {
          final editor = await pumpEditor(tester);
          final layer = PaintLayer(
            item: PaintedModel(
              mode: PaintMode.rect,
              offsets: const [Offset.zero, Offset(40, 40)],
              erasedOffsets: const [],
              color: const Color(0xFFFF0000),
              strokeWidth: 2,
              opacity: 1,
              fill: true,
            ),
            rawSize: const Size(40, 40),
            opacity: 0.5,
            keyframes: keyframed
                ? const [
                    LayerKeyframe(time: Duration.zero, offset: Offset.zero),
                  ]
                : null,
          );
          editor.addLayer(layer);
          await tester.pumpAndSettle();

          final bytes = await layer.captureAsPng(
            format: ui.ImageByteFormat.rawRgba,
            pixelRatio: 1,
          );

          expect(centerAlpha(bytes!), closeTo(keyframed ? 255 : 128, 1));
        });
      });
    }

    for (final grows in [false, true]) {
      testWidgets('captures a ${grows ? 'growing' : 'still'} layer at '
          '${grows ? 'its largest keyframed' : 'its own'} size', (
        tester,
      ) async {
        await tester.runAsync(() async {
          final editor = await pumpEditor(tester);
          final layer = opaqueLayer(
            kf: grows
                ? const [
                    LayerKeyframe(time: Duration.zero, offset: Offset.zero),
                    LayerKeyframe(
                      time: Duration(seconds: 1),
                      offset: Offset.zero,
                      scale: 2,
                    ),
                  ]
                : null,
          );
          editor.addLayer(layer);
          await tester.pumpAndSettle();

          final bytes = await layer.captureAsPng(
            format: ui.ImageByteFormat.rawRgba,
            basePixelRatio: 1,
          );

          // The laid-out layer at a pixel ratio of 1, or twice that on each
          // axis.
          final size = layer.repaintBoundaryKey.currentContext!.size!;
          final growth = grows ? 2 : 1;
          expect(
            bytes!.length,
            (size.width * growth).round() * (size.height * growth).round() * 4,
          );
        });
      });
    }

    testWidgets('leaves the opacity of a keyframed layer to its keyframes', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpEditor(tester);
        final layer = opaqueLayer(
          opacity: 0.5,
          kf: const [LayerKeyframe(time: Duration.zero, offset: Offset.zero)],
        );
        editor.addLayer(layer);
        await tester.pumpAndSettle();

        final bytes = await layer.captureAsPng(
          format: ui.ImageByteFormat.rawRgba,
          pixelRatio: 1,
        );

        expect(centerAlpha(bytes!), 255);
      });
    });
  });
  group('Layer mask', () {
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
      return key.currentState!;
    }

    const contentKey = ValueKey('masked-content');
    const circle = LayerMask(shape: LayerMaskShape.ellipse, size: Size(1, 1));

    WidgetLayer maskedLayer() => WidgetLayer(
      widget: const ColoredBox(
        key: contentKey,
        color: Color(0xFFFF0000),
        child: SizedBox(width: 20, height: 20),
      ),
      mask: circle,
    );

    /// The alphas of the middle pixel and of the top-left one of [bytes], an
    /// RGBA image of a square layer.
    (int, int) centerAndCornerAlpha(Uint8List bytes) {
      final side = math.sqrt(bytes.length / 4).round();
      final center = (side ~/ 2) * side + side ~/ 2;
      return (bytes[center * 4 + 3], bytes[3]);
    }

    testWidgets('masks a layer on the canvas', (tester) async {
      final editor = await pumpEditor(tester);
      editor.addLayer(maskedLayer());
      await tester.pumpAndSettle();

      final box = tester.widget<LayerMaskBox>(
        find.ancestor(
          of: find.byKey(contentKey),
          matching: find.byType(LayerMaskBox),
        ),
      );
      expect(box.mask, circle);
    });

    testWidgets('keeps the mask of a text layer whose text is edited', (
      tester,
    ) async {
      final editor = await pumpEditor(tester);
      final original = TextLayer(text: 'before', mask: circle);
      editor.addLayer(original);
      await tester.pumpAndSettle();

      editor.applyTextLayerChanges(original, TextLayer(text: 'after'));
      await tester.pumpAndSettle();

      final edited = editor.activeLayers.single as TextLayer;
      expect(edited.text, 'after');
      expect(edited.mask, circle);
    });

    for (final applyTransforms in [true, false]) {
      testWidgets('bakes the mask into the captured image '
          '${applyTransforms ? 'with' : 'without'} transforms', (tester) async {
        await tester.runAsync(() async {
          final editor = await pumpEditor(tester);
          final layer = maskedLayer();
          editor.addLayer(layer);
          await tester.pumpAndSettle();

          final bytes = await layer.captureAsPng(
            format: ui.ImageByteFormat.rawRgba,
            pixelRatio: 1,
            applyTransforms: applyTransforms,
          );

          expect(centerAndCornerAlpha(bytes!), (255, 0));
        });
      });
    }
  });
  group('Layer blend mode', () {
    Future<ProImageEditorState> pumpEditor(
      WidgetTester tester, {
      Uint8List? image,
    }) async {
      final key = GlobalKey<ProImageEditorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: ProImageEditor.memory(
            image ?? mockMemoryImage,
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
      return key.currentState!;
    }

    const contentKey = ValueKey('blended-content');

    WidgetLayer blendedLayer({double opacity = 1}) => WidgetLayer(
      widget: const ColoredBox(
        key: contentKey,
        color: Color(0xFFFF0000),
        child: SizedBox(width: 20, height: 20),
      ),
      opacity: opacity,
      blendMode: BlendMode.multiply,
    );

    testWidgets('blends a layer on the canvas, outside its opacity', (
      tester,
    ) async {
      final editor = await pumpEditor(tester);
      editor.addLayer(blendedLayer(opacity: 0.5));
      await tester.pumpAndSettle();

      final box = find.ancestor(
        of: find.byKey(contentKey),
        matching: find.byType(LayerBlendModeBox),
      );
      expect(
        tester.widget<LayerBlendModeBox>(box).blendMode,
        BlendMode.multiply,
      );
      // A fade outside the box would end the backdrop at its own layer, so
      // the layer would blend with nothing.
      expect(
        find.descendant(of: box, matching: find.byType(Opacity)),
        findsWidgets,
      );
    });

    testWidgets('leaves a censor area unblended', (tester) async {
      final editor = await pumpEditor(tester);
      editor.addLayer(
        PaintLayer(
          item: PaintedModel(
            mode: PaintMode.blur,
            offsets: const [Offset.zero, Offset(20, 20)],
            erasedOffsets: const [],
            color: Colors.black,
            strokeWidth: 4,
            opacity: 1,
          ),
          rawSize: const Size(20, 20),
          opacity: 1,
          blendMode: BlendMode.multiply,
        ),
      );
      await tester.pumpAndSettle();

      // Blended, it would blur the box's cleared backdrop and hide nothing.
      final box = find.ancestor(
        of: find.byType(LayerWidgetCensorItem),
        matching: find.byType(LayerBlendModeBox),
      );
      expect(
        tester.widget<LayerBlendModeBox>(box).blendMode,
        BlendMode.srcOver,
      );
    });

    testWidgets('keeps the blend mode of a text layer whose text is edited', (
      tester,
    ) async {
      final editor = await pumpEditor(tester);
      final original = TextLayer(text: 'before', blendMode: BlendMode.screen);
      editor.addLayer(original);
      await tester.pumpAndSettle();

      editor.applyTextLayerChanges(original, TextLayer(text: 'after'));
      await tester.pumpAndSettle();

      final edited = editor.activeLayers.single as TextLayer;
      expect(edited.text, 'after');
      expect(edited.blendMode, BlendMode.screen);
    });

    testWidgets('blends a layer into the generated image', (tester) async {
      await tester.runAsync(() async {
        // A 64 x 64 image of 0x8040C0.
        final recorder = ui.PictureRecorder();
        ui.Canvas(recorder).drawRect(
          const Rect.fromLTWH(0, 0, 64, 64),
          Paint()..color = const Color(0xFF8040C0),
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(64, 64);
        final png = (await image.toByteData(
          format: ui.ImageByteFormat.png,
        ))!.buffer.asUint8List();

        /// The RGB in the middle of the image the editor generates.
        Future<List<int>> middleOfGeneratedImage(
          ProImageEditorState editor,
        ) async {
          final codec = await ui.instantiateImageCodec(
            await editor.captureEditorImage(),
          );
          final result = (await codec.getNextFrame()).image;
          final data = (await result.toByteData())!;
          final i = (result.height ~/ 2 * result.width + result.width ~/ 2) * 4;
          return [data.getUint8(i), data.getUint8(i + 1), data.getUint8(i + 2)];
        }

        void expectNear(List<int> actual, List<int> expected) {
          for (var c = 0; c < 3; c++) {
            expect(
              (actual[c] - expected[c]).abs(),
              lessThanOrEqualTo(3),
              reason: 'got $actual, expected $expected',
            );
          }
        }

        final editor = await pumpEditor(tester, image: png);
        // Decoded, so the image is there to blend with.
        await tester.pumpAndSettle();
        expectNear(await middleOfGeneratedImage(editor), [0x80, 0x40, 0xC0]);

        editor.addLayer(
          WidgetLayer(
            // Larger than the image shows, so it covers all of it.
            widget: const ColoredBox(
              color: Color(0xFF60A020),
              child: SizedBox(width: 2000, height: 2000),
            ),
            blendMode: BlendMode.multiply,
          ),
        );
        await tester.pumpAndSettle();

        // 0x80 * 0x60, 0x40 * 0xA0, 0xC0 * 0x20, each over 255.
        expectNear(await middleOfGeneratedImage(editor), [48, 40, 24]);
      });
    });

    testWidgets('leaves the blend mode out of the captured image', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final editor = await pumpEditor(tester);
        final layer = blendedLayer();
        editor.addLayer(layer);
        await tester.pumpAndSettle();

        final bytes = (await layer.captureAsPng(
          format: ui.ImageByteFormat.rawRgba,
          pixelRatio: 1,
        ))!;

        // The layer's own red, not red multiplied with the image beneath.
        final middle = bytes.length ~/ 8 * 4;
        expect(bytes.sublist(middle, middle + 4), [255, 0, 0, 255]);
      });
    });
  });
}
