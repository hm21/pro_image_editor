// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/models/init_configs/filter_editor_init_configs.dart';
import 'package:pro_image_editor/modules/filter_editor/filter_editor.dart';
import 'package:pro_image_editor/modules/filter_editor/widgets/filtered_image.dart';
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

      expect(find.byType(FilteredImage), findsWidgets);
    });
  });
}
