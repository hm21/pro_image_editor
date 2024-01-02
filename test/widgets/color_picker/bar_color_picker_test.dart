import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:pro_image_editor/widgets/color_picker/bar_color_picker.dart';

@GenerateNiceMocks([MockSpec<BarColorPicker>()])
void main() {
  group('BarColorPicker Tests', () {
    testWidgets('Picks color on tap', (WidgetTester tester) async {
      int colorValue = 0;
      await tester.pumpWidget(MaterialApp(
        home: BarColorPicker(
          initialColor: const Color(0xffff0000),
          colorListener: (value) => colorValue = value,
        ),
      ));

      await tester.tap(find.byType(BarColorPicker));
      await tester.pumpAndSettle();

      expect(colorValue, isNot(equals(0)));
    });
  });
}
