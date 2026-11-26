import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/core/models/editor_image.dart';
import 'package:pro_image_editor/core/models/history/state_history.dart';
import 'package:pro_image_editor/features/main_editor/services/state_manager.dart';
import 'package:pro_image_editor/shared/services/content_recorder/controllers/content_recorder_controller.dart';
import 'package:pro_image_editor/shared/services/import_export/enums/export_import_enum.dart';
import 'package:pro_image_editor/shared/services/import_export/export_state_history.dart';
import 'package:pro_image_editor/shared/services/import_export/models/export_state_history_configs.dart';
import 'package:pro_image_editor/shared/utils/decode_image.dart';

class _MockContentRecorderController extends Mock
    implements ContentRecorderController {}

class _MockBuildContext extends Mock implements BuildContext {}

const _limit = 3;

TransformConfigs _crop(double left) => TransformConfigs(
  angle: 0,
  cropRect: Rect.fromLTWH(left, 10, 100, 100),
  originalSize: const Size(300, 200),
  cropEditorScreenRatio: 1,
  scaleUser: 1,
  scaleRotation: 1,
  aspectRatio: 1,
  flipX: false,
  flipY: false,
  offset: Offset.zero,
);

/// A manager that starts like the editor: an initial state at index 0.
StateManager _manager() {
  return StateManager(onStateHistoryChange: null, activeBackgroundImage: null)
    ..stateHistory = [
      EditorStateHistory(transformConfigs: TransformConfigs.empty(), blur: 0),
    ];
}

void _add(StateManager manager, [EditorStateHistory? history]) {
  manager.addHistory(
    history ?? EditorStateHistory(),
    historyLimit: _limit,
    enableScreenshotLimit: false,
  );
}

Future<Map<String, dynamic>> _exportCurrent(StateManager manager) {
  return ExportStateHistory(
    editorConfigs: const ProImageEditorConfigs(),
    stateHistory: manager.stateHistory,
    imageInfos: const ImageInfos(
      rawSize: Size(300, 200),
      originalRenderedSize: Size(300, 200),
      renderedSize: Size(300, 200),
      cropRectSize: Size(100, 100),
      pixelRatio: 1,
      isRotated: false,
    ),
    editorPosition: manager.historyPointer,
    contentRecorderCtrl: _MockContentRecorderController(),
    context: _MockBuildContext(),
    configs: const ExportEditorConfigs(
      historySpan: ExportHistorySpan.current,
      enableMinify: false,
    ),
  ).toMap();
}

Map<String, dynamic> _onlyEntry(Map<String, dynamic> exported) {
  final history = exported['history'] as List;
  expect(history, hasLength(1));
  return history.single as Map<String, dynamic>;
}

void main() {
  group('StateManager history limit', () {
    test('keeps a crop in effect after its entry is trimmed', () {
      final crop = _crop(10);
      final manager = _manager();
      _add(manager, EditorStateHistory(transformConfigs: crop));

      for (var i = 0; i < _limit * 3; i++) {
        _add(manager);
        expect(manager.transformConfigs, crop, reason: 'after edit ${i + 1}');
      }

      while (manager.historyPointer > 0) {
        manager.undo();
        expect(manager.transformConfigs, crop);
      }
    });

    test('exports a crop after its entry is trimmed', () async {
      final crop = _crop(10);
      final manager = _manager();
      _add(manager, EditorStateHistory(transformConfigs: crop));

      for (var i = 0; i < _limit * 3; i++) {
        _add(manager);
        final entry = _onlyEntry(await _exportCurrent(manager));
        expect(entry['transform'], crop.toMap(), reason: 'after edit ${i + 1}');
      }
    });

    test('keeps a blur in effect and exported after its entry is '
        'trimmed', () async {
      final manager = _manager();
      _add(manager, EditorStateHistory(blur: 4));

      for (var i = 0; i < _limit * 3; i++) {
        _add(manager);
        expect(manager.activeBlur, 4, reason: 'after edit ${i + 1}');
        final entry = _onlyEntry(await _exportCurrent(manager));
        expect(entry['blur'], 4, reason: 'after edit ${i + 1}');
      }
    });

    test('a later crop still replaces a trimmed one', () {
      final first = _crop(10);
      final second = _crop(40);
      final manager = _manager();
      _add(manager, EditorStateHistory(transformConfigs: first));
      _add(manager);
      _add(manager, EditorStateHistory(transformConfigs: second));

      for (var i = 0; i < _limit * 3; i++) {
        _add(manager);
        expect(manager.transformConfigs, second);
      }
    });

    test('an uncropped history stays uncropped and exports no transform '
        'or blur', () async {
      final manager = _manager();

      for (var i = 0; i < _limit * 3; i++) {
        _add(manager);
        expect(manager.transformConfigs.isEmpty, isTrue);
        final entry = _onlyEntry(await _exportCurrent(manager));
        expect(entry.containsKey('transform'), isFalse);
        expect(entry.containsKey('blur'), isFalse);
      }
    });

    test('does not change trimmed-into entries in place', () {
      final crop = _crop(10);
      final manager = _manager();
      _add(manager, EditorStateHistory(transformConfigs: crop, blur: 4));
      final held = <EditorStateHistory>[];
      for (var i = 0; i < _limit * 2; i++) {
        final entry = EditorStateHistory();
        held.add(entry);
        _add(manager, entry);
      }

      for (final entry in held) {
        expect(entry.transformConfigs, isNull);
        expect(entry.blur, isNull);
      }
      expect(manager.transformConfigs, crop);
      expect(manager.activeBlur, 4);
    });

    test('keeps background images with their entries after trimming', () {
      final oldImage = EditorImage(networkUrl: 'old');
      final newImage = EditorImage(networkUrl: 'new');
      final manager = _manager()..activeBackgroundImage = oldImage;
      _add(manager);
      _add(manager);
      _add(manager);
      manager.updateBackgroundImages(oldImage: oldImage, newImage: newImage);
      _add(manager);

      final seen = [manager.activeBackgroundImage?.networkUrl];
      while (manager.canUndo) {
        manager.undo();
        seen.add(manager.activeBackgroundImage?.networkUrl);
      }
      expect(seen, ['new', 'new', 'old', 'old']);
    });

    test('keeps a crop with a history limit of one', () async {
      final crop = _crop(10);
      final manager = _manager();
      _add(manager, EditorStateHistory(transformConfigs: crop));

      for (var i = 0; i < 4; i++) {
        manager.addHistory(
          EditorStateHistory(),
          historyLimit: 1,
          enableScreenshotLimit: false,
        );
        expect(manager.transformConfigs, crop);
        final entry = _onlyEntry(await _exportCurrent(manager));
        expect(entry['transform'], crop.toMap());
      }
    });
  });
}
