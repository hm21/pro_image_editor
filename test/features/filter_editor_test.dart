// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pro_image_editor/core/models/init_configs/filter_editor_init_configs.dart';
import 'package:pro_image_editor/features/filter_editor/filter_editor.dart';

// Project imports:
import '../mock/mock_image.dart';

void main() {
  final initConfigs = FilterEditorInitConfigs(
    theme: ThemeData(),
  );
  var key = GlobalKey<FilterEditorState>();
  Future<void> pumpEditor(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilterEditor.memory(
            mockMemoryImage,
            key: key,
            initConfigs: initConfigs,
          ),
        ),
      ),
    );
  }

  group('FilterEditor Initialization', () {
    testWidgets('creates FilterEditor using memory image',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: FilterEditor.memory(mockMemoryImage, initConfigs: initConfigs),
      ));

      expect(find.byType(FilterEditor), findsOneWidget);
    });
    testWidgets('creates FilterEditor using network image',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home:
              FilterEditor.network(mockNetworkImage, initConfigs: initConfigs),
        ));
      });

      expect(find.byType(FilterEditor), findsOneWidget);
    });
    testWidgets('creates FilterEditor using file image',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: FilterEditor.file(mockFileImage, initConfigs: initConfigs),
      ));

      expect(find.byType(FilterEditor), findsOneWidget);
    });
    testWidgets('creates FilterEditor using file path',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: FilterEditor.file('', initConfigs: initConfigs),
      ));

      expect(find.byType(FilterEditor), findsOneWidget);
    });
    group('creates FilterEditor using autoSource constructor', () {
      testWidgets('Auto-detects from memory image',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: FilterEditor.autoSource(
            byteArray: mockMemoryImage,
            initConfigs: initConfigs,
          ),
        ));

        expect(find.byType(FilterEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from network image',
          (WidgetTester tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(MaterialApp(
            home: FilterEditor.autoSource(
              networkUrl: mockNetworkImage,
              initConfigs: initConfigs,
            ),
          ));
        });

        expect(find.byType(FilterEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file image', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: FilterEditor.autoSource(
            file: mockFileImage,
            initConfigs: initConfigs,
          ),
        ));

        expect(find.byType(FilterEditor), findsOneWidget);
      });
      testWidgets('Auto-detects from file path', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          home: FilterEditor.autoSource(file: '', initConfigs: initConfigs),
        ));

        expect(find.byType(FilterEditor), findsOneWidget);
      });
    });
  });

  group('FilterEditor UI Components', () {
    testWidgets('should have filter buttons', (WidgetTester tester) async {
      await pumpEditor(tester);

      expect(find.byType(FilteredWidget), findsWidgets);
    });
  });
  group('FilterEditor Behavior', () {
    testWidgets('should change filter factor', (WidgetTester tester) async {
      await pumpEditor(tester);

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
      await pumpEditor(tester);

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

    testWidgets('should set filterOpacity via setFilterOpacity()',
        (tester) async {
      await pumpEditor(tester);

      final editor = key.currentState!;
      double newValue = 0.7;

      editor.setFilterOpacity(newValue);

      expect(editor.filterOpacity, newValue);
    });
    testWidgets('should set filter via setFilter()', (tester) async {
      await pumpEditor(tester);

      final editor = key.currentState!;
      FilterModel filter = presetFiltersList.last;

      editor.setFilter(filter);

      expect(editor.selectedFilter.name, filter.name);
      expect(editor.selectedFilter.filters, filter.filters);
    });
  });
}
