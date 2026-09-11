// Dart imports:
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
// Package imports:
import 'package:flutter_test/flutter_test.dart';
// Flutter imports:
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/main_editor/services/paint_layer_raster_cache.dart';
import 'package:pro_image_editor/features/paint_editor/models/eraser_model.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

const Size _body = Size(200, 300);
const Offset _center = Offset(-0.5, -0.5);
const _configs = PaintEditorConfigs();

PaintLayer _stroke({
  String? id,
  Offset offset = Offset.zero,
  double scale = 1,
  double rotation = 0,
  bool flipX = false,
  bool flipY = false,
  double opacity = 1,
  Color color = const Color(0xFF2E7D32),
  Duration? startTime,
  Duration? endTime,
  List<LayerAnimation> animations = const [],
  Duration? enterDuration,
  List<ErasedOffset> erasedOffsets = const [],
  int points = 12,
}) {
  final offsets = <Offset?>[
    for (var i = 0; i < points; i++) Offset(4 + i * 5.0, 30 + sin(i / 2) * 20),
  ];
  return PaintLayer(
    id: id,
    item: PaintedModel(
      mode: PaintMode.freeStyle,
      offsets: offsets,
      erasedOffsets: erasedOffsets,
      color: color,
      strokeWidth: 6,
      opacity: 1,
    ),
    rawSize: const Size(64, 60),
    opacity: opacity,
    offset: offset,
    scale: scale,
    rotation: rotation,
    flipX: flipX,
    flipY: flipY,
    startTime: startTime,
    endTime: endTime,
    enterDuration: enterDuration,
    animations: animations,
  );
}

TextLayer _text() => TextLayer(text: 'hi', offset: Offset.zero);

PaintLayerRasterPlan _plan(
  PaintLayerRasterCache cache,
  List<Layer> layers, {
  Set<String> excluded = const {},
  Duration? playTime,
  double pixelRatio = 1,
  PaintEditorConfigs configs = _configs,
}) {
  return cache.plan(
    layers: layers,
    excludedIds: excluded,
    playTime: playTime,
    editorBodySize: _body,
    fractionalOffset: _center,
    pixelRatio: pixelRatio,
    paintEditorConfigs: configs,
  );
}

/// Renders [layers] the way the main editor does — one `LayerWidget` per
/// layer inside a body-sized stack — and returns the RGBA bytes.
Future<ByteData> _renderLive(WidgetTester tester, List<Layer> layers) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox.fromSize(
            size: _body,
            child: ColoredBox(
              color: const Color(0xFFFFFFFF),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final layer in layers)
                    LayerWidget(
                      key: layer.key,
                      layer: layer,
                      configs: const ProImageEditorConfigs(),
                      editorBodySize: _body,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  // Rasterizing is real engine work, which only completes inside runAsync.
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData();
    image.dispose();
    return bytes;
  });
  return bytes!;
}

/// Draws the cached image of every run in [plan] onto a white body-sized
/// canvas, exactly where `_PaintRunImage` positions it, and returns the RGBA
/// bytes.
Future<ByteData> _renderCached(
  WidgetTester tester,
  PaintLayerRasterPlan plan,
) async {
  final bytes = await tester.runAsync(() => _recordCached(plan));
  return bytes!;
}

Future<ByteData> _recordCached(PaintLayerRasterPlan plan) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..drawRect(Offset.zero & _body, Paint()..color = const Color(0xFFFFFFFF));
  for (final run in plan.runs) {
    final picture = PaintLayerRasterCache.recordRun(
      run,
      editorBodySize: _body,
      fractionalOffset: _center,
      pixelRatio: 1,
      paintEditorConfigs: _configs,
    );
    final image = await picture.toImage(
      run.bounds.width.ceil(),
      run.bounds.height.ceil(),
    );
    picture.dispose();
    canvas.drawImage(image, run.bounds.topLeft, Paint());
    image.dispose();
  }
  final image = await recorder.endRecording().toImage(
    _body.width.toInt(),
    _body.height.toInt(),
  );
  final bytes = await image.toByteData();
  image.dispose();
  return bytes!;
}

/// The share of pixels whose RGBA differs by more than [tolerance] in any
/// channel, plus a sanity count of ink pixels so an all-white pair cannot
/// pass by accident.
({double mismatch, int ink}) _compare(
  ByteData a,
  ByteData b, {
  int tolerance = 24,
}) {
  expect(a.lengthInBytes, b.lengthInBytes);
  var mismatched = 0;
  var ink = 0;
  final pixels = a.lengthInBytes ~/ 4;
  for (var i = 0; i < pixels; i++) {
    var differs = false;
    for (var c = 0; c < 4; c++) {
      final pa = a.getUint8(i * 4 + c);
      final pb = b.getUint8(i * 4 + c);
      if ((pa - pb).abs() > tolerance) differs = true;
    }
    if (differs) mismatched++;
    if (a.getUint8(i * 4) != 255 ||
        a.getUint8(i * 4 + 1) != 255 ||
        a.getUint8(i * 4 + 2) != 255) {
      ink++;
    }
  }
  return (mismatch: mismatched / pixels, ink: ink);
}

void main() {
  group('PaintLayerRasterCache.plan', () {
    test('groups consecutive paint layers and splits at other layer types', () {
      final cache = PaintLayerRasterCache();
      final a = _stroke(id: 'a');
      final b = _stroke(id: 'b', offset: const Offset(10, 10));
      final t = _text();
      final c = _stroke(id: 'c', offset: const Offset(-20, 40));

      final plan = _plan(cache, [a, b, t, c]);

      expect(plan.runs, hasLength(2));
      expect(plan.runs[0].layerIds, ['a', 'b']);
      expect(plan.runs[0].insertIndex, 0);
      expect(plan.runs[1].layerIds, ['c']);
      expect(plan.runs[1].insertIndex, 3);
      cache.dispose();
    });

    test(
      'keeps selected, animated, censor and timeline-hidden layers live',
      () {
        final cache = PaintLayerRasterCache();
        final selected = _stroke(id: 'selected');
        final animated = _stroke(
          id: 'animated',
          animations: const [
            LayerAnimation(
              type: LayerAnimationType.fade,
              phase: AnimationPhase.animateIn,
              duration: Duration(seconds: 1),
            ),
          ],
        );
        final fading = _stroke(
          id: 'fading',
          enterDuration: const Duration(milliseconds: 500),
        );
        final later = _stroke(
          id: 'later',
          startTime: const Duration(seconds: 4),
          endTime: const Duration(seconds: 6),
        );
        final now = _stroke(
          id: 'now',
          startTime: Duration.zero,
          endTime: const Duration(seconds: 6),
        );
        final censor = PaintLayer(
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
        );

        final plan = _plan(
          cache,
          [selected, animated, fading, later, now, censor],
          excluded: {'selected'},
          playTime: const Duration(seconds: 1),
        );

        expect(plan.runs, hasLength(1));
        expect(plan.runs.single.layerIds, ['now']);
        cache.dispose();
      },
    );

    test(
      'does not cache a merged layer that fades through an Opacity widget',
      () {
        final cache = PaintLayerRasterCache();
        final merged = PaintLayer(
          items: [_stroke().item, _stroke().item],
          rawSize: const Size(64, 60),
          opacity: 0.5,
        );
        final single = _stroke(id: 'single', opacity: 0.5);

        final plan = _plan(cache, [merged, single]);

        expect(plan.runs, hasLength(1));
        expect(plan.runs.single.layerIds, ['single']);
        cache.dispose();
      },
    );

    test('leaves modes with a custom path builder live', () {
      final cache = PaintLayerRasterCache();
      final configs = PaintEditorConfigs(
        customPathBuilders: {
          PaintMode.freeStyle:
              ({required item, required scale, required paintEditorConfigs}) =>
                  throw UnimplementedError(),
        },
      );

      final plan = _plan(cache, [_stroke()], configs: configs);

      expect(plan.runs, isEmpty);
      cache.dispose();
    });

    test('drops a run whose image would exceed the pixel budget', () {
      final cache = PaintLayerRasterCache(maxPixels: 1000);

      final plan = _plan(cache, [_stroke()]);

      expect(plan.runs, isEmpty);
      cache.dispose();
    });

    test('drops a run whose image would exceed maxDimension on one side', () {
      // Well within the pixel budget; only the width is over the limit.
      final cache = PaintLayerRasterCache(maxDimension: 64);

      final plan = _plan(cache, [_stroke()]);

      expect(plan.runs, isEmpty);
      cache.dispose();
    });

    test('keeps at most maxImages runs', () {
      final cache = PaintLayerRasterCache(maxImages: 1);

      final plan = _plan(cache, [_stroke(id: 'a'), _text(), _stroke(id: 'b')]);

      expect(plan.runs, hasLength(1));
      expect(plan.runs.single.layerIds, ['a']);
      cache.dispose();
    });
  });

  group('PaintLayerRasterCache.layerKey', () {
    test('changes with geometry, opacity and erased strokes', () {
      final base = _stroke(id: 'x');
      final baseKey = PaintLayerRasterCache.layerKey(base);

      expect(
        PaintLayerRasterCache.layerKey(
          _stroke(id: 'x', offset: const Offset(1, 0)),
        ),
        isNot(baseKey),
      );
      expect(
        PaintLayerRasterCache.layerKey(_stroke(id: 'x', scale: 1.5)),
        isNot(baseKey),
      );
      expect(
        PaintLayerRasterCache.layerKey(_stroke(id: 'x', rotation: 0.3)),
        isNot(baseKey),
      );
      expect(
        PaintLayerRasterCache.layerKey(_stroke(id: 'x', flipX: true)),
        isNot(baseKey),
      );
      expect(
        PaintLayerRasterCache.layerKey(_stroke(id: 'x', opacity: 0.4)),
        isNot(baseKey),
      );
      expect(
        PaintLayerRasterCache.layerKey(
          _stroke(
            id: 'x',
            erasedOffsets: const [
              ErasedOffset(offset: Offset(10, 10), radius: 4),
            ],
          ),
        ),
        isNot(baseKey),
      );
    });

    test('ignores the timeline window, so retiming keeps the raster', () {
      final baseKey = PaintLayerRasterCache.layerKey(_stroke(id: 'x'));

      expect(
        PaintLayerRasterCache.layerKey(
          _stroke(
            id: 'x',
            startTime: const Duration(seconds: 1),
            endTime: const Duration(seconds: 2),
          ),
        ),
        baseKey,
      );
    });
  });

  group('PaintLayerRasterCache.layerBounds', () {
    test('covers the rotated box of a transformed layer', () {
      final layer = _stroke(
        offset: const Offset(20, -30),
        scale: 2,
        rotation: pi / 3,
      );

      final bounds = PaintLayerRasterCache.layerBounds(
        layer,
        editorBodySize: _body,
        fractionalOffset: _center,
      );

      final center = Offset(_body.width / 2 + 20, _body.height / 2 - 30);
      final halfDiagonal = layer.size.longestSide * sqrt(2) / 2;
      expect(bounds.contains(center), isTrue);
      // Every corner of the rotated box lies within its circumscribed circle,
      // and the bounds must contain them all.
      expect(bounds.width, lessThanOrEqualTo(halfDiagonal * 2 + 10));
      expect(bounds.height, lessThanOrEqualTo(halfDiagonal * 2 + 10));
      expect(bounds.width, greaterThan(layer.size.width));
    });
  });

  group('PaintLayerRasterCache.recordRun', () {
    testWidgets('matches the live LayerWidget render pixel for pixel', (
      tester,
    ) async {
      final layers = <Layer>[
        _stroke(id: 'plain'),
        _stroke(
          id: 'moved',
          offset: const Offset(30, 60),
          color: const Color(0xFF1565C0),
        ),
        _stroke(
          id: 'scaled-rotated',
          offset: const Offset(-40, -70),
          scale: 1.6,
          rotation: 0.7,
          color: const Color(0xFFC62828),
        ),
        _stroke(
          id: 'flipped',
          offset: const Offset(40, -90),
          flipX: true,
          flipY: true,
          rotation: -0.4,
          color: const Color(0xFF6A1B9A),
        ),
        _stroke(
          id: 'translucent',
          offset: const Offset(-30, 90),
          opacity: 0.5,
          color: const Color(0xFF000000),
        ),
      ];
      final cache = PaintLayerRasterCache();
      final plan = _plan(cache, layers);
      expect(plan.runs, hasLength(1));

      final live = await _renderLive(tester, layers);
      final cached = await _renderCached(tester, plan);

      final result = _compare(live, cached);
      // Every layer leaves ink, so a blank pair cannot pass.
      expect(result.ink, greaterThan(500));
      // Anti-aliasing at rotated edges differs by a pixel here and there;
      // anything beyond a fraction of a percent is a placement error.
      expect(result.mismatch, lessThan(0.0005));
      cache.dispose();
    });
  });

  group('PaintLayerRasterCache.ensure', () {
    testWidgets('renders an image sized to the run and notifies', (
      tester,
    ) async {
      final cache = PaintLayerRasterCache();
      final plan = _plan(cache, [_stroke()], pixelRatio: 2);
      final run = plan.runs.single;
      var notified = 0;
      cache.addListener(() => notified++);

      expect(cache.imageFor(run), isNull);
      cache.ensure(
        run,
        editorBodySize: _body,
        fractionalOffset: _center,
        pixelRatio: 2,
        paintEditorConfigs: _configs,
      );
      await tester.runAsync(() async {
        while (notified == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });

      final image = cache.imageFor(run)!;
      expect(image.width, (run.bounds.width * 2).ceil());
      expect(image.height, (run.bounds.height * 2).ceil());
      expect(notified, 1);
      cache.dispose();
    });

    testWidgets('evicts the oldest image beyond maxImages', (tester) async {
      final cache = PaintLayerRasterCache(maxImages: 1);
      final first = _plan(cache, [_stroke(id: 'a')]).runs.single;
      final second = _plan(cache, [_stroke(id: 'b')]).runs.single;
      var notified = 0;
      cache.addListener(() => notified++);

      for (final run in [first, second]) {
        cache.ensure(
          run,
          editorBodySize: _body,
          fractionalOffset: _center,
          pixelRatio: 1,
          paintEditorConfigs: _configs,
        );
        final expected = notified + 1;
        await tester.runAsync(() async {
          while (notified < expected) {
            await Future<void>.delayed(const Duration(milliseconds: 10));
          }
        });
      }

      expect(cache.contains(first), isFalse);
      expect(cache.contains(second), isTrue);
      cache.dispose();
    });

    testWidgets('reports a failed render once and leaves the run live', (
      tester,
    ) async {
      final cache = _FailingCache();
      final run = _plan(cache, [_stroke()]).runs.single;
      final errors = <FlutterErrorDetails>[];
      final onError = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = onError);

      // `ensure` runs on every build; a run the GPU cannot render must not be
      // attempted again on each of them.
      for (var i = 0; i < 3; i++) {
        cache.ensure(
          run,
          editorBodySize: _body,
          fractionalOffset: _center,
          pixelRatio: 1,
          paintEditorConfigs: _configs,
        );
        await tester.runAsync(() async {
          while (cache.isRendering) {
            await Future<void>.delayed(const Duration(milliseconds: 10));
          }
        });
      }

      expect(cache.attempts, 1);
      expect(errors, hasLength(1));
      expect(cache.imageFor(run), isNull);
      expect(cache.hasFailed(run), isTrue);
      cache.dispose();
    });
  });
}

/// A cache whose every render fails, the way one past the GPU's texture
/// limit does.
class _FailingCache extends PaintLayerRasterCache {
  int attempts = 0;

  @override
  Future<ui.Image> toImage(ui.Picture picture, int width, int height) {
    attempts++;
    throw StateError('no texture');
  }
}
