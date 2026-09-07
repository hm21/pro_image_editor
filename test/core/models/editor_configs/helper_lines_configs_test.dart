// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/helper_lines_configs.dart';

void main() {
  group('HelperLineConfigs.enableSmartAlignment', () {
    test('defaults to false so existing edge matching is unchanged', () {
      const configs = HelperLineConfigs();
      expect(configs.enableSmartAlignment, isFalse);
      expect(configs.enableEdgeSnapping, isTrue);
    });

    test('copyWith replaces enableSmartAlignment', () {
      const configs = HelperLineConfigs();
      final updated = configs.copyWith(enableSmartAlignment: true);
      expect(updated.enableSmartAlignment, isTrue);
      expect(configs.enableSmartAlignment, isFalse);
    });
  });

  group('HelperLineConfigs.enablePaintLayerSnapping', () {
    test('defaults to true so existing paint alignment is unchanged', () {
      const configs = HelperLineConfigs();
      expect(configs.enablePaintLayerSnapping, isTrue);
    });

    test('copyWith replaces enablePaintLayerSnapping', () {
      const configs = HelperLineConfigs();
      final updated = configs.copyWith(enablePaintLayerSnapping: false);
      expect(updated.enablePaintLayerSnapping, isFalse);
      expect(configs.enablePaintLayerSnapping, isTrue);
    });
  });
}
