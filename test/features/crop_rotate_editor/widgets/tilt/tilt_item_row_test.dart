import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/crop_rotate_editor_configs.dart';
import 'package:pro_image_editor/core/models/i18n/i18n_crop_rotate_editor.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/providers/tilt_provider.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/widgets/tilt/tilt_item_row.dart';

CropRotateEditorConfigs createTestConfigs({
  bool showRotate = true,
  bool showHorizontal = true,
  bool showVertical = true,
  Widget? customBottomBar,
}) {
  return CropRotateEditorConfigs(
    style: const CropRotateEditorStyle(
      bottomBarColor: Colors.black,
      tiltStyle: TiltStyle(
        bottomBarSelectedColor: Colors.red,
        barHeight: 40,
        cursor: SystemMouseCursors.click,
        tickMarkColor: Colors.black,
        tickMarkWidth: 2,
        tickMarkHeight: 8,
        indicatorWidth: 2,
        indicatorHeight: 15,
        indicatorColor: Colors.blue,
        activeColor: Colors.green,
      ),
    ),
    icons: const CropRotateEditorIcons(
      backButton: Icons.arrow_back,
      reset: Icons.refresh,
      tiltRotate: Icons.rotate_right,
      tiltHorizontal: Icons.swap_horiz,
      tiltVertical: Icons.swap_vert,
    ),
    tiltConfigs: TiltConfigs(
      showTiltRotate: showRotate,
      showTiltHorizontal: showHorizontal,
      showTiltVertical: showVertical,
    ),
    widgets: CropRotateEditorWidgets(
      tiltWidgets: TiltWidgets(bottomBar: customBottomBar),
    ),
  );
}

Widget buildTestWidget({required CropRotateEditorConfigs configs}) {
  return MaterialApp(
    home: TiltProvider(
      tiltRotate: 0,
      tiltVertical: 0,
      tiltHorizontal: 0,
      tiltMode: TiltMode.rotate,
      tiltResetCount: 0,
      isTiltEditorVisible: true,
      cropRotateConfigs: configs,
      i18n: const I18nCropRotateEditor(),
      onTiltChangeEnd: (mode, value) {},
      onTiltChangeUpdate: (mode, value) {},
      onToggleTiltBar: (isVisible) {},
      onUpdateResetCount: () {},
      child: const Scaffold(body: TiltItemRow()),
    ),
  );
}

void main() {
  group('TiltItemRow config tests', () {
    testWidgets('renders all default buttons when configs enabled', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(configs: createTestConfigs()));

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Rotate'), findsOneWidget);
      expect(find.text('Horizontal'), findsOneWidget);
      expect(find.text('Vertical'), findsOneWidget);
    });

    testWidgets('hides rotate when config disabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(configs: createTestConfigs(showRotate: false)),
      );

      expect(find.text('Rotate'), findsNothing);
      expect(find.text('Horizontal'), findsOneWidget);
      expect(find.text('Vertical'), findsOneWidget);
    });

    testWidgets('hides horizontal when config disabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(configs: createTestConfigs(showHorizontal: false)),
      );

      expect(find.text('Horizontal'), findsNothing);
      expect(find.text('Rotate'), findsOneWidget);
      expect(find.text('Vertical'), findsOneWidget);
    });

    testWidgets('hides vertical when config disabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(configs: createTestConfigs(showVertical: false)),
      );

      expect(find.text('Vertical'), findsNothing);
      expect(find.text('Rotate'), findsOneWidget);
      expect(find.text('Horizontal'), findsOneWidget);
    });

    testWidgets('renders custom bottom bar when provided', (tester) async {
      const custom = Text('CustomBottomBar');
      await tester.pumpWidget(
        buildTestWidget(configs: createTestConfigs(customBottomBar: custom)),
      );

      expect(find.text('CustomBottomBar'), findsOneWidget);
      expect(find.text('Back'), findsNothing);
      expect(find.text('Reset'), findsNothing);
    });
  });
}
