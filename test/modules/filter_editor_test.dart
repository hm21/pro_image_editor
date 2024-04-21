import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/models/init_configs/filter_editor_init_configs.dart';
import 'package:pro_image_editor/modules/filter_editor/filter_editor.dart';
import 'package:pro_image_editor/modules/filter_editor/widgets/image_with_filter.dart';

import '../fake/fake_image.dart';

void main() {
  group('FilterEditor Tests', () {
    testWidgets('FilterEditor should build without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              initConfigs: FilterEditorInitConfigs(
                theme: ThemeData.light(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FilterEditor), findsOneWidget);
    });

    testWidgets('FilterEditor should have filter buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              initConfigs: FilterEditorInitConfigs(
                theme: ThemeData.light(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ImageWithFilter), findsWidgets);
    });
  });
}
