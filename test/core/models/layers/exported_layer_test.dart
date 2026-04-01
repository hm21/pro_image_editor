import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/layers/exported_layer.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';
import 'package:pro_image_editor/features/paint_editor/paint_editor.dart';

void main() {
  group('ExportedLayer', () {
    test('stores all constructor parameters', () {
      final layer = TextLayer(text: 'Hello');
      final bytes = Uint8List.fromList([1, 2, 3]);
      const size = Size(100, 50);

      final exported = ExportedLayer(
        layer: layer,
        bytes: bytes,
        logicalSize: size,
      );

      expect(exported.layer, same(layer));
      expect(exported.bytes, same(bytes));
      expect(exported.logicalSize, size);
    });

    test('works with EmojiLayer', () {
      final layer = EmojiLayer(emoji: '😀');
      final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
      const size = Size(48, 48);

      final exported = ExportedLayer(
        layer: layer,
        bytes: bytes,
        logicalSize: size,
      );

      expect(exported.layer, isA<EmojiLayer>());
      expect((exported.layer as EmojiLayer).emoji, '😀');
      expect(exported.bytes.length, 4);
      expect(exported.logicalSize.width, 48);
      expect(exported.logicalSize.height, 48);
    });

    test('works with PaintLayer', () {
      final item = PaintedModel(
        mode: PaintMode.freeStyle,
        offsets: [Offset.zero],
        erasedOffsets: [],
        color: const Color(0xFF000000),
        strokeWidth: 5,
        opacity: 1,
        fill: false,
      );
      final layer = PaintLayer(
        item: item,
        rawSize: const Size(200, 200),
        opacity: 1.0,
      );
      final bytes = Uint8List.fromList(List.filled(100, 0));
      const size = Size(200, 200);

      final exported = ExportedLayer(
        layer: layer,
        bytes: bytes,
        logicalSize: size,
      );

      expect(exported.layer, isA<PaintLayer>());
      expect(exported.bytes.length, 100);
      expect(exported.logicalSize, const Size(200, 200));
    });

    test('preserves Size.zero for unmounted layers', () {
      final layer = Layer();
      final bytes = Uint8List.fromList([0]);

      final exported = ExportedLayer(
        layer: layer,
        bytes: bytes,
        logicalSize: Size.zero,
      );

      expect(exported.logicalSize, Size.zero);
    });
  });
}
