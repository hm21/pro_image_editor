import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/shared/widgets/layer/widgets/layer_blend_mode_box.dart';

/// The RGB of the top-left pixel and the one right of the middle of what
/// [key] paints.
Future<List<List<int>>> _pixels(WidgetTester tester, GlobalKey key) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = (await tester.runAsync(boundary.toImage))!;
  final data = (await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
  ))!;
  List<int> at(int x, int y) {
    final i = (y * image.width + x) * 4;
    return [data.getUint8(i), data.getUint8(i + 1), data.getUint8(i + 2)];
  }

  return [at(2, 2), at(15, 2)];
}

/// A 20 x 4 backdrop of 0x8040C0 with [box] over its left half.
Widget _scene(GlobalKey key, Widget box) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(
    child: RepaintBoundary(
      key: key,
      child: SizedBox(
        width: 20,
        height: 4,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFF8040C0))),
            Positioned(left: 0, top: 0, width: 10, height: 4, child: box),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  group(LayerBlendModeBox, () {
    testWidgets('blends its child onto what is beneath it', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        _scene(
          key,
          const LayerBlendModeBox(
            blendMode: BlendMode.multiply,
            child: ColoredBox(color: Color(0xFF60A020)),
          ),
        ),
      );

      final [inside, beside] = await _pixels(tester, key);
      // 0x80 * 0x60, 0x40 * 0xA0, 0xC0 * 0x20, each over 255.
      expect(inside, [48, 40, 24]);
      expect(beside, [0x80, 0x40, 0xC0]);
    });

    testWidgets('fades a child faded inside it before blending it', (
      tester,
    ) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        _scene(
          key,
          const LayerBlendModeBox(
            blendMode: BlendMode.screen,
            child: Opacity(
              opacity: 0.5,
              child: ColoredBox(color: Color(0xFF60A020)),
            ),
          ),
        ),
      );

      final [inside, _] = await _pixels(tester, key);
      // The backdrop halfway to its screen with 0x60A020.
      for (final (actual, expected) in [
        (inside[0], 152),
        (inside[1], 124),
        (inside[2], 196),
      ]) {
        expect((actual - expected).abs(), lessThanOrEqualTo(1));
      }
    });

    testWidgets('paints a srcOver child without a layer', (tester) async {
      await tester.pumpWidget(
        const LayerBlendModeBox(
          blendMode: BlendMode.srcOver,
          child: SizedBox(),
        ),
      );

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}
