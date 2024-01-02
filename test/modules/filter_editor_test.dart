import 'package:colorfilter_generator/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/modules/filter_editor.dart';
import 'package:pro_image_editor/utils/design_mode.dart';

import '../fake/fake_image.dart';

void main() {
  group('FilterEditor Tests', () {
    testWidgets('FilterEditor should build without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              theme: ThemeData.light(),
              designMode: ImageEditorDesignModeE.material,
              heroTag: 'unique_hero_tag',
            ),
          ),
        ),
      );

      expect(find.byType(FilterEditor), findsOneWidget);
    });

    testWidgets('FilterEditor should have filter buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              theme: ThemeData.light(),
              designMode: ImageEditorDesignModeE.material,
              heroTag: 'unique_hero_tag',
            ),
          ),
        ),
      );

      expect(find.byType(ImageWithFilter), findsWidgets);
    });

    testWidgets('FilterEditor should change filter on button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              theme: ThemeData.light(),
              designMode: ImageEditorDesignModeE.material,
              heroTag: 'unique_hero_tag',
            ),
          ),
        ),
      );

      final Finder filterButton = find.byType(GestureDetector).last;
      await tester.tap(filterButton);
      await tester.pump();

      final FilterEditorState state = tester.state(find.byType(FilterEditor));

      expect(state.selectedFilter, isNot(PresetFilters.none));
    });
  });
}
