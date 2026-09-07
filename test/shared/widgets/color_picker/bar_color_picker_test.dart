// Flutter imports:
// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
// Project imports:
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/shared/widgets/color_picker/bar_color_picker.dart';

@GenerateNiceMocks([MockSpec<BarColorPicker>()])
void main() {
  group('BarColorPicker Tests', () {
    testWidgets('Picks color on tap', (WidgetTester tester) async {
      int colorValue = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BarColorPicker(
            configs: const ProImageEditorConfigs(),
            color: const Color(0xffff0000),
            colorListener: (value) => colorValue = value,
          ),
        ),
      );

      /// Wait that init animation is done
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byType(BarColorPicker));
      await tester.pumpAndSettle();

      expect(colorValue, isNot(equals(0)));
    });
  });
}
