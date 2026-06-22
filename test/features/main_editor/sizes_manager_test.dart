// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/features/main_editor/services/sizes_manager.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/screen_resize_detector.dart';

void main() {
  const configs = ProImageEditorConfigs();

  // A square decoded image plus a 2x content shrink yields a resize
  // `scaleFactor` of exactly 2, so every distinct layer is rescaled by 1/2.
  const decodedImageSize = Size(100, 100);
  const resizeEvent = ResizeEvent(
    oldContentSize: Size(200, 200),
    newContentSize: Size(100, 100),
  );
  const scaleFactor = 2.0;
  const initialScale = 2.0;
  const initialOffset = Offset(40, 60);

  TextLayer buildTextLayer() => TextLayer(
    text: 'Hello',
    scale: initialScale,
    offset: initialOffset,
  );

  PaintLayer buildPaintLayer() => PaintLayer(
    scale: 1.0,
    offset: Offset.zero,
    rawSize: const Size(10, 10),
    opacity: 1.0,
    item: PaintedModel(
      mode: PaintMode.line,
      offsets: const [Offset(0, 0), Offset(5, 5)],
      erasedOffsets: const [],
      color: const Color(0xFF000000),
      strokeWidth: 2,
      opacity: 1,
    ),
  );

  /// Reproduces the shared-instance history shape produced by
  /// `MainEditor.openPaintEditor`: pre-existing layers are deep-copied ONCE and
  /// the very same instances are then reused (via `List<Layer>.of`) across
  /// every per-stroke history entry. The supplied [textLayer] instance
  /// therefore appears in all `paintLayerCount + 1` entries.
  List<EditorStateHistory> buildPaintSessionHistory({
    required TextLayer textLayer,
    required int paintLayerCount,
  }) {
    final runningLayers = <Layer>[textLayer];
    final history = <EditorStateHistory>[
      EditorStateHistory(layers: List<Layer>.of(runningLayers)),
    ];
    for (var i = 0; i < paintLayerCount; i++) {
      runningLayers.add(buildPaintLayer());
      history.add(
        EditorStateHistory(layers: List<Layer>.of(runningLayers)),
      );
    }
    return history;
  }

  /// Builds a [SizesManager] wired up for `recalculateLayerPosition`.
  Future<SizesManager> buildSizesManager(WidgetTester tester) async {
    late SizesManager sizesManager;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            sizesManager = SizesManager(context: context, configs: configs)
              ..decodedImageSize = decodedImageSize;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return sizesManager;
  }

  group('SizesManager.recalculateLayerPosition', () {
    testWidgets(
      'rescales a layer shared across many history entries exactly once',
      (tester) async {
        final sizesManager = await buildSizesManager(tester);

        final textLayer = buildTextLayer();
        sizesManager.recalculateLayerPosition(
          history: buildPaintSessionHistory(
            textLayer: textLayer,
            paintLayerCount: 10,
          ),
          resizeEvent: resizeEvent,
        );

        // Rescaled once (scale / scaleFactor), NOT once-per-entry which would
        // compound to scale / scaleFactor^11 and shrink the layer to nothing.
        expect(textLayer.scale, closeTo(initialScale / scaleFactor, 1e-9));
        expect(
          textLayer.offset.dx,
          closeTo(initialOffset.dx / scaleFactor, 1e-9),
        );
        expect(
          textLayer.offset.dy,
          closeTo(initialOffset.dy / scaleFactor, 1e-9),
        );

        const compounded = initialScale / (scaleFactor * scaleFactor);
        expect(
          textLayer.scale,
          isNot(lessThanOrEqualTo(compounded)),
          reason: 'scale must not compound across shared history entries',
        );
      },
    );

    testWidgets(
      'final scale is independent of the number of layers in the session',
      (tester) async {
        final sizesManager = await buildSizesManager(tester);

        final singleSessionLayer = buildTextLayer();
        final manySessionLayer = buildTextLayer();

        sizesManager
          ..recalculateLayerPosition(
            history: buildPaintSessionHistory(
              textLayer: singleSessionLayer,
              paintLayerCount: 1,
            ),
            resizeEvent: resizeEvent,
          )
          ..recalculateLayerPosition(
            history: buildPaintSessionHistory(
              textLayer: manySessionLayer,
              paintLayerCount: 25,
            ),
            resizeEvent: resizeEvent,
          );

        expect(
          manySessionLayer.scale,
          closeTo(singleSessionLayer.scale, 1e-9),
        );
        expect(
          manySessionLayer.scale,
          closeTo(initialScale / scaleFactor, 1e-9),
        );
      },
    );

    testWidgets(
      'still rescales every distinct copy in the normal per-entry-copy case',
      (tester) async {
        final sizesManager = await buildSizesManager(tester);

        // Independent-but-content-equal copies, as produced by the normal
        // `copyLayerList` per-entry invariant (`copyWith` preserves the id, so
        // the copies compare equal). Because `Layer.==` is content-based these
        // are equal, so the identity-dedup guard must keep them distinct and
        // rescale each one.
        final copyA = buildTextLayer();
        final copyB = copyA.copyWith();
        expect(copyA == copyB, isTrue);
        expect(identical(copyA, copyB), isFalse);

        sizesManager.recalculateLayerPosition(
          history: [
            EditorStateHistory(layers: [copyA]),
            EditorStateHistory(layers: [copyB]),
          ],
          resizeEvent: resizeEvent,
        );

        expect(copyA.scale, closeTo(initialScale / scaleFactor, 1e-9));
        expect(copyB.scale, closeTo(initialScale / scaleFactor, 1e-9));
      },
    );
  });
}
