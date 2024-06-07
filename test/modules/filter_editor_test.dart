// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/modules/filter_editor/widgets/filtered_image.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../fake/fake_image.dart';

void main() {
  group('FilterEditor Tests', () {
    testWidgets('should build without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              initConfigs: FilterEditorInitConfigs(theme: ThemeData.light()),
            ),
          ),
        ),
      );

      expect(find.byType(FilterEditor), findsOneWidget);
    });

    testWidgets('should have filter buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              initConfigs: FilterEditorInitConfigs(theme: ThemeData.light()),
            ),
          ),
        ),
      );

      expect(find.byType(FilteredImage), findsWidgets);
    });
    testWidgets('should change filter factor', (WidgetTester tester) async {
      var key = GlobalKey<FilterEditorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              key: key,
              initConfigs: FilterEditorInitConfigs(theme: ThemeData.light()),
            ),
          ),
        ),
      );

      /// Set a filter that the slider is visible
      key.currentState!.setFilter(PresetFilters.addictiveBlue);

      await tester.pump();

      double initOpacity = key.currentState!.filterOpacity;

      // Find the slider widget
      final sliderFinder = find.byType(Slider);

      // Ensure the slider is found
      expect(sliderFinder, findsOneWidget);

      // Move the slider to a specific position
      await tester.drag(sliderFinder, const Offset(300.0, 0.0));

      expect(key.currentState!.filterOpacity, isNot(initOpacity));
    });
    testWidgets('should change filter when selected',
        (WidgetTester tester) async {
      var key = GlobalKey<FilterEditorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterEditor.memory(
              fakeMemoryImage,
              key: key,
              initConfigs: FilterEditorInitConfigs(theme: ThemeData.light()),
            ),
          ),
        ),
      );

      FilterModel targetFilter = PresetFilters.amaro;
      int index =
          presetFiltersList.indexWhere((el) => el.name == targetFilter.name);

      // Find the filter button
      final filterButtonFinder =
          find.byKey(ValueKey('Filter-${targetFilter.name}-$index'));

      // Ensure the filter button is found
      expect(filterButtonFinder, findsOneWidget);

      // Tap the filter button
      await tester.tap(filterButtonFinder);

      expect(key.currentState!.selectedFilter, targetFilter);
    });
  });
}
