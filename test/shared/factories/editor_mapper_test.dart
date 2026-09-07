import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/factories/editor_mapper.dart';

void main() {
  group('EditorMapper.getEditorModeFromConfigs', () {
    test('returns EditorMode.paint for PaintEditorInitConfigs', () {
      final configs = PaintEditorInitConfigs(theme: ThemeData.dark());
      final mode = EditorMapper.getEditorModeFromConfigs(configs);
      expect(mode, EditorMode.paint);
    });

    test('returns EditorMode.cropRotate for CropRotateEditorInitConfigs', () {
      final configs = CropRotateEditorInitConfigs(theme: ThemeData.dark());
      final mode = EditorMapper.getEditorModeFromConfigs(configs);
      expect(mode, EditorMode.cropRotate);
    });

    test('returns EditorMode.tune for TuneEditorInitConfigs', () {
      final configs = TuneEditorInitConfigs(theme: ThemeData.dark());
      final mode = EditorMapper.getEditorModeFromConfigs(configs);
      expect(mode, EditorMode.tune);
    });

    test('returns EditorMode.filter for FilterEditorInitConfigs', () {
      final configs = FilterEditorInitConfigs(theme: ThemeData.dark());
      final mode = EditorMapper.getEditorModeFromConfigs(configs);
      expect(mode, EditorMode.filter);
    });

    test('returns EditorMode.blur for BlurEditorInitConfigs', () {
      final configs = BlurEditorInitConfigs(theme: ThemeData.dark());
      final mode = EditorMapper.getEditorModeFromConfigs(configs);
      expect(mode, EditorMode.blur);
    });
  });
}
