import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/providers/tilt_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  group('TiltProvider', () {
    late TiltProvider tiltProvider;
    late CropRotateEditorConfigs mockConfigs;
    late I18nCropRotateEditor mockI18n;
    late List<String> callbackLog;

    setUp(() {
      callbackLog = [];
      mockConfigs = const CropRotateEditorConfigs();
      mockI18n = const I18nCropRotateEditor();

      tiltProvider = TiltProvider(
        tiltRotate: 15.0,
        tiltVertical: -10.0,
        tiltHorizontal: 5.0,
        cropRotateConfigs: mockConfigs,
        i18n: mockI18n,
        isTiltEditorVisible: true,
        tiltMode: TiltMode.rotate,
        tiltResetCount: 2,
        onTiltChangeUpdate: (mode, value) {
          callbackLog.add('update:${mode.name}:$value');
        },
        onTiltChangeEnd: (mode, value) {
          callbackLog.add('end:${mode.name}:$value');
        },
        onToggleTiltBar: (isVisible) {
          callbackLog.add('toggle:$isVisible');
        },
        onUpdateResetCount: () {
          callbackLog.add('resetCount');
        },
        child: const SizedBox(),
      );
    });

    test('should initialize with correct values', () {
      expect(tiltProvider.tiltRotate, 15.0);
      expect(tiltProvider.tiltVertical, -10.0);
      expect(tiltProvider.tiltHorizontal, 5.0);
      expect(tiltProvider.isTiltEditorVisible, true);
      expect(tiltProvider.tiltMode, TiltMode.rotate);
      expect(tiltProvider.tiltResetCount, 2);
      expect(tiltProvider.cropRotateConfigs, mockConfigs);
      expect(tiltProvider.i18n, mockI18n);
    });

    test('should access tiltConfigs from cropRotateConfigs', () {
      expect(tiltProvider.tiltConfigs, mockConfigs.tiltConfigs);
    });

    testWidgets('should find provider using of() method', (tester) async {
      await tester.pumpWidget(tiltProvider);

      final context = tester.element(find.byType(SizedBox));
      final foundProvider = TiltProvider.of(context);

      expect(foundProvider, isNotNull);
      expect(foundProvider.tiltRotate, 15.0);
    });

    testWidgets('should return null using maybeOf() when not found', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox());

      final context = tester.element(find.byType(SizedBox));
      final foundProvider = TiltProvider.maybeOf(context);

      expect(foundProvider, isNull);
    });

    testWidgets('should find provider using maybeOf() when exists', (
      tester,
    ) async {
      await tester.pumpWidget(tiltProvider);

      final context = tester.element(find.byType(SizedBox));
      final foundProvider = TiltProvider.maybeOf(context);

      expect(foundProvider, isNotNull);
      expect(foundProvider!.tiltHorizontal, 5.0);
    });

    test('should toggle tilt editor state', () {
      tiltProvider.setTiltEditorState(false);

      expect(callbackLog, contains('toggle:false'));

      tiltProvider.setTiltEditorState(true);

      expect(callbackLog, contains('toggle:true'));
    });

    test('should set tilt mode for rotate', () {
      tiltProvider.setTiltMode(TiltMode.rotate);

      expect(callbackLog, contains('update:rotate:15.0'));
    });

    test('should set tilt mode for horizontal', () {
      tiltProvider.setTiltMode(TiltMode.horizontal);

      expect(callbackLog, contains('update:horizontal:5.0'));
    });

    test('should set tilt mode for vertical', () {
      tiltProvider.setTiltMode(TiltMode.vertical);

      expect(callbackLog, contains('update:vertical:-10.0'));
    });

    test('should notify when tiltMode changes', () {
      final newProvider = TiltProvider(
        tiltRotate: 15.0,
        tiltVertical: -10.0,
        tiltHorizontal: 5.0,
        cropRotateConfigs: mockConfigs,
        i18n: mockI18n,
        isTiltEditorVisible: true,
        tiltMode: TiltMode.horizontal,
        tiltResetCount: 2,
        onTiltChangeUpdate: (mode, value) {},
        onTiltChangeEnd: (mode, value) {},
        onToggleTiltBar: (isVisible) {},
        onUpdateResetCount: () {},
        child: const SizedBox(),
      );

      expect(tiltProvider.updateShouldNotify(newProvider), true);
    });

    test('should notify when isTiltEditorVisible changes', () {
      final newProvider = TiltProvider(
        tiltRotate: 15.0,
        tiltVertical: -10.0,
        tiltHorizontal: 5.0,
        cropRotateConfigs: mockConfigs,
        i18n: mockI18n,
        isTiltEditorVisible: false,
        tiltMode: TiltMode.rotate,
        tiltResetCount: 2,
        onTiltChangeUpdate: (mode, value) {},
        onTiltChangeEnd: (mode, value) {},
        onToggleTiltBar: (isVisible) {},
        onUpdateResetCount: () {},
        child: const SizedBox(),
      );

      expect(tiltProvider.updateShouldNotify(newProvider), true);
    });

    test('should notify when tiltResetCount changes', () {
      final newProvider = TiltProvider(
        tiltRotate: 15.0,
        tiltVertical: -10.0,
        tiltHorizontal: 5.0,
        cropRotateConfigs: mockConfigs,
        i18n: mockI18n,
        isTiltEditorVisible: true,
        tiltMode: TiltMode.rotate,
        tiltResetCount: 3,
        onTiltChangeUpdate: (mode, value) {},
        onTiltChangeEnd: (mode, value) {},
        onToggleTiltBar: (isVisible) {},
        onUpdateResetCount: () {},
        child: const SizedBox(),
      );

      expect(tiltProvider.updateShouldNotify(newProvider), true);
    });

    test('should not notify when nothing changes', () {
      final identicalProvider = TiltProvider(
        tiltRotate: 20.0, // Different value but not tracked
        tiltVertical: -5.0, // Different value but not tracked
        tiltHorizontal: 8.0, // Different value but not tracked
        cropRotateConfigs: mockConfigs,
        i18n: mockI18n,
        isTiltEditorVisible: true,
        tiltMode: TiltMode.rotate,
        tiltResetCount: 2,
        onTiltChangeUpdate: (mode, value) {},
        onTiltChangeEnd: (mode, value) {},
        onToggleTiltBar: (isVisible) {},
        onUpdateResetCount: () {},
        child: const SizedBox(),
      );

      expect(tiltProvider.updateShouldNotify(identicalProvider), false);
    });
  });
}
